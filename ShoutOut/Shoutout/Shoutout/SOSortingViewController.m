//
//  SOSortingViewController.m
//  Shoutout
//
//  Created by Diana Elezaj on 11/12/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOSortingViewController.h"
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
UICollectionViewDataSource
>
{
    IBOutlet UICollectionView *collectionView;
}
@property (weak, nonatomic) IBOutlet UIView *videoPlayingView;

@property (nonatomic) NSIndexPath *draggedIndex;

@property (nonatomic) NSMutableArray <UIImage *>*imagesArray;

@property (nonatomic) UIImagePickerController *imagePicker;

@property (nonatomic) NSMutableArray<SOVideo *> *videoFilesArray;

@property (nonatomic) NSMutableArray<AVAsset *> *videoAssetsArray;

@property (nonatomic) AVPlayer *avPlayer;

@property (nonatomic) AVPlayerItem *avPlayerItem;

@property (nonatomic) AVPlayerLayer *avPlayerLayer;
@end

@implementation SOSortingViewController

#pragma mark - Life cycle methods

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@"passed %@",self.sortingProject.title);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(modalCameraPopup)];
    
    self.videoAssetsArray = [NSMutableArray new];
    self.videoFilesArray = [NSMutableArray new];
    self.videoThumbnails = [NSMutableArray new];
    
    UINib *myNib = [UINib nibWithNibName:@"SOSortingCollectionViewCell" bundle:nil];
    
    [collectionView registerNib:myNib forCellWithReuseIdentifier:@"sortingIdentifier"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload:) name:@"ArrayReorderedMustReloadData" object:nil];
}

#pragma mark - Query block called
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
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
    
    [self.sortingProject fetchVideos:^(NSMutableArray<SOVideo *> *fetchedVideos, NSMutableArray<AVAsset *> *fetchedVideoAssets, NSMutableArray<PFFile *> *thumbnails) {

        self.videoThumbnails = [NSMutableArray arrayWithArray:thumbnails];
        self.videoAssetsArray = [NSMutableArray arrayWithArray:fetchedVideoAssets];
        
        [collectionView reloadData];
        [activityIndicator stopAnimating];
        [activityIndicator removeFromSuperview];
        [activityIndicatorView removeFromSuperview];
    }];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [self.sortingProject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"Saved new order of videos, assuming there is a new order");
    }];
    
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

#pragma mark - Merging methods

- (IBAction)mergeAndSaveButtonTapped:(UIButton *)sender {
    
    [self mergeVideosInArray:self.videoAssetsArray];
}

-(void)mergeVideosInArray:(NSArray<AVAsset *> *)videosArray{
    
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
    
    AVPlayerLayer *avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:player];
    
    [avPlayerLayer setFrame:self.videoPlayingView.frame];
    avPlayerLayer.frame = self.videoPlayingView.bounds;
    
    [self.videoPlayingView.layer addSublayer:avPlayerLayer];
    
    [player seekToTime:kCMTimeZero];
    [player play];
    
    
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

-(void)exportDidFinish:(AVAssetExportSession*)session {
    if (session.status == AVAssetExportSessionStatusCompleted) {
//        NSURL *outputURL = session.outputURL;
        SOVideo *video = [[SOVideo alloc] initWithVideoUrl:session.outputURL];
        self.sortingProject.shoutout = video;
    }
    
    AVAsset *avAsset = nil;
    AVPlayerItem *avPlayerItem = nil;
    AVPlayer *avPlayer = nil;
    AVPlayerLayer *avPlayerLayer =nil;
    
    if (avPlayer.rate > 0 && !avPlayer.error) {
        [avPlayer pause];
    }
    
    else {
        
        avAsset = [self.sortingProject.shoutout assetFromVideoFile];
        
        avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
        
        avPlayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
        
        avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:avPlayer];
        
        [avPlayerLayer setFrame:self.videoPlayingView.frame];
        avPlayerLayer.frame = self.videoPlayingView.bounds;
        
        [self.videoPlayingView.layer addSublayer:avPlayerLayer];
        
        [avPlayer seekToTime:kCMTimeZero];
        [avPlayer play];
    }
}

#pragma mark - New video button selector

-(void)modalCameraPopup{
    
    [self setupCamera];
}


# pragma mark - Video camera setup

- (void)setupCamera{
    
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = [[NSArray alloc]initWithObjects:(NSString *)kUTTypeMovie, nil];
    self.imagePicker.videoMaximumDuration = kVideoLengthMax2;
    self.imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}


# pragma mark - Image Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    SOVideo *video = [[SOVideo alloc]initWithVideoUrl:info [UIImagePickerControllerMediaURL]];
    
    [self.videoThumbnails addObject:video.thumbnail];
    
    //Add video to current projects
    [self.sortingProject.videos addObject:video];
    
    // Alternative is to use saveEventually, allowing saving when connection is available
    [self.sortingProject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"Saved current PROJECT in background");

        NSLog(@"Saved project videos: %@",self.sortingProject.videos);
        [picker dismissViewControllerAnimated:YES completion:nil];
    }];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(100, 100);
}

#pragma mark - UICollectionViewDataSourceDelegate

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0.0;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)aCollectionView
     numberOfItemsInSection:(NSInteger)aSection{
    
    return [self.videoThumbnails count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView
                  cellForItemAtIndexPath:(NSIndexPath *)IndexPath{
    
    SOSortingCVC *cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:@"sortingIdentifier" forIndexPath:IndexPath];
    
    PFImageView *imageViewCopy = [[PFImageView alloc]initWithFrame:cell.videoImageView.bounds];
    [cell addSubview:imageViewCopy];
    cell.videoImageView.file = nil;
    
//    cell.videoImageView.file = self.videoThumbnails[anIndexPath.row];
    imageViewCopy.file = self.videoThumbnails[IndexPath.row];
    NSLog(@"row %lu and file:%@",IndexPath.row, self.videoThumbnails[IndexPath.row]);
    [imageViewCopy loadInBackground];
    imageViewCopy.contentMode = UIViewContentModeScaleAspectFit;
//    cell.videoImageView.contentMode = UIViewContentModeScaleAspectFit;
//    [cell.videoImageView loadInBackground];
    
    cell.backgroundColor = [UIColor blackColor];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.avPlayerLayer) {
        [self.avPlayerLayer removeFromSuperlayer];
    }
    
    self.avPlayerLayer =nil;
    AVAsset *avAsset = nil;
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

@end