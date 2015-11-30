//
//  SOSortingViewController.m
//  Shoutout
//
//  Created by Diana Elezaj on 11/12/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOSortingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "SOSortingCVC.h"
#import "SOVideo.h"
#import "SOProject.h"
#import "NSURL+ImageGenerator.h"
#import <Parse/Parse.h>
#import "BMAReorderableFlowLayout.h"
#import "UICollectionView+BMADecorators.h"
#import "SOCachedObject.h"
#import "SOSignUpViewController.h"
#import "SOLoginViewController.h"
#import "FullScreenMergeViewController.h"
#import "VideoViewController.h"
#import "SOCameraOverlay.h"
#import "SOCachedProjects.h"
#import "SOContactsAndFriendsViewController.h"
#import "SOContactsViewController.h"
#import "SOExportHandler.h"
#import "SOShareViewController.h"
const float kVideoLengthMax2 = 10.0;

@implementation NSMutableArray (BMAReordering)

- (void)bma_moveItemAtIndex:(NSUInteger)index toIndex:(NSUInteger)toIndex {
    if (index == toIndex) {
        return;
    }
    // When index<toIndex
    for (NSUInteger i = index; i < toIndex; ++i) {
        [self exchangeObjectAtIndex:i withObjectAtIndex:i+1];
    }
    // When toIndex>index
    for (NSUInteger i = index; i > toIndex; --i) {
        [self exchangeObjectAtIndex:i withObjectAtIndex:i-1];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ArrayReorderedMustReloadData" object:[NSNumber numberWithInteger:toIndex]];
    
    
}
@end
@interface SOSortingViewController ()
<
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
BMAReorderableDelegateFlowLayout,
UICollectionViewDataSource,
UIGestureRecognizerDelegate
>
{
    IBOutlet UICollectionView *collectionView;
}
@property (weak, nonatomic) IBOutlet UIView *videoPlayingView;

@property (nonatomic) NSURL *videoURL;
@property (nonatomic) BOOL playStop;

@property (nonatomic) NSIndexPath *draggedIndex;

@property (nonatomic) NSMutableArray <UIImage *>*imagesArray;

@property (nonatomic) UIImagePickerController *imagePicker;

@property (nonatomic) NSMutableArray<SOVideo *> *videoFilesArray;

@property (nonatomic) NSMutableArray<AVAsset *> *videoAssetsArray;

@property (nonatomic) AVPlayer *avPlayer;

@property (nonatomic) AVPlayerItem *avPlayerItem;

@property (nonatomic) AVPlayerLayer *avPlayerLayer;

@property (nonatomic) BOOL doneFetching;
@property (weak, nonatomic) IBOutlet UIButton *videoPlayingViewCancelButton;

@property (nonatomic) BOOL hasRespondedToSignUp;

@property (nonatomic) UIView *dropDownPlayerView;

@property (nonatomic) SOCameraOverlay *cameraOverlay;
@end

@implementation SOSortingViewController

#pragma mark - Life cycle methods

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.playStop = YES;
    
    UIScreenEdgePanGestureRecognizer * edgePan = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(popToRoot:)];
    [edgePan setEdges:UIRectEdgeLeft];
    edgePan.delegate = self;
    [self.view addGestureRecognizer:edgePan];
    
    self.videoAssetsArray = [NSMutableArray new];
    self.videoFilesArray = [NSMutableArray new];
    self.videoThumbnails = [NSMutableArray new];
    
    self.videoPlayingViewCancelButton.hidden = YES;
    
    
    UINib *myNib = [UINib nibWithNibName:@"SOSortingCollectionViewCell" bundle:nil];
    
    [collectionView registerNib:myNib forCellWithReuseIdentifier:@"sortingIdentifier"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload:) name:@"ArrayReorderedMustReloadData" object:nil];
    NSLog(@"sorting proj %@",self.sortingProject.objectId);
    [self fetch];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToProfile) name:@"SignUpComplete" object:nil];
}

-(void)popToProfile
{
    self.hasRespondedToSignUp = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

#pragma mark - Query block called
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [collectionView reloadData];
    
    if (self.videoThumbnails.count > 0) {
        
        [self collectionViewBatchReload];
    }
}



-(void) alertView {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Invite a friend" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"signedUpAlready"])
        {
            SOContactsAndFriendsViewController *contactsAndFriendsVC = [[SOContactsAndFriendsViewController alloc] init];
            contactsAndFriendsVC.projectID = self.sortingProject.objectId;
            [self presentViewController:contactsAndFriendsVC animated:YES completion:nil];
//            SOContactsViewController *contactsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SOContactsViewControllerID"];
//            contactsVC.projectId = self.sortingProject.objectId;
//            [self presentViewController:contactsVC animated:YES completion:nil];
        }
        else
        {
            SOSignUpViewController *signUpViewController = [SOSignUpViewController new];
            signUpViewController.projectID = self.sortingProject.objectId;
            
            [self presentViewController:signUpViewController animated:YES completion:nil];
        }
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Take a video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self setupCamera];
    }]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}




-(void)fetch{
    UIView *activityIndicatorView = [[UIView alloc] initWithFrame:self.view.bounds];
    UIActivityIndicatorView *activityIndicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    activityIndicator.center= activityIndicatorView.center;
    activityIndicator.color = [UIColor blackColor];
    activityIndicatorView.backgroundColor = [UIColor whiteColor];
    activityIndicatorView.alpha = 0.6;
    
    [activityIndicator startAnimating];
    [activityIndicatorView addSubview:activityIndicator];
    [self.view addSubview:activityIndicatorView];
    [self.view bringSubviewToFront:activityIndicatorView];
    if (![SOCachedProjects sharedManager].cachedProjects[self.sortingProject.objectId]) {
        
        [self.sortingProject fetchVideos:^(NSMutableArray<SOVideo *> *fetchedVideos, NSMutableArray<AVAsset *> *fetchedVideoAssets, NSMutableArray<PFFile *> *thumbnails) {
            
            self.videoThumbnails = [NSMutableArray arrayWithArray:thumbnails];
            self.videoAssetsArray = [NSMutableArray arrayWithArray:fetchedVideoAssets];
            NSLog(@"VIDEO THUMBNAILS ARRAY: %@",self.videoThumbnails);
            
            self.doneFetching = YES;
            [collectionView reloadData];
            [self collectionViewBatchReload];
            [activityIndicator stopAnimating];
            [activityIndicator removeFromSuperview];
            [activityIndicatorView removeFromSuperview];
        }];
    }else{
        [self.sortingProject getNewVideosIfNeeded:^(NSMutableArray<SOVideo *> *fetchedVideos, NSMutableArray<AVAsset *> *avAssets, NSMutableArray<PFFile *> *allThumbnails) {
            self.videoThumbnails = allThumbnails;
            self.videoAssetsArray = avAssets;
            self.doneFetching = YES;
            [collectionView reloadData];
            [self collectionViewBatchReload];
            [activityIndicator stopAnimating];
            [activityIndicator removeFromSuperview];
            [activityIndicatorView removeFromSuperview];
        }];
    }
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // [collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [self.sortingProject reindexVideos];
    
    [self.sortingProject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"Saved new order of videos, assuming there is a new order");
    }];
    
    SOCachedObject *currentlyCached = [SOCachedProjects sharedManager].cachedProjects[self.sortingProject.objectId];
    currentlyCached.cachedProject = self.sortingProject;
    currentlyCached.avassetsArray = self.videoAssetsArray;
    currentlyCached.thumbnailsArray = self.videoThumbnails;
    
    [[SOCachedProjects sharedManager].cachedProjects removeObjectForKey:self.sortingProject.objectId];
    [[SOCachedProjects sharedManager].cachedProjects setObject:currentlyCached forKey:self.sortingProject.objectId];
    
    if(self.hasRespondedToSignUp){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MoveToProfile" object:nil];
    }
    
}

- (void)reload:(NSNotification *)notif{
    
    NSNumber *number = notif.object;
    NSInteger numb = [number integerValue];
    
    if(numb == 0 || numb == 1|| numb == 2){
        if (self.videoThumbnails.count>5) {
            [collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0], [NSIndexPath indexPathForRow:4 inSection:0]]];
        }
    }
}
#pragma mark - video playing method

- (IBAction)cancelButtonTapped:(UIButton *)sender {
    self.navigationController.navigationBar.hidden = NO;
    self.videoPlayingViewCancelButton.hidden = YES;
    
    self.videoPlayingView.frame = CGRectMake(0, 68, self.view.frame.size.width, self.view.frame.size.height - collectionView.frame.size.height);
    
    [self.avPlayerLayer removeFromSuperlayer];
    self.avPlayerLayer =nil;
    self.avPlayerItem = nil;
    self.avPlayer = nil;
}


#pragma mark - Merging methods
- (IBAction)previewButtonTapped:(UIButton *)sender {
    [self mergeVideosInArray:self.videoAssetsArray];
}



-(void)mergeVideosInArray:(NSArray<AVAsset *> *)videosArray{
    
    [self.avPlayerLayer removeFromSuperlayer];
    self.avPlayerLayer =nil;
    self.avPlayerItem = nil;
    self.avPlayer = nil;
    
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoCompositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVMutableCompositionTrack *audioCompositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    CGSize size = CGSizeZero;
    CMTime time = kCMTimeZero;
    
    NSMutableArray *instructions = [NSMutableArray new];
    
    for(AVAsset *asset in videosArray)
    {
        AVAssetTrack *videoAssetTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        
        NSError *videoError;
        [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration)
                                       ofTrack:videoAssetTrack
                                        atTime:time
                                         error:&videoError];
        //Added this line in an attempt to fix the orientation
        videoCompositionTrack.preferredTransform = videoAssetTrack.preferredTransform;
        //
        if (videoError) {
            NSLog(@"Error - %@", videoError.debugDescription);
        }
        
        AVAssetTrack *audioAssetTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
        
        NSError *audioError;
        [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration)
                                       ofTrack:audioAssetTrack
                                        atTime:time
                                         error:&audioError];
        if (audioError) {
            NSLog(@"Error - %@", audioError.debugDescription);
        }
        AVMutableVideoCompositionInstruction *videoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        videoCompositionInstruction.timeRange = CMTimeRangeMake(time, videoAssetTrack.timeRange.duration);
        videoCompositionInstruction.layerInstructions = @[[AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack]];
        [instructions addObject:videoCompositionInstruction];
        
        time = CMTimeAdd(time, videoAssetTrack.timeRange.duration);
        
        if (CGSizeEqualToSize(size, CGSizeZero)) {
            size = videoAssetTrack.naturalSize;;
        }
    }
    
    
    AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
    mutableVideoComposition.instructions = instructions;
    mutableVideoComposition.frameDuration = CMTimeMake(1, 30);
    mutableVideoComposition.renderSize = size;
    
    AVPlayerItem *pi = [AVPlayerItem playerItemWithAsset:mixComposition];
    pi.videoComposition = mutableVideoComposition;
    
    AVPlayer *player = [AVPlayer playerWithPlayerItem:pi];
    
    VideoViewController *videoVC = [VideoViewController new];
    videoVC.avPlayer = player;
    [self presentViewController:videoVC animated:YES completion:nil];
    
    //AVPlayerLayer *avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:player];
    self.navigationController.navigationBar.hidden = YES;
    
    //    self.videoPlayingView.frame = self.view.bounds;
    //    [avPlayerLayer setFrame:self.videoPlayingView.frame];
    //    avPlayerLayer.frame = self.videoPlayingView.bounds;
    //
    //    [self.videoPlayingView.layer addSublayer:avPlayerLayer];
    //    self.videoPlayingViewCancelButton.hidden = NO;
    
    
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *documentsDirectory = [paths objectAtIndex:0];
    //    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
    //                             [NSString stringWithFormat:@"mergeVideo-%d.mp4",arc4random() % 1000]];
    //    NSURL *myURL = [NSURL fileURLWithPath:myPathDocs];
    //    // 5 - Create exporter with High Quality
    //    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
    //                                                                      presetName:AVAssetExportPresetHighestQuality];
    //    exporter.outputURL=myURL;
    
    //    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    //    exporter.shouldOptimizeForNetworkUse = YES;
    //    [exporter exportAsynchronouslyWithCompletionHandler:^{
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            [self exportDidFinish:exporter];
    //        });
    //    }];
}


//-(void)exportDidFinish:(AVAssetExportSession*)session {
//    if (session.status == AVAssetExportSessionStatusCompleted) {
//        //        NSURL *outputURL = session.outputURL;
//        SOVideo *video = [[SOVideo alloc] initWithVideoUrl:session.outputURL];
//        self.sortingProject.shoutout = video;
//    }
//
//    AVAsset *avAsset = nil;
//    AVPlayerItem *avPlayerItem = nil;
//    AVPlayer *avPlayer = nil;
//    AVPlayerLayer *avPlayerLayer =nil;
//
//    if (avPlayer.rate > 0 && !avPlayer.error) {
//        [avPlayer pause];
//    }
//
//    else {
//
//        avAsset = [self.sortingProject.shoutout assetFromVideoFile];
//
//        avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
//
//        avPlayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
//
//        avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:avPlayer];
//
//        [avPlayerLayer setFrame:self.videoPlayingView.frame];
//        avPlayerLayer.frame = self.videoPlayingView.bounds;
//
//        [self.videoPlayingView.layer addSublayer:avPlayerLayer];
//
//        [avPlayer seekToTime:kCMTimeZero];
//        [avPlayer play];
//    }
//}

- (IBAction)shareButtonTapped:(UIButton *)sender{
    
    UIView *activityIndicatorView = [[UIView alloc] initWithFrame:self.view.bounds];
    UIActivityIndicatorView *activityIndicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    activityIndicator.center= activityIndicatorView.center;
    activityIndicator.color = [UIColor blackColor];
    activityIndicatorView.backgroundColor = [UIColor whiteColor];
    activityIndicatorView.alpha = 0.6;
    
    [activityIndicator startAnimating];
    [activityIndicatorView addSubview:activityIndicator];
    [self.view addSubview:activityIndicatorView];
    [self.view bringSubviewToFront:activityIndicatorView];
    
    SOExportHandler *exportHandler = [[SOExportHandler alloc]init];
    AVMutableComposition *mutableComp = [exportHandler mergeVideosFrom:self.videoAssetsArray];
    [exportHandler exportMixComposition:mutableComp completion:^(NSURL *url, BOOL success) {
        if (success) {
            SOVideo *shoutout = [[SOVideo alloc]initWithVideoUrl:url];
            [shoutout saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                NSString *passedUrl = shoutout.video.url;
                [activityIndicator stopAnimating];
                [activityIndicator removeFromSuperview];
                [activityIndicatorView removeFromSuperview];
                [self segueToShareViewControllerWithUrl:passedUrl];
            }];
        }
        else{
            
            NSLog(@"Unsuccessful, must troubleshoot");
            [activityIndicator stopAnimating];
            [activityIndicator removeFromSuperview];
            [activityIndicatorView removeFromSuperview];
        }
    }];
  
}

- (void)segueToShareViewControllerWithUrl:(NSString *)sharedUrl{
    
    SOShareViewController *shareVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
    shareVC.shareUrl = sharedUrl;
    [self presentViewController:shareVC animated:YES completion:nil];
    
}



# pragma mark - Video camera setup

- (void)setupCamera{
    
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = [[NSArray alloc]initWithObjects:(NSString *)kUTTypeMovie, nil];
    self.imagePicker.videoMaximumDuration = kVideoLengthMax2;
    self.imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    self.cameraOverlay = [[SOCameraOverlay alloc]initFromNib];
    self.cameraOverlay.frame = CGRectMake(0, 0, self.imagePicker.view.bounds.size.width, self.imagePicker.view.bounds.size.height - 60);
    self.imagePicker.cameraOverlayView = self.cameraOverlay;
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
    
}

# pragma mark - Image Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    SOVideo *video = [[SOVideo alloc]initWithVideoUrl:info [UIImagePickerControllerMediaURL]];
    video.index = self.sortingProject.videos.count;
    if ([self.cameraOverlay hasText]) {
        video.details = self.cameraOverlay.tagTextField.text;
    }
    
    [video saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self viewWillAppear:YES];
    }];
    
    self.videoThumbnails  = [NSMutableArray arrayWithArray:self.videoThumbnails];
    [self.videoThumbnails addObject:video.thumbnail];
    
    [self.videoAssetsArray addObject:[AVAsset assetWithURL:info[UIImagePickerControllerMediaURL]]];
    NSLog(@"sorting proj %@",self.sortingProject.objectId);
    
    [self.sortingProject.videos addObject:video];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(110, 110);
}

#pragma mark - Add video or invite people button

- (IBAction)plusButtonTapped:(UIButton *)sender {
    
}


#pragma mark - UICollectionViewDataSourceDelegate

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)aCollectionView
     numberOfItemsInSection:(NSInteger)aSection{
    if(!self.doneFetching){
        return 0;
    }
    return self.videoThumbnails.count+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(self.videoThumbnails.count !=0 && indexPath.row != self.videoThumbnails.count){
        SOSortingCVC *cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:@"sortingIdentifier" forIndexPath:indexPath];
        
        cell.videoImageView.file = nil;
        cell.videoImageView.image = nil;
        cell.videoImageView.file = self.videoThumbnails[indexPath.row];
        cell.videoImageView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.videoImageView loadInBackground];
        
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    
    else if(indexPath.row == self.videoThumbnails.count)
    {
        SOSortingCVC *cell2 = [aCollectionView dequeueReusableCellWithReuseIdentifier:@"sortingIdentifier" forIndexPath:indexPath];
        cell2.videoImageView.image = nil;
        cell2.videoImageView.image = [UIImage imageNamed: @"PlusButtonCell" ];
        return cell2;
    }
    else{
        return nil;
    }
    
}

- (void)collectionView:(UICollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == self.videoThumbnails.count && self.videoThumbnails)
    {
        [self alertView];
    }
    
    else {
        
        if (self.avPlayerLayer) {
            
            [self.avPlayerLayer removeFromSuperlayer];
        }
        
        AVAsset *avAsset = nil;
        self.avPlayerLayer =nil;
        self.avPlayerItem = nil;
        self.avPlayer = nil;
        
        if ( self.avPlayer.rate !=0 && !self.avPlayer.error) {
            self.avPlayer.rate = 0.0;
        }
        
        avAsset = self.videoAssetsArray[indexPath.row];
        
        self.avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
        
        self.avPlayer = [[AVPlayer alloc]initWithPlayerItem:self.avPlayerItem];
        
        self.avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
        
        [self.avPlayerLayer setFrame:self.videoPlayingView.frame];
        
        self.avPlayerLayer.frame = self.videoPlayingView.bounds;
        
        [self.videoPlayingView.layer addSublayer:self.avPlayerLayer];
        
        [self.avPlayer seekToTime:kCMTimeZero];
        [self.avPlayer play];
        
    }
    [collectionView reloadData];
}


#pragma mark - Reorderable layout

- (BOOL)collectionView:(UICollectionView *)collectionView canDragItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)acollectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    UIView *overlay = [[UIView alloc] init];
    overlay.backgroundColor = [UIColor blackColor];
    overlay.frame = acollectionView.bounds;
    overlay.alpha = 0;
    [acollectionView bma_setOverlayView:overlay];
    self.draggedIndex = indexPath;
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (BMAReorderingAnimationBlock)animationForDragBeganInCollectionView:(UICollectionView *)acollectionView layout:(UICollectionViewLayout *)collectionViewLayout {
    return ^(UICollectionViewCell *draggedView){
        draggedView.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
        [acollectionView bma_overlayView].alpha = 0.5;
        PFImageView *draggedImageView = [[PFImageView alloc]initWithFrame:draggedView.bounds];
        
        draggedImageView.file = self.videoThumbnails[self.draggedIndex.row];
        [draggedImageView loadInBackground];
        draggedImageView.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
        
        [draggedView addSubview:draggedImageView];
    };
}

- (BMAReorderingAnimationBlock)animationForDragEndedInCollectionView:(UICollectionView *)acollectionView layout:(UICollectionViewLayout *)collectionViewLayout {
    return ^(UICollectionViewCell *draggedView){
        draggedView.transform = CGAffineTransformIdentity;
        
        [acollectionView bma_overlayView].alpha = 0;
    };
}

- (void)collectionView:(UICollectionView *)acollectionView didMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath {
    [self.videoThumbnails bma_moveItemAtIndex:(NSUInteger)indexPath.item toIndex:(NSUInteger)toIndexPath.item];
    
    [self.videoAssetsArray bma_moveItemAtIndex:(NSUInteger)indexPath.item toIndex:(NSUInteger)toIndexPath.item];
    
    SOVideo *first = self.sortingProject.videos[indexPath.row];
    [self.sortingProject.videos replaceObjectAtIndex:indexPath.row withObject:self.sortingProject.videos[toIndexPath.row]];
    [self.sortingProject.videos replaceObjectAtIndex:toIndexPath.row withObject:first];
    [collectionView reloadData];
}

-(void)collectionViewBatchReload{
    
    NSMutableArray *indexPathArray = [NSMutableArray new];
    for(int i =0; i <=self.videoThumbnails.count; i++)
    {
        [indexPathArray addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    [collectionView performBatchUpdates:^{
        [collectionView reloadItemsAtIndexPaths:indexPathArray];
    } completion:^(BOOL finished) {
        NSLog(@"Reloaded");
    }];
    
}

#pragma mark - Gesture Recognizer
- (void)popToRoot:(UIScreenEdgePanGestureRecognizer *)edgePan{
    CGPoint translation = [edgePan translationInView:self.view];
    
    if (translation.x >= 100) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    
}

@end