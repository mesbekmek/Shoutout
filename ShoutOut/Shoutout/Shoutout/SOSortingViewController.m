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

#import "BMAReorderableFlowLayout.h"
#import "UICollectionView+BMADecorators.h"


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
UINavigationControllerDelegate,
BMAReorderableDelegateFlowLayout,
UICollectionViewDataSource
>
{
    IBOutlet UICollectionView *collectionView;
    
    NSMutableArray *imagesArray;
}
@property (weak, nonatomic) IBOutlet UIView *videoPlayingView;
@property (nonatomic) NSIndexPath *draggedIndex;

@end

@implementation SOSortingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    imagesArray = [[NSMutableArray alloc] initWithObjects:@"video1.jpg", @"video2.jpg", @"video3.jpg", nil];
    
    UINib *myNib = [UINib nibWithNibName:@"SOSortingCollectionViewCell" bundle:nil];
    
    [collectionView registerNib:myNib forCellWithReuseIdentifier:@"sortingIdentifier"];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
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


- (NSInteger)collectionView:(UICollectionView *)aCollectionView
     numberOfItemsInSection:(NSInteger)aSection
{
    
    NSLog(@"count %lu",(unsigned long)[imagesArray count]);
    return [imagesArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView
                  cellForItemAtIndexPath:(NSIndexPath *)anIndexPath
{
    SOSortingCVC *cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:@"sortingIdentifier"
                                                                    forIndexPath:anIndexPath];
    NSString *videoImage = [imagesArray objectAtIndex:anIndexPath.row];
    
    UIImage *image = [UIImage imageNamed: videoImage];
    
    cell.videoImageView.image = image;
    cell.backgroundColor = [UIColor blackColor];
    
    NSLog(@"imagessss %@",[imagesArray objectAtIndex:anIndexPath.row]);
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
        UIImageView *draggedImageView = [[UIImageView alloc] initWithFrame:draggedView.bounds];
        draggedImageView.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
        
        [draggedView addSubview:draggedImageView];
        NSString *draggedImageName = [imagesArray objectAtIndex:self.draggedIndex.row];
        draggedImageView.image = [UIImage imageNamed:draggedImageName];

    };
}

- (BMAReorderingAnimationBlock)animationForDragEndedInCollectionView:(UICollectionView *)acollectionView layout:(UICollectionViewLayout *)collectionViewLayout {
    return ^(UICollectionViewCell *draggedView){
        draggedView.transform = CGAffineTransformIdentity;
        
        [acollectionView bma_overlayView].alpha = 0;
    };
}

- (void)collectionView:(UICollectionView *)collectionView didMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath {
    [imagesArray bma_moveItemAtIndex:(NSUInteger)indexPath.item toIndex:(NSUInteger)toIndexPath.item];
}

@end
