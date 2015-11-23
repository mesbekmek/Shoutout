//
//  SOProjectsViewController.m
//  Shoutout
//
//  Created by Diana Elezaj on 11/12/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOProjectsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSURL+ImageGenerator.h"
#import "SOVideo.h"
#import "SOProject.h"
#import "SOVideoCVC.h"
#import "SOSortingViewController.h"

const CGFloat aspectRatio = 1.77;

typedef enum eventsType{
    
    MY_EVENTS = 0,
    MY_COLLABORATIONS
    
} EventsType;

@interface SOProjectsViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout>
{
//    IBOutlet UIView *centerView;
    IBOutlet UICollectionView *collectionView;
    EventsType currentEventType;
}

@property (nonatomic) NSMutableArray <SOProject*> *projectsArray;
@property (nonatomic) NSMutableArray <SOVideo*> *videosArray;
@property (nonatomic) NSMutableArray <PFFile *>*videoThumbnailsArray;
//@property (weak, nonatomic) IBOutlet UITextView *noProjectsTextView;
@property (nonatomic) SOProject *project;
@property (nonatomic, assign) CGFloat previousOffset;
@property (nonatomic, assign) NSInteger currentPage;
@property (weak, nonatomic) IBOutlet UIView *underlineBar;
@property (nonatomic) BOOL isAnimating;

@end

@implementation SOProjectsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
//    self.noProjectsTextView.hidden = YES;
//    self.noProjectsTextView.text = @"You don't have any projects. \nClick + to create a new one!";
    
    self.videoThumbnailsArray = [[NSMutableArray alloc]init];
    
    UINib *myNib = [UINib nibWithNibName:@"SOVideoCollectionViewCell" bundle:nil];
    
    [collectionView registerNib:myNib forCellWithReuseIdentifier:@"VideoCellIdentifier"];
    
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
    
//    CGFloat width = self.view.frame.size.width * 0.6;
//    collectionView.frame = CGRectMake(self.view.frame.size.width * 0.2, collectionView.frame.origin.y, width, width * aspectRatio);
//    
    
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    self.noProjectsTextView.hidden = YES;
//    [self projectsQuery];
    [collectionView reloadData];
}



- (void)projectsQuery{
    
    NSLog(@"current user %@", [User currentUser]);
    
    PFQuery *query = [PFQuery queryWithClassName:@"SOProject"];
    [query whereKey:@"createdBy" equalTo:[User currentUser].username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            //get an array of projects
            self.projectsArray = [[NSMutableArray alloc]initWithArray:objects];
            NSLog(@"projectsArray %@",self.projectsArray);
            
            self.videosArray = [[NSMutableArray alloc]init];
            //for every project get an array of videos
            for (SOProject *project in objects) {
                self.project = project;
                
                NSLog(@"objectId %@", project.objectId);
                NSLog(@"object %@",project);
                
                //getting only the first video from each project
                
                
                
                [self.videosArray addObjectsFromArray:project.videos];
                //[self.videosArray addObjectWithArrat:project.videos];
                NSLog(@"videosArray %@", self.videosArray);
                
                
                if ([self.projectsArray count]==0){
                    
//                    self.noProjectsTextView.hidden = NO;
                    collectionView.hidden = YES;
//                    centerView.hidden = YES;
                }
                
                
            }
            [collectionView reloadData];
            [self videoThumbnailQuery];
        }
        else{
            NSLog(@"Error: %@",error);
        }
    }];
    
}


-(void)videoThumbnailQuery {
    
    NSLog(@"yoooo %@", self.videosArray);
    
    for (int i=0; i<[self.videosArray count]; i++) {
        
        PFQuery *query = [PFQuery queryWithClassName:@"SOVideo"];
        [query whereKey:@"objectId" equalTo:[self.videosArray objectAtIndex:i].objectId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error) {
                NSLog(@"video objects %@",objects);
                for (SOVideo *vid in objects) {
                    NSLog(@"video thumbnail %@", vid.thumbnail);
                    
                    //add video thumbnail to thumbnails array
                    [self.videoThumbnailsArray addObject:vid.thumbnail];
                    if(i == self.videosArray.count-1){
                        [collectionView reloadData];
                    }
                    
                }
            }
            
            else{
                NSLog(@"Error: %@",error);
            }
        }];
    }
}


#pragma mark Collection view layout things
// Layout: Set cell size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = self.view.frame.size.width * 0.6;
    CGFloat height = aspectRatio * width;
    
    
    CGSize mElementSize = CGSizeMake(width, height);
    return mElementSize;
}
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    return 0.5;
//}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 20;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    NSInteger itemsCount = [collectionView.dataSource collectionView:collectionView numberOfItemsInSection:0];
    
     UICollectionViewFlowLayout *flowLayout = (id)collectionView.collectionViewLayout;
    
    // Imitating paging behaviour
    // Check previous offset and scroll direction
    if ((self.previousOffset > collectionView.contentOffset.x) && (velocity.x < 0.0f)) {
        self.currentPage = MAX(self.currentPage - 1, 0);
    } else if ((self.previousOffset < collectionView.contentOffset.x) && (velocity.x > 0.0f)) {
        self.currentPage = MIN(self.currentPage + 1, itemsCount - 1);
    }
    
    // Update offset by using item size + spacing
    CGFloat updatedOffset = (flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing) * self.currentPage;
    self.previousOffset = updatedOffset;
    
    return CGPointMake(updatedOffset, proposedContentOffset.y);
}


#pragma mark - UICollectionViewDataSourceDelegate

- (NSInteger)collectionView:(UICollectionView *)aCollectionView
     numberOfItemsInSection:(NSInteger)aSection
{
    
    
    //  for testing purposes
    //    if ([self.videoThumbnailsArray count]==0){
    //        [self.videoThumbnailsArray addObject:@"video1.jpg"];
    //        [self.videoThumbnailsArray addObject:@"video2.jpg"];
    //        [self.videoThumbnailsArray addObject:@"video3.jpg"];
    //
    //    }
    NSLog(@"projects array %lu",(unsigned long)[self.projectsArray count]);
    NSLog(@"videoThumbnailsArray %lu ",(unsigned long)[self.videoThumbnailsArray count]);
    return [self.projectsArray count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)CollectionView
                  cellForItemAtIndexPath:(NSIndexPath *)IndexPath
{
    SOVideoCVC *cell = [CollectionView dequeueReusableCellWithReuseIdentifier:@"VideoCellIdentifier" forIndexPath:IndexPath];
    
       
    cell.videoImageView.file = nil;
    
    
    if ([self.videoThumbnailsArray count] !=0 ) {
        //NSString *videoImage = [self.videoThumbnailsArray objectAtIndex:IndexPath.row];
        // NSLog(@"%@",videoImage);
        // NSLog(@"index %ld",(long)IndexPath.row);
        
        // UIImage *image = [UIImage imageNamed: videoImage];
        
        cell.videoImageView.file = self.videoThumbnailsArray[IndexPath.row];
        
        cell.videoImageView.frame = cell.bounds;
        
        cell.videoImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [cell.videoImageView loadInBackground];
        
        NSLog(@"imagessss %@",[self.videoThumbnailsArray objectAtIndex:IndexPath.row]);
        
    }
    
    SOProject *project = self.projectsArray[IndexPath.row];
    
    NSString *projectTitle = project.title;
    cell.projectTitle.text = projectTitle;
    
    
    
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
    if ([self.projectsArray count] !=0) {
        SOSortingViewController *sortingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SOSortingVideoID"];
        sortingVC.sortingProject = self.projectsArray[indexPath.row];
        NSLog(@"passing %@",sortingVC.sortingProject.title);
        
        sortingVC.videoThumbnails =  self.videoThumbnailsArray;
        
        [self.navigationController pushViewController:sortingVC animated:YES];
    }
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
