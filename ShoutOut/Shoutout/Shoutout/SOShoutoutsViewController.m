//
//  SOShoutoutsViewController.m
//  Shoutout
//
//  Created by Varindra Hart on 12/4/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOShoutoutsViewController.h"
#import <ChameleonFramework/Chameleon.h>
#import <Parse/Parse.h>
#import "User.h"
#import "SOVideoCVC.h"
#import "SOShoutout.h"
#import "SOCachedProjects.h"
#import "SOExportHandler.h"
#import "SOShoutoutsCollectionViewFlowLayout.h"
#import "VideoViewController.h"

@interface SOShoutoutsViewController ()< UINavigationControllerDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic) SOShoutout *shoutout;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSMutableArray<SOShoutout *> *shoutoutsArray;
@property (nonatomic, assign) CGFloat previousOffset;
@property (nonatomic, assign) NSInteger currentPage;

@end

const CGFloat aspectRatio2 = 1.77;


@implementation SOShoutoutsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shoutoutsArray = [NSMutableArray<SOShoutout *> new];
    self.shoutout = [[SOShoutout alloc]initShoutout];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    // Do any additional setup after loading the view.
    UINib *myNib = [UINib nibWithNibName:@"SOVideoCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:myNib forCellWithReuseIdentifier:@"VideoCellIdentifier"];
    
    // By turning off clipping, you'll see the prior and next items.
    self.collectionView.clipsToBounds = NO;
    
    UICollectionViewFlowLayout *myLayout = [[SOShoutoutsCollectionViewFlowLayout alloc] init];
    
    CGFloat margin = ((self.view.frame.size.width - self.collectionView.frame.size.width) / 2);
    
    // This assumes that the the collectionView is centered withing its parent view.
    myLayout.itemSize = CGSizeMake(self.collectionView.frame.size.width + margin, self.collectionView.frame.size.height);
    
    // A negative margin will shift each item to the left.
    myLayout.minimumLineSpacing = -margin;
    
    myLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    [self.collectionView setCollectionViewLayout:myLayout];


}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"34A6FF"];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"futura-medium" size:25]}];
    self.navigationItem.title = @"Shoutouts";
    [self fetch];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.collectionView reloadData];
}

- (void)fetch{
    
    [self.shoutout fetchAllCollabs:^(NSMutableArray<SOShoutout *> *shoutoutsCollaborationsArray)
     {
         self.shoutoutsArray = shoutoutsCollaborationsArray;
         [self.collectionView reloadData];
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 20;
}

- (NSInteger)collectionView:(UICollectionView *)aCollectionView
     numberOfItemsInSection:(NSInteger)aSection
{
    return self.shoutoutsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)CollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    SOVideoCVC *cell = [CollectionView dequeueReusableCellWithReuseIdentifier:@"VideoCellIdentifier" forIndexPath:indexPath];
    if (self.shoutoutsArray[indexPath.row].videosArray[0].thumbnail)
    {
        //cell.videoImageView = [[PFImageView alloc]init];
        cell.videoImageView.image = nil;
        cell.videoImageView.file = nil;
        
        cell.videoImageView.file = self.shoutoutsArray[indexPath.row].videosArray[0].thumbnail;
        NSLog(@"Thumbnail : %@", self.shoutoutsArray[indexPath.row].videosArray[0].thumbnail);
        cell.videoImageView.frame = cell.bounds;
        
        cell.videoImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [cell.videoImageView loadInBackground];
    }
    return cell;
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

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VideoViewController *videoVC = [VideoViewController new];
    videoVC.shoutout = self.shoutoutsArray[indexPath.row];
    [self presentViewController:videoVC animated:YES completion:nil];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat width = self.view.frame.size.width * 0.8;
    CGFloat height = aspectRatio2 * width;


    CGSize mElementSize = CGSizeMake(width, height);
    return mElementSize;
}


- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    NSInteger itemsCount = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
    
    UICollectionViewFlowLayout *flowLayout = (id)self.collectionView.collectionViewLayout;
    
    // Imitating paging behaviour
    // Check previous offset and scroll direction
    if ((self.previousOffset > self.collectionView.contentOffset.x) && (velocity.x < 0.0f)) {
        self.currentPage = MAX(self.currentPage - 1, 0);
    } else if ((self.previousOffset < self.collectionView.contentOffset.x) && (velocity.x > 0.0f)) {
        self.currentPage = MIN(self.currentPage + 1, itemsCount - 1);
    }
    
    // Update offset by using item size + spacing
    CGFloat updatedOffset = (flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing) * self.currentPage;
    self.previousOffset = updatedOffset;
    
    return CGPointMake(updatedOffset, proposedContentOffset.y);
}


@end
