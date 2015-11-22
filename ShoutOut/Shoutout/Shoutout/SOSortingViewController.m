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
    
    //    NSMutableArray *imagesArray;
}
@property (weak, nonatomic) IBOutlet UIView *videoPlayingView;
@property (nonatomic) NSIndexPath *draggedIndex;

@property (nonatomic) NSMutableArray <UIImage *>*imagesArray;

@property (nonatomic) UIImagePickerController *imagePicker;

@property (nonatomic) NSMutableArray<SOVideo *> *videoFilesArray;

@property (nonatomic) NSMutableArray<AVAsset *> *videoAssetsArray;

@end

@implementation SOSortingViewController

#pragma mark - Life cycle methods

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@"passed %@",self.sortingProject.title);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(modalCameraPopup)];
    
    self.videoAssetsArray = [NSMutableArray new];
    self.videoFilesArray = [NSMutableArray new];
    
    
    //    self.videoThumbnails =[NSMutableArray new];
    //
    //    for(int i = 0; i < self.sortingProject.videos.count; i++){
    //        SOVideo *video = self.sortingProject.videos[i];
    //        PFFile *thumbnail = video.thumbnail;
    //        [self.videoThumbnails addObject:thumbnail];
    //    }
    //
    //    [self videoThumbnails];
    
    //    imagesArray = [[NSMutableArray alloc] initWithObjects:@"video1.jpg", @"video2.jpg", @"video3.jpg", nil];
    
    UINib *myNib = [UINib nibWithNibName:@"SOSortingCollectionViewCell" bundle:nil];
    
    [collectionView registerNib:myNib forCellWithReuseIdentifier:@"sortingIdentifier"];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[self videoQuery];
    
    UIView *activityIndicatorView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    activityView.center= activityIndicatorView.center;
    activityView.color = [UIColor blackColor];
    activityIndicatorView.backgroundColor = [UIColor whiteColor];
    activityIndicatorView.alpha = 0.6;

    [activityView startAnimating];
    [activityIndicatorView addSubview:activityView];
    [self.view addSubview:activityIndicatorView];
    [self.view bringSubviewToFront:activityIndicatorView];
    
    [self.sortingProject fetchVideos:^(NSMutableArray<SOVideo *> *fetchedVideos, NSMutableArray<AVAsset *> *fetchedVideoAssets, NSMutableArray<PFFile *> *thumbnails) {
        self.videoThumbnails = [NSMutableArray arrayWithArray:thumbnails];
        self.videoAssetsArray = [NSMutableArray arrayWithArray:fetchedVideoAssets];
        
        [collectionView reloadData];
        [activityView stopAnimating];
        [activityView removeFromSuperview];
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



#pragma mark - Query videos

//-(void)videoQuery {
//
//    NSMutableArray<SOVideo *> *videosArray = self.sortingProject.videos;
//
////    for (SOVideo *video in self.sortingProject.videos) {
////        [video fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
////
////        }];
////    }
//
//    for (int i=0; i<[videosArray count]; i++) {
//
//
//
//        PFQuery *query = [PFQuery queryWithClassName:@"SOVideo"];
//        [query whereKey:@"objectId" containsString:[videosArray objectAtIndex:i].objectId];
//        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//
//            if (!error) {
//                NSLog(@"video objects %@",objects);
//                for (SOVideo *vid in objects) {
//                    NSLog(@"Current video is: %@", vid.video);
//                    //add video  PFiles to videoFiles array
//                    [self.videoFilesArray addObject:vid];
//                    //
//                }
//                if(self.videoFilesArray.count == self.sortingProject.videos.count){
//
//                    [self resortVideoFilesArray];
//                    [collectionView reloadData];
//
//                    self.videoAssetsArray = [self videoAssestsArray];
//                }
//            }
//
//            else{
//                NSLog(@"Error: %@",error);
//            }
//        }];
//    }
//
//
//}

//- (void)resortVideoFilesArray{
//
//    NSMutableArray <SOVideo *> *sortedArray = [NSMutableArray new];
//    NSMutableArray <PFFile  *> *sortedPFFileThumbnailsArray = [NSMutableArray new];
//
//    for (SOVideo *video in self.sortingProject.videos) {
//
//        for (SOVideo *unsortedVideo in self.videoFilesArray) {
//            if ([unsortedVideo.objectId isEqualToString:video.objectId]) {
//                [sortedArray addObject:unsortedVideo];
//                [sortedPFFileThumbnailsArray addObject:unsortedVideo.thumbnail];
//                break;
//            }
//        }
//
//    }
//    self.videoFilesArray = sortedArray;
//    self.videoThumbnails = sortedPFFileThumbnailsArray;
//}


//method for getting AVAssets array from PFFile array
//-(NSMutableArray<AVAsset * > *)videoAssestsArray
//{
//    NSMutableArray<AVAsset *> *videoAssetsArray = [NSMutableArray new];
//    for (int i=0; i < self.videoFilesArray.count; i++)
//    {
//        SOVideo *currentVideo = self.videoFilesArray[i];
//        AVAsset *videoAsset = [currentVideo assetFromVideoFile];
//        [videoAssetsArray addObject:videoAsset];
//    }
//    return videoAssetsArray;
//}
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
        NSURL *outputURL = session.outputURL;
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
        [collectionView reloadData];
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
}


//-(void)videoThumbnailImages{
//    self.imagesArray = [NSMutableArray new];
//
//    for (SOVideo *video in self.sortingProject.videos) {
//
//        [video.thumbnail getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
//            if (data) {
//
//
//                NSData *dataFromFile = [NSData dataWithData:data];
//                UIImage *image = [UIImage imageWithData:dataFromFile];
//                [self.imagesArray addObject:image];
//
//                if (self.imagesArray.count == self.sortingProject.videos.count) {
//                    [collectionView reloadData];
//                }
//
//            }
//        }];
//    }
//}


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
                  cellForItemAtIndexPath:(NSIndexPath *)anIndexPath{
    
    SOSortingCVC *cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:@"sortingIdentifier"
                                                                    forIndexPath:anIndexPath];
    
    cell.videoImageView.file = nil;
    
    cell.videoImageView.file = self.videoThumbnails[anIndexPath.row];
    cell.videoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [cell.videoImageView loadInBackground];
    
    cell.backgroundColor = [UIColor blackColor];
    
    //  NSLog(@"imagessss %@",[imagesArray objectAtIndex:anIndexPath.row]);
    return cell;
    
}




- (void)collectionView:(UICollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath

{
    if(self.videoAssetsArray[indexPath.row] && self.videoAssetsArray.count != 0){
        
        NSLog (@"indexpath %ld",(long)indexPath.row);
        AVAsset *avAsset = nil;
        AVPlayerItem *avPlayerItem = nil;
        AVPlayer *avPlayer = nil;
        AVPlayerLayer *avPlayerLayer =nil;
        
        if (avPlayer.rate > 0 && !avPlayer.error) {
            [avPlayer pause];
        }
        
        else {
            
            avAsset = self.videoAssetsArray[indexPath.row];
            
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
    
    else
        NSLog(@"weird bug");
    
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
        
        // PFFile *
        
        // NSString *draggedImageName = [self.videoThumbnails objectAtIndex:self.draggedIndex.row];
        
        // draggedImageView.image = [UIImage imageNamed:draggedImageName];
        
        //draggedImageView.image = self.imagesArray[self.draggedIndex.row];
        
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
