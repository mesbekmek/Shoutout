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

@end

@implementation SOSortingViewController

#pragma mark - Life cycle methods

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@"passed %@",self.sortingProject.title);
    
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(modalCameraPopup)];
    
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


- (void)viewDidAppear:(BOOL)animated{
    
    [collectionView reloadData];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [self.sortingProject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"Saved new order of videos, assuming there is a new order");
    }];
    
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


-(void)videoThumbnailImages{
    self.imagesArray = [NSMutableArray new];
    
    for (SOVideo *video in self.sortingProject.videos) {
        
        [video.thumbnail getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            if (data) {
                
                
                NSData *dataFromFile = [NSData dataWithData:data];
                UIImage *image = [UIImage imageWithData:dataFromFile];
                [self.imagesArray addObject:image];
                
                if (self.imagesArray.count == self.sortingProject.videos.count) {
                    [collectionView reloadData];
                }
                
            }
        }];
    }
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(120, 120);
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
    
    return [self.sortingProject.videos count];
    
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
