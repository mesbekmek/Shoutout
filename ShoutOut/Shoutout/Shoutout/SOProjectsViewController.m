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


@interface SOProjectsViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    IBOutlet UIView *centerView;
    IBOutlet UICollectionView *collectionView;
    
 }

@property (nonatomic) NSMutableArray <SOProject*> *projectsArray;
@property (nonatomic) NSMutableArray <SOVideo*> *videosArray;
@property (nonatomic) NSMutableArray *videoThumbnailsArray;
@property (weak, nonatomic) IBOutlet UITextView *noProjectsTextView;


@end

@implementation SOProjectsViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.noProjectsTextView.hidden = YES;
    self.noProjectsTextView.text = @"You don't have any projects. \nClick + to create a new one!";
    
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
 
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.noProjectsTextView.hidden = YES;
    
    if ([self.videoThumbnailsArray count]==0){
        self.noProjectsTextView.hidden = NO;
        collectionView.hidden = YES;
        centerView.hidden = YES;
    }
    [self projectsQuery];
 }



- (void)projectsQuery{
    
    NSLog(@"current user %@", [User currentUser]);
    
    PFQuery *query = [PFQuery queryWithClassName:@"SOProject"];
    [query whereKey:@"createdBy" equalTo:[User currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            //get an array of projects
            self.projectsArray = [[NSMutableArray alloc]initWithArray:objects];
            NSLog(@"projectsArray %@",self.projectsArray);
            
            self.videosArray = [[NSMutableArray alloc]init];
            //for every project get an array of videos
            for (SOProject *project in objects) {
                NSLog(@"objectId %@", project.objectId);
                NSLog(@"object %@",project);
                
                //getting only the first video from each project
                [self.videosArray addObject: [project.videos objectAtIndex:0] ];
                NSLog(@"videosArray %@", self.videosArray);

             }
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
    [query whereKey:@"objectId" equalTo:[self.videosArray objectAtIndex:i]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        if (!error) {
            NSLog(@"video objects %@",objects);
            for (SOVideo *vid in objects) {
                NSLog(@"video thumbnail %@", vid.thumbnail);
                
                //add video thumbnail to thumbnails array
                [self.videoThumbnailsArray addObject:vid.thumbnail];
                 
                 }
        }
        
        else{
            NSLog(@"Error: %@",error);
        }
    }];
    }
}





#pragma mark - UICollectionViewDataSourceDelegate

- (NSInteger)collectionView:(UICollectionView *)aCollectionView
     numberOfItemsInSection:(NSInteger)aSection
{
    
    
    //for testing purposes
    if ([self.videoThumbnailsArray count]==0){
        [self.videoThumbnailsArray addObject:@"video1.jpg"];
        [self.videoThumbnailsArray addObject:@"video2.jpg"];
        [self.videoThumbnailsArray addObject:@"video3.jpg"];

    }
    return [self.videoThumbnailsArray count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)CollectionView
                  cellForItemAtIndexPath:(NSIndexPath *)IndexPath
{
    SOVideoCVC *cell = [CollectionView dequeueReusableCellWithReuseIdentifier:@"VideoCellIdentifier" forIndexPath:IndexPath];
    
    NSString *videoImage = [self.videoThumbnailsArray objectAtIndex:IndexPath.row];
    NSLog(@"%@",videoImage);
    NSLog(@"index %ld",(long)IndexPath.row);
    
    UIImage *image = [UIImage imageNamed: videoImage];
    
    cell.videoImageView.image = image;
    
    NSLog(@"imagessss %@",[self.videoThumbnailsArray objectAtIndex:IndexPath.row]);
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
    
    [self performSegueWithIdentifier:@"SortingVideos" sender:self];
    
    
    if ([self.projectsArray count] !=0) {
    SOSortingViewController *sortingVC;
        
    sortingVC.sortingProject = self.projectsArray[indexPath.row];
    
    [self.navigationController pushViewController:sortingVC animated:YES];
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
 }

@end
