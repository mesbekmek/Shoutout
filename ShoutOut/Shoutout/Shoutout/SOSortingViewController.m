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
    [self videoQuery];
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

-(void)videoQuery {
    
    NSMutableArray<SOVideo *> *videosArray = self.sortingProject.videos;
    self.videoFilesArray = [[NSMutableArray alloc] init];
    
    for (int i=0; i<[videosArray count]; i++) {
        
        PFQuery *query = [PFQuery queryWithClassName:@"SOVideo"];
        [query whereKey:@"objectId" equalTo:[videosArray objectAtIndex:i].objectId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error) {
                NSLog(@"video objects %@",objects);
                for (SOVideo *vid in objects) {
                    NSLog(@"Current video is: %@", vid.video);
                    //add video  PFiles to videoFiles array
                    [self.videoFilesArray addObject:vid];
                    //
                }
                if(self.videoFilesArray.count == self.sortingProject.videos.count){
                    
                    [self resortVideoFilesArray];
                    [collectionView reloadData];
                    
                    self.videoAssetsArray = [self videoAssestsArray];
                }
            }
            
            else{
                NSLog(@"Error: %@",error);
            }
        }];
    }
    
   
}

- (void)resortVideoFilesArray{
    
    NSMutableArray <SOVideo *> *sortedArray = [NSMutableArray new];
    NSMutableArray <PFFile  *> *sortedPFFileThumbnailsArray = [NSMutableArray new];
    
    for (SOVideo *video in self.sortingProject.videos) {
        
        for (SOVideo *unsortedVideo in self.videoFilesArray) {
            if ([unsortedVideo.objectId isEqualToString:video.objectId]) {
                [sortedArray addObject:unsortedVideo];
                [sortedPFFileThumbnailsArray addObject:unsortedVideo.thumbnail];
                break;
            }
        }
        
    }
    
    self.videoFilesArray = sortedArray;
    self.videoThumbnails = sortedPFFileThumbnailsArray;
}


//method for getting AVAssets array from PFFile array
-(NSMutableArray<AVAsset * > *)videoAssestsArray
{
    NSMutableArray<AVAsset *> *videoAssetsArray = [NSMutableArray new];
    for (int i=0; i < self.videoFilesArray.count; i++)
    {
        SOVideo *currentVideo = self.videoFilesArray[i];
        AVAsset *videoAsset = [currentVideo assetFromVideoFile];
        [videoAssetsArray addObject:videoAsset];
    }
    return videoAssetsArray;
}
#pragma mark - Merging methods
- (IBAction)mergeAndSaveButtonTapped:(UIButton *)sender {
    
    [self mergeVideosInArray:self.videoAssetsArray];
}

-(void)mergeVideosInArray:(NSArray<AVAsset *> *)videosArray{
    int count = (int) [videosArray count];
    AVMutableComposition *mixComposition = nil;
    for(int i = count-1; i >= 0 ; i--)
    {
        AVAsset *currentAsset = videosArray[i];
        if(i>0)
        {
            AVAsset *previousAsset = videosArray[i-1];
            if(currentAsset && previousAsset)
            {
                //Object that holds Video track instances
                mixComposition = [[AVMutableComposition alloc] init];
                // 2 - Video track
                AVMutableCompositionTrack *currentTrack = [mixComposition addMutableTrackWithMediaType:
                                                           AVMediaTypeVideo
                                                                                      preferredTrackID:kCMPersistentTrackID_Invalid];
                [currentTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, currentAsset.duration)
                                      ofTrack:[[currentAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:previousAsset.duration error:nil];
                
                //fetch current Audio Track
                currentTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                [currentTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, currentAsset.duration)
                                      ofTrack:[[currentAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                       atTime:previousAsset.duration error:nil];
            }
        }
        else
        {
            if(currentAsset)//asset is the first video track
            {
                //Object that holds Video track instances
                AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
                // 2 - Video track
                AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                    preferredTrackID:kCMPersistentTrackID_Invalid];
                [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, currentAsset.duration)
                                    ofTrack:[[currentAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
                
                //fetch current Audio Track
                firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, currentAsset.duration)
                                    ofTrack:[[currentAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                     atTime:kCMTimeZero error:nil];
            }
        }
        
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"mergeVideo-%d.mov",arc4random() % 1000]];
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    // 5 - Create exporter with High Quality
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL=url;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self exportDidFinish:exporter];
        });
    }];
}

-(void)exportDidFinish:(AVAssetExportSession*)session {
    if (session.status == AVAssetExportSessionStatusCompleted) {
        NSURL *outputURL = session.outputURL;
        SOVideo *video = [[SOVideo alloc] initWithVideoUrl:outputURL];
        self.sortingProject.shoutout = video;
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
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [collectionView reloadData];
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
    SOVideo *first = self.sortingProject.videos[indexPath.row];
    [self.sortingProject.videos replaceObjectAtIndex:indexPath.row withObject:self.sortingProject.videos[toIndexPath.row]];
    [self.sortingProject.videos replaceObjectAtIndex:toIndexPath.row withObject:first];
    [collectionView reloadData];
    
}

@end
