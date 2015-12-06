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
#import "ProfileViewController.h"
#import "SOSortingViewController.h"
#import <ChameleonFramework/Chameleon.h>
#import "SONotificationsTableViewController.h"
#import "NotificationsTableViewContainerViewController.h"
#import "SOProjectsCollectionViewFlowLayout.h"

const CGFloat aspectRatio = 1.77;

typedef enum eventsType{
    
    MY_EVENTS = 0,
    MY_COLLABORATIONS
    
} EventsType;

@interface SOProjectsViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout,UITextFieldDelegate>
{
    //    IBOutlet UIView *centerView;
    IBOutlet UICollectionView *collectionView;
    EventsType currentEventType;
}

@property (nonatomic) UIImagePickerController *imagePicker;
@property (nonatomic) NSMutableArray <SOProject*> *projectsArray;
@property (nonatomic) NSMutableArray <SOVideo*> *videosArray;
@property (nonatomic) NSMutableArray <PFFile *>*videoThumbnailsArray;
@property (nonatomic) SOProject *project;
@property (nonatomic, assign) CGFloat previousOffset;
@property (nonatomic, assign) NSInteger currentPage;
@property (weak, nonatomic) IBOutlet UIView *underlineBar;
@property (nonatomic) BOOL isAnimating;
@property (nonatomic) BOOL initialFetchOfVideosComplete;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *myEventsCollabsSegmentedControl;
@property (nonatomic) NSString *appColor;

@end

@implementation SOProjectsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.appColor = @"F07179";
    
    self.videoThumbnailsArray = [NSMutableArray new];
    self.plusButton.layer.cornerRadius = 22.5;
    self.plusButton.clipsToBounds = YES;
    [self projectsQuery];
    
    UINib *myNib = [UINib nibWithNibName:@"SOVideoCollectionViewCell" bundle:nil];
    [collectionView registerNib:myNib forCellWithReuseIdentifier:@"VideoCellIdentifier"];
    
    UINib *plusButtonNib = [UINib nibWithNibName:@"SOProjectsAddEventCollectionViewCell" bundle:nil];
    [collectionView registerNib:plusButtonNib forCellWithReuseIdentifier:@"plusCellIdentifier"];
    
    // By turning off clipping, you'll see the prior and next items.
    collectionView.clipsToBounds = NO;
    
    UICollectionViewFlowLayout *myLayout = [[SOProjectsCollectionViewFlowLayout alloc] init];
    
    CGFloat margin = ((self.view.frame.size.width - collectionView.frame.size.width) / 2);
    
    // This assumes that the the collectionView is centered withing its parent view.
    myLayout.itemSize = CGSizeMake(collectionView.frame.size.width + margin, collectionView.frame.size.height);
    
    // A negative margin will shift each item to the left.
    myLayout.minimumLineSpacing = -margin;
    
    myLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    [collectionView setCollectionViewLayout:myLayout];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToProfile) name:@"MoveToProfile" object:nil];
    
    [self projectsQuery];
}

#pragma mark -Navigate to Profile after sign up

-(void)popToProfile{
    
    [self profileButtonTapped:self.profileButton];
    
}
- (IBAction)profileButtonTapped:(UIButton *)sender {
    
    ProfileViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileVC"];
    [self.navigationController pushViewController:profileVC animated:YES];
    
}

- (IBAction)pushToNotifications:(UIButton *)sender {
    
    NotificationsTableViewContainerViewController *notifContainer = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationsSection"];
    [self.navigationController pushViewController:notifContainer animated:YES];
}

#pragma mark - Life Cycle
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [collectionView reloadData];
    [self collectionViewBatchReload];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    //self.navigationController.navigationBarHidden = YES;
    
    
    //UI color stuff
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:self.appColor];
    self.myEventsCollabsSegmentedControl.tintColor = [UIColor colorWithHexString:self.appColor];
//    [[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithHexString:self.appColor]];
//    self.navigationController.navigationBar.backgroundColor = [UIColor redColor];
    [[UINavigationBar appearance] setBackgroundColor:[UIColor redColor]];

    
    

    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"futura-medium" size:25]}];
    self.navigationItem.title = @"Shoutout";
    
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
    if([User currentUser].username !=nil){
        [query whereKey:@"createdBy" equalTo:[User currentUser].username];
        NSLog(@"Current User: %@", [User currentUser].username);
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error) {
                
                if(objects.count == 0)
                {
                    self.initialFetchOfVideosComplete = YES;
                }
                //get an array of projects
                else{
                    self.projectsArray = [[NSMutableArray alloc]initWithArray:objects];
                    NSLog(@"projectsArray %@",self.projectsArray);
                    
                    self.videosArray = [[NSMutableArray alloc]init];
                    //for every project get an array of videos
                    for (SOProject *project in objects)
                    {
                        self.project = project;
                        
                        [self.videosArray addObjectsFromArray:project.videos];
                        if ([self.projectsArray count]==0){
                            collectionView.hidden = YES;
                        }
                    }
                    [self videoQuery];
                    [collectionView reloadData];
                }
                //[self videoThumbnailQuery];
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
    
    CGFloat width = self.view.frame.size.width * 0.8;
    CGFloat height = aspectRatio * width;
    
    
    CGSize mElementSize = CGSizeMake(width, height);
    return mElementSize;
}

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
        return 1;
    }
    return [self.projectsArray count] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)CollectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        SOVideoCVC *plusCell = [CollectionView dequeueReusableCellWithReuseIdentifier:@"VideoCellIdentifier" forIndexPath:indexPath];
        plusCell.videoImageView.file = nil;
        plusCell.videoImageView.image = nil;
        plusCell.videoImageView.frame = plusCell.bounds;
        plusCell.videoImageView.image = [UIImage imageNamed:@"yellowPlus"];
        plusCell.videoImageView.contentMode = UIViewContentModeScaleAspectFit;
        return plusCell;
    }
    else
    {
        SOVideoCVC *cell = [CollectionView dequeueReusableCellWithReuseIdentifier:@"VideoCellIdentifier" forIndexPath:indexPath];
        if (self.projectsArray[indexPath.row - 1].videos[0].thumbnail) {
            
            cell.videoImageView.image = nil;
            cell.videoImageView.file = nil;
            
            cell.videoImageView.file = self.projectsArray[indexPath.row - 1].videos[0].thumbnail;
            
            cell.videoImageView.frame = cell.bounds;
            
            cell.videoImageView.contentMode = UIViewContentModeScaleAspectFit;
            
            [cell.videoImageView loadInBackground];
        }
        if([self.projectsArray count] != 0){
            SOProject *project = self.projectsArray[indexPath.row - 1];
            
            NSString *projectTitle = project.title;
            cell.projectTitle.text = projectTitle;
        }
        return cell;
    } else {
//        UICollectionViewCell *plusCell = [CollectionView dequeueReusableCellWithReuseIdentifier:@"plusCellIdentifier" forIndexPath:IndexPath];
        SOVideoCVC *plusCell = [CollectionView dequeueReusableCellWithReuseIdentifier:@"VideoCellIdentifier" forIndexPath:indexPath];
        plusCell.videoImageView.file = nil;
        plusCell.videoImageView.image = nil;
        plusCell.videoImageView.frame = plusCell.bounds;
        plusCell.videoImageView.image = [UIImage imageNamed:@"plusWatermelon"];
        plusCell.videoImageView.contentMode = UIViewContentModeScaleAspectFit;
        return plusCell;
        
    }
    
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
    if (indexPath.row > 0) {
        if ([self.projectsArray count] !=0) {
            SOSortingViewController *sortingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SOSortingVideoID"];
            sortingVC.sortingProject = self.projectsArray[indexPath.row-1];
            
            //  sortingVC.videoThumbnails =  self.videoThumbnailsArray;
            
            [self.navigationController pushViewController:sortingVC animated:YES];
        }
    } else {
        [self modalCameraPopup];
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
    
    SOProject *project = nil;
    if([[SOCachedProjects sharedManager].cachedProjects objectForKey:@"UUID"])
    {
        NSString *uuid = [[SOCachedProjects sharedManager].cachedProjects objectForKey:@"UUID"];
        project = [[SOProject alloc] initWithUUID:uuid];
    }
    else{
        project = [[SOProject alloc]initWithUUID:[User currentUser].username];
    }
    [project.videos addObject:video];
    self.currentProject = project;
    
    [project saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded)
        {
            NSLog(@"Saved currrent project in background");
            if(!self.projectsArray)
            {
                self.projectsArray = [NSMutableArray new];
            }
            [self.projectsArray insertObject:project atIndex:0];
            self.initialFetchOfVideosComplete = YES;
            [collectionView reloadData];
        }else{
            NSLog(@"Error saving project in background :%@",[error localizedDescription]);
        }
    }];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Event Title" message:@"Please title Event" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.delegate = self;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:okAction];
    
    [picker presentViewController:alert animated:YES completion:nil];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.currentProject.title = finalString;
    [self.currentProject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded)
        {
            NSLog(@"Successfully updated current proj in parse");
        }
        else
        {
            NSLog(@"%@",[error localizedDescription]);
        }
    }];
    return YES;
}

@end
