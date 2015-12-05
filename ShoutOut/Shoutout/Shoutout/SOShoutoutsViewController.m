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
#import "VideoViewController.h"

@interface SOShoutoutsViewController ()< UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic) SOShoutout *shoutout;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSMutableArray<SOShoutout *> *shoutoutsArray;

@end

@implementation SOShoutoutsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shoutoutsArray = [NSMutableArray<SOShoutout *> new];
    // Do any additional setup after loading the view.
    [self fetch];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"34A6FF"];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"futura-medium" size:25]}];
    self.navigationItem.title = @"Shoutouts";
}

- (void)fetch{
    
    [self.shoutout fetchAllShoutouts:^(NSMutableArray<SOShoutout *> *shoutoutsCollaborationsArray)
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)CollectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    SOVideoCVC *cell = [CollectionView dequeueReusableCellWithReuseIdentifier:@"VideoCellIdentifier" forIndexPath:indexPath];
    if (self.shoutoutsArray[indexPath.row].videosArray[0].thumbnail)
    {
        
        cell.videoImageView.file = nil;
        
        cell.videoImageView.file = self.shoutoutsArray[indexPath.row].videosArray[0].thumbnail;
        
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



@end
