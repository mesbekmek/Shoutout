//
//  SOSortingViewController.m
//  Shoutout
//
//  Created by Diana Elezaj on 11/12/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOSortingViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SOSortingCVC.h"


@interface SOSortingViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    IBOutlet UIView *centerView;
    IBOutlet UICollectionView *collectionView;
    
    NSMutableArray *imagesArray;
}

@end

@implementation SOSortingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    imagesArray = [[NSMutableArray alloc] initWithObjects:@"video1.jpg", @"video2.jpg", @"video3.jpg", nil];
    
    
    // This nib file has a "live area" defined by an inner view. It's background is necessarily transparent
    UINib *myNib = [UINib nibWithNibName:@"SOSortingCollectionViewCell" bundle:nil];
    
    [collectionView registerNib:myNib forCellWithReuseIdentifier:@"sortingIdentifier"];
    
    // By turning off clipping, you'll see the prior and next items.
    collectionView.clipsToBounds = NO;
    
    UICollectionViewFlowLayout *myLayout = [[UICollectionViewFlowLayout alloc] init];
    
    CGFloat margin = ((self.view.frame.size.width - collectionView.frame.size.width) / 2);
    
    // This assumes that the the collectionView is centered withing its parent view.
    myLayout.itemSize = CGSizeMake(collectionView.frame.size.width + margin, collectionView.frame.size.height);
    
    // A negative margin will shift each item to the left.
    myLayout.minimumLineSpacing = -margin;
    
    myLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    [collectionView setCollectionViewLayout:myLayout];
}









#pragma mark - UICollectionViewDataSourceDelegate



- (NSInteger)collectionView:(UICollectionView *)aCollectionView
     numberOfItemsInSection:(NSInteger)aSection
{
    //    NSUInteger count = 4;
    //
    //    return count;
    return [imagesArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView
                  cellForItemAtIndexPath:(NSIndexPath *)anIndexPath
{
    SOSortingCVC *appropriateCell = [aCollectionView dequeueReusableCellWithReuseIdentifier:@"sortingIdentifier"
                                                                             forIndexPath:anIndexPath];
    NSString *videoImage = [imagesArray objectAtIndex:anIndexPath.row];
    
    NSLog(@"%@",videoImage);
    
    
    UIImage *image = [UIImage imageNamed: videoImage];
    
    
    appropriateCell.videoImageView.image = image;
    
    
    NSLog(@"imagessss %@",[imagesArray objectAtIndex:anIndexPath.row]);
    return appropriateCell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)aCollectionView
                        layout:(UICollectionViewFlowLayout *)aCollectionViewLayout
        insetForSectionAtIndex:(NSInteger)aSection
{
    CGFloat margin = (aCollectionViewLayout.minimumLineSpacing / 2);
    
    // top, left, bottom, right
    UIEdgeInsets myInsets = UIEdgeInsetsMake(0, margin, 0, margin);
    
    return myInsets;
}


//-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    [self performSegueWithIdentifier:@"SortingVideos" sender:self];
//    
//    
//    
//}





@end
