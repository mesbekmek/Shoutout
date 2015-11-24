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
#import "SOCachedProjects.h"
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

@property (nonatomic) UIImagePickerController *imagePicker;
@property (nonatomic) NSMutableArray <SOProject*> *projectsArray;
@property (nonatomic) NSMutableArray <SOVideo*> *videosArray;
@property (nonatomic) NSMutableArray <PFFile *>*videoThumbnailsArray;
//@property (weak, nonatomic) IBOutlet UITextView *noProjectsTextView;
@property (nonatomic) SOProject *project;
@property (nonatomic, assign) CGFloat previousOffset;
@property (nonatomic, assign) NSInteger currentPage;
@property (weak, nonatomic) IBOutlet UIView *underlineBar;
@property (nonatomic) BOOL isAnimating;
@property (nonatomic) BOOL initialFetchOfVideosComplete;

@end

@implementation SOProjectsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.noProjectsTextView.hidden = YES;
    //    self.noProjectsTextView.text = @"You don't have any projects. \nClick + to create a new one!";
    
    self.videoThumbnailsArray = [NSMutableArray new];
    self.plusButton.layer.cornerRadius = 22.5;
    self.plusButton.clipsToBounds = YES;
    
    [self projectsQuery];
    
    
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
 
    [collectionView reloadData];
    [self collectionViewBatchReload];
}

-(void)videoQuery{
    
    
    NSMutableArray<NSString *> *videoObjectIDArray = [NSMutableArray new];
    NSMutableArray<SOProject *> *correctOrderArray = [NSMutableArray arrayWithArray:[self.projectsArray sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]]];
    self.projectsArray = correctOrderArray;
    for(int i = 0; i < correctOrderArray.count; i++)
    {
        SOProject *project = self.projectsArray[i];
        NSString *videoObjectID = project.videos[0].objectId;
        [videoObjectIDArray addObject:videoObjectID];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"SOVideo"];
    [query whereKey:@"objectId" containedIn:videoObjectIDArray];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            for (SOVideo *vid in objects)
            {
                for(int i=0; i < videoObjectIDArray.count; i++)
                {
                    if([videoObjectIDArray[i] isEqualToString:vid.objectId]){
                        [self.projectsArray[i].videos replaceObjectAtIndex:0 withObject:vid];
                        break;
                    }
                }
            }
            self.initialFetchOfVideosComplete = YES;
            [collectionView reloadData];
            [self collectionViewBatchReload];
        }
        else{
            NSLog(@"Error: %@",[error localizedDescription]);
        }
    }];
}


- (void)projectsQuery{
    
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
                
                [self.videosArray addObjectsFromArray:project.videos];
                if ([self.projectsArray count]==0){
                    collectionView.hidden = YES;
                }
            }
            [self videoQuery];
            [collectionView reloadData];
            //[self videoThumbnailQuery];
        }
        else{
            NSLog(@"Error: %@",error);
        }
    }];
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
    if (!self.initialFetchOfVideosComplete) {
        return 0;
    }
    return [self.projectsArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)CollectionView
                  cellForItemAtIndexPath:(NSIndexPath *)IndexPath
{
    SOVideoCVC *cell = [CollectionView dequeueReusableCellWithReuseIdentifier:@"VideoCellIdentifier" forIndexPath:IndexPath];
    if (self.projectsArray[IndexPath.row].videos[0].thumbnail) {
    
    cell.videoImageView.file = nil;
    
    cell.videoImageView.file = self.projectsArray[IndexPath.row].videos[0].thumbnail;
    
    cell.videoImageView.frame = cell.bounds;
    
    cell.videoImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [cell.videoImageView loadInBackground];
    }
    if([self.projectsArray count] != 0){
        SOProject *project = self.projectsArray[IndexPath.row];
        
        NSString *projectTitle = project.title;
        cell.projectTitle.text = projectTitle;
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
    if ([self.projectsArray count] !=0) {
        SOSortingViewController *sortingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SOSortingVideoID"];
        sortingVC.sortingProject = self.projectsArray[indexPath.row];
        //  sortingVC.videoThumbnails =  self.videoThumbnailsArray;
        
        [self.navigationController pushViewController:sortingVC animated:YES];
    }
}

- (IBAction)changeEventTypeButtonsTapped:(UIButton *)sender{
    
    if (self.isAnimating || (sender.tag ==0 && currentEventType == MY_EVENTS) || (sender.tag == 1 && currentEventType == MY_COLLABORATIONS)) {
        return;
    }
    
    [self animateUnderlineBar];
    
}

- (void)animateUnderlineBar{
    
    if (!self.isAnimating) {
        
        CGFloat newX = currentEventType == MY_EVENTS? self.underlineBar.bounds.size.width : 0;
        CGRect newFrame = CGRectMake(newX, self.underlineBar.frame.origin.y, self.underlineBar.bounds.size.width, self.underlineBar.bounds.size.height);
        
        self.isAnimating = YES;
        
        [UIView animateWithDuration:.25f animations:^{
            
            self.underlineBar.frame = newFrame;
            
        } completion:^(BOOL finished) {
            
            self.isAnimating = NO;
            currentEventType = currentEventType == MY_EVENTS? MY_COLLABORATIONS : MY_EVENTS;
            [collectionView reloadData];
        }];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark Camera
- (IBAction)plusButtonTapped:(UIButton *)sender {
    [self modalCameraPopup];
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
    self.imagePicker.videoMaximumDuration = 10.0;
    self.imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}


# pragma mark - Image Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    SOVideo *video = [[SOVideo alloc]initWithVideoUrl:info [UIImagePickerControllerMediaURL]];
    
    [self.videoThumbnailsArray addObject:video.thumbnail];
    
    NSString *uuid = [[SOCachedProjects sharedManager].cachedProjects objectForKey:@"UUID"];
    
    SOProject *project = [[SOProject alloc]initWithUUID:uuid];
    [project.videos addObject:video];
    self.currentProject = project;
    
    [project saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"Saved currrent project in background");
    }];
    //[self.projectsArray addObject:project];
    [self.projectsArray insertObject:project atIndex:0];
    [collectionView reloadData];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)collectionViewBatchReload{
    
    NSMutableArray *indexPathArray = [NSMutableArray new];
    for(int i =0; i < self.projectsArray.count; i++)
    {
        [indexPathArray addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    [collectionView performBatchUpdates:^{
        [collectionView reloadItemsAtIndexPaths:indexPathArray];
    } completion:^(BOOL finished) {
        NSLog(@"Reloaded");
    }];
    
}

@end
