//
//  SOSortingViewController.m
//  Shoutout
//
//  Created by Diana Elezaj on 11/12/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOSortingViewController.h"
#import <AVFoundation/AVFoundation.h>
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
#import "SOCachedObject.h"
#import "SOSignUpViewController.h"
#import "SOLoginViewController.h"
#import "FullScreenMergeViewController.h"
#import "VideoViewController.h"
#import "SOCameraOverlay.h"
#import "SOCachedProjects.h"
#import "SOContactsAndFriendsViewController.h"
#import "SOContactsViewController.h"
#import "SOExportHandler.h"
#import "SOShareViewController.h"
const float kVideoLengthMax2 = 10.0;
const float cellspacing = 10.0;


NS_ENUM(NSInteger, ProviderEditingState)
{
    ProviderEditStateNormal,
    ProviderEditStateDelete
};

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
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ArrayReorderedMustReloadData" object:[NSNumber numberWithInteger:toIndex]];
    
    
}
@end
@interface SOSortingViewController ()
<
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
BMAReorderableDelegateFlowLayout,
UICollectionViewDataSource,
UIGestureRecognizerDelegate
>
{
    IBOutlet UICollectionView *collectionView;
}
@property (weak, nonatomic) IBOutlet UIView *videoPlayingView;

@property (nonatomic) NSURL *videoURL;
@property (nonatomic) BOOL playStop;

@property (nonatomic) NSIndexPath *draggedIndex;

@property (nonatomic) NSMutableArray <UIImage *>*imagesArray;

@property (nonatomic) UIImagePickerController *imagePicker;

@property (nonatomic) NSMutableArray<SOVideo *> *videoFilesArray;

@property (nonatomic) NSMutableArray<AVAsset *> *videoAssetsArray;

@property (nonatomic) AVPlayer *avPlayer;

@property (nonatomic) AVPlayerItem *avPlayerItem;

@property (nonatomic) AVPlayerLayer *avPlayerLayer;

@property (nonatomic) BOOL doneFetching;
@property (weak, nonatomic) IBOutlet UIButton *videoPlayingViewCancelButton;

@property (nonatomic) BOOL hasRespondedToSignUp;

@property (nonatomic) UIView *dropDownPlayerView;

@property (nonatomic) SOCameraOverlay *cameraOverlay;
@property (assign) enum ProviderEditingState currentEditState;
@property (nonatomic) UIBarButtonItem *editDoneButton;
@property (nonatomic) NSMutableArray *collaboratorUsernameArray;


@end

@implementation SOSortingViewController

#pragma mark - Life cycle methods

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.playStop = YES;

    self.videoAssetsArray = [NSMutableArray new];
    self.videoFilesArray = [NSMutableArray new];
    self.videoThumbnails = [NSMutableArray new];
    self.collaboratorUsernameArray = [NSMutableArray new];
    
    
    self.videoPlayingViewCancelButton.hidden = YES;
    
    UINib *myNib = [UINib nibWithNibName:@"SOSortingCollectionViewCell" bundle:nil];
    
    [collectionView registerNib:myNib forCellWithReuseIdentifier:@"sortingIdentifier"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload:) name:@"ArrayReorderedMustReloadData" object:nil];
    NSLog(@"sorting proj %@",self.sortingProject.objectId);
    [self fetch];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToProfile) name:@"SignUpComplete" object:nil];
    
    [self.editDoneButton setTitle:@"Diiiiii"];

    self.editDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                           style:UIBarButtonItemStyleDone
                                                          target:self
                                                          action:@selector(editDoneButtonTapped)];
    
    self.navigationItem.rightBarButtonItem = self.editDoneButton;
}

-(void)popToProfile
{
    self.hasRespondedToSignUp = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

#pragma mark - Query block called
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    self.tabBarController.hidesBottomBarWhenPushed = YES;
    self.tabBarController.tabBar.hidden = YES;

    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    [collectionView reloadData];
    
    if (self.videoThumbnails.count > 0) {
        
        [self collectionViewBatchReload];
    }
}

-(void)fetch{
    UIView *activityIndicatorView = [[UIView alloc] initWithFrame:self.view.bounds];
    UIActivityIndicatorView *activityIndicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    activityIndicator.center= activityIndicatorView.center;
    activityIndicator.color = [UIColor blackColor];
    activityIndicatorView.backgroundColor = [UIColor whiteColor];
    activityIndicatorView.alpha = 0.6;
    
    [activityIndicator startAnimating];
    [activityIndicatorView addSubview:activityIndicator];
    [self.view addSubview:activityIndicatorView];
    [self.view bringSubviewToFront:activityIndicatorView];
    if (![SOCachedProjects sharedManager].cachedProjects[self.sortingProject.objectId]) {
        
        [self.sortingProject fetchVideos:^(NSMutableArray<SOVideo *> *fetchedVideos, NSMutableArray<AVAsset *> *fetchedVideoAssets,NSMutableArray *usernames , NSMutableArray<PFFile *> *thumbnails) {
            
            self.videoThumbnails = [NSMutableArray arrayWithArray:thumbnails];
            self.videoAssetsArray = [NSMutableArray arrayWithArray:fetchedVideoAssets];
            self.collaboratorUsernameArray = [NSMutableArray arrayWithArray:usernames];
            NSLog(@"VIDEO THUMBNAILS ARRAY: %@",self.videoThumbnails);
            
            self.doneFetching = YES;
            [collectionView reloadData];
            [self collectionViewBatchReload];
            [activityIndicator stopAnimating];
            [activityIndicator removeFromSuperview];
            [activityIndicatorView removeFromSuperview];
        }];
    }else{
        [self.sortingProject getNewVideosIfNeeded:^(NSMutableArray<SOVideo *> *fetchedVideos,                              NSMutableArray<AVAsset *> *avAssets, NSMutableArray *usernames, NSMutableArray<PFFile *> *allThumbnails) {
            self.videoThumbnails = allThumbnails;
            self.videoAssetsArray = avAssets;
            self.collaboratorUsernameArray = usernames;
            self.doneFetching = YES;
            [collectionView reloadData];
            [self collectionViewBatchReload];
            [activityIndicator stopAnimating];
            [activityIndicator removeFromSuperview];
            [activityIndicatorView removeFromSuperview];
        }];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [self.sortingProject reindexVideos];
    
    [self.sortingProject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
    }];
    
    SOCachedObject *currentlyCached = [SOCachedProjects sharedManager].cachedProjects[self.sortingProject.objectId];
    currentlyCached.cachedProject = self.sortingProject;
    currentlyCached.avassetsArray = self.videoAssetsArray;
    currentlyCached.thumbnailsArray = self.videoThumbnails;
    
    [[SOCachedProjects sharedManager].cachedProjects removeObjectForKey:self.sortingProject.objectId];
    [[SOCachedProjects sharedManager].cachedProjects setObject:currentlyCached forKey:self.sortingProject.objectId];
    
    if(self.hasRespondedToSignUp){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MoveToProfile" object:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)reload:(NSNotification *)notif{
    
    NSNumber *number = notif.object;
    NSInteger numb = [number integerValue];
    
    if(numb == 0 || numb == 1|| numb == 2){
        if (self.videoThumbnails.count>5) {
            [collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0], [NSIndexPath indexPathForRow:4 inSection:0]]];
        }
    }
}
#pragma mark - video playing method

- (IBAction)cancelButtonTapped:(UIButton *)sender {
    self.navigationController.navigationBar.hidden = NO;
    self.videoPlayingViewCancelButton.hidden = YES;
    
    self.videoPlayingView.frame = CGRectMake(0, 68, self.view.frame.size.width, self.view.frame.size.height - collectionView.frame.size.height);
    
    [self.avPlayerLayer removeFromSuperlayer];
    self.avPlayerLayer =nil;
    self.avPlayerItem = nil;
    self.avPlayer = nil;
}


#pragma mark - Invite-Preview-Share


- (IBAction)inviteButtonTapped:(UIButton *)sender {
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"signedUpAlready"])
    {
        SOContactsAndFriendsViewController *contactsAndFriendsVC = [[SOContactsAndFriendsViewController alloc] init];
        contactsAndFriendsVC.sortingProject = self.sortingProject;
        [self presentViewController:contactsAndFriendsVC animated:YES completion:nil];
        
    }
    else
    {
        SOSignUpViewController *signUpViewController = [SOSignUpViewController new];
        signUpViewController.sortingProject = self.sortingProject;
        
        [self presentViewController:signUpViewController animated:YES completion:nil];
    }
}

- (IBAction)previewButtonTapped:(UIButton *)sender {
    [self mergeVideosInArray:self.videoAssetsArray];
}

- (IBAction)shareButtonTapped:(UIButton *)sender{
    
    UIView *activityIndicatorView = [[UIView alloc] initWithFrame:self.view.bounds];
    UIActivityIndicatorView *activityIndicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    activityIndicator.center= activityIndicatorView.center;
    activityIndicator.color = [UIColor blackColor];
    activityIndicatorView.backgroundColor = [UIColor whiteColor];
    activityIndicatorView.alpha = 0.6;
    
    [activityIndicator startAnimating];
    [activityIndicatorView addSubview:activityIndicator];
    [self.view addSubview:activityIndicatorView];
    [self.view bringSubviewToFront:activityIndicatorView];
    
    SOExportHandler *exportHandler = [[SOExportHandler alloc]init];
    AVMutableComposition *mutableComp = [exportHandler mergeVideosFrom:self.videoAssetsArray];
    [exportHandler exportMixComposition:mutableComp completion:^(NSURL *url, BOOL success) {
        if (success) {
            SOVideo *shoutout = [[SOVideo alloc]initWithVideoUrl:url];
            [shoutout saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                NSString *passedUrl = shoutout.video.url;
                [activityIndicator stopAnimating];
                [activityIndicator removeFromSuperview];
                [activityIndicatorView removeFromSuperview];
                [self segueToShareViewControllerWithUrl:passedUrl];
            }];
        }
        else{
            
            NSLog(@"Unsuccessful, must troubleshoot");
            [activityIndicator stopAnimating];
            [activityIndicator removeFromSuperview];
            [activityIndicatorView removeFromSuperview];
        }
    }];
  
}

-(void)mergeVideosInArray:(NSMutableArray<AVAsset *> *)videosArray{
    
    [self.avPlayerLayer removeFromSuperlayer];
    self.avPlayerLayer =nil;
    self.avPlayerItem = nil;
    self.avPlayer = nil;
    
    SOExportHandler *exportHandler = [SOExportHandler new];
    AVPlayerItem * pi = [exportHandler playerItemFromVideosArray:videosArray];
    
    AVPlayer *player = [AVPlayer playerWithPlayerItem:pi];
    
    VideoViewController *videoVC = [VideoViewController new];
    videoVC.avPlayer = player;
    [self presentViewController:videoVC animated:YES completion:nil];
    
    //AVPlayerLayer *avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:player];
    
}

- (void)segueToShareViewControllerWithUrl:(NSString *)sharedUrl{
    
    SOShareViewController *shareVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
    shareVC.shareUrl = sharedUrl;
    [self presentViewController:shareVC animated:YES completion:nil];
    
}


# pragma mark - Video camera setup

- (void)setupCamera{
    
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = [[NSArray alloc]initWithObjects:(NSString *)kUTTypeMovie, nil];
    self.imagePicker.videoMaximumDuration = kVideoLengthMax2;
    self.imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    self.cameraOverlay = [[SOCameraOverlay alloc]initFromNib];
    self.cameraOverlay.frame = CGRectMake(0, 0, self.imagePicker.view.bounds.size.width, self.imagePicker.view.bounds.size.height - 60);
    self.imagePicker.cameraOverlayView = self.cameraOverlay;
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
    
}

# pragma mark - Image Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    SOVideo *video = [[SOVideo alloc]initWithVideoUrl:info [UIImagePickerControllerMediaURL]];
    video.index = self.sortingProject.videos.count;
    if ([self.cameraOverlay hasText]) {
        video.details = self.cameraOverlay.tagTextField.text;
    }
    
    [video saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self viewWillAppear:YES];
    }];
    
    self.videoThumbnails  = [NSMutableArray arrayWithArray:self.videoThumbnails];
    [self.videoThumbnails addObject:video.thumbnail];
    
    [self.videoAssetsArray addObject:[AVAsset assetWithURL:info[UIImagePickerControllerMediaURL]]];
    NSLog(@"sorting proj %@",self.sortingProject.objectId);
    
    [self.sortingProject.videos addObject:video];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}


#pragma mark - UICollectionViewDataSourceDelegate

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, cellspacing, 0, cellspacing);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat cellSpace = (screenWidth - cellspacing*4) / 3 ;
    CGFloat cellsize = cellSpace ;
    
    return CGSizeMake(cellsize, cellsize*4.0/3.0);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return cellspacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return cellspacing;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)aCollectionView
     numberOfItemsInSection:(NSInteger)aSection{
    if(!self.doneFetching){
        return 0;
    }
    return self.videoThumbnails.count+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 0)
    {
        SOSortingCVC *cell2 = [aCollectionView dequeueReusableCellWithReuseIdentifier:@"sortingIdentifier" forIndexPath:indexPath];
    
        cell2.deleteItemButton.hidden = YES;
        cell2.videoImageView.image = nil;
        cell2.videoImageView.contentMode = UIViewContentModeScaleAspectFill;
        cell2.videoImageView.image = [UIImage imageNamed: @"pinkPlus" ];
        cell2.collaboratorUsernameLabel.hidden = YES;
        return cell2;
    }
    
    else {
        SOSortingCVC *cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:@"sortingIdentifier" forIndexPath:indexPath];
        
        cell.deleteItemButton.tag = indexPath.row;
        
        if(self.currentEditState == ProviderEditStateNormal)
        {
            cell.deleteItemButton.hidden = YES;
        }
        else
        {
        cell.deleteItemButton.hidden = NO;
        }
        
        cell.videoImageView.file = nil;
        cell.videoImageView.image = nil;
        cell.videoImageView.file = self.videoThumbnails[indexPath.row-1];
        cell.videoImageView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.videoImageView loadInBackground];
        cell.collaboratorUsernameLabel.hidden = NO;
        cell.collaboratorUsernameLabel.text = self.collaboratorUsernameArray[indexPath.row-1];

        cell.backgroundColor = [UIColor clearColor];
        
        [cell.deleteItemButton addTarget:self action:@selector(deleteVideoAlertView:) forControlEvents:UIControlEventTouchUpInside];

        return cell;
    }
}

- (void)collectionView:(UICollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 )
    {
        [self setupCamera];
    }
    
    else {
        if (self.avPlayerLayer) {
        [self.avPlayerLayer removeFromSuperlayer];
        }
        
        AVAsset *avAsset = nil;
        self.avPlayerLayer =nil;
        self.avPlayerItem = nil;
        self.avPlayer = nil;
        
        if ( self.avPlayer.rate !=0 && !self.avPlayer.error) {
            self.avPlayer.rate = 0.0;
        }
        
        avAsset = self.videoAssetsArray[indexPath.row-1];
        
        self.avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
        
        self.avPlayer = [[AVPlayer alloc]initWithPlayerItem:self.avPlayerItem];
        
        self.avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
        
        [self.avPlayerLayer setFrame:self.videoPlayingView.frame];
        
        self.avPlayerLayer.frame = self.videoPlayingView.bounds;
        
        [self.videoPlayingView.layer addSublayer:self.avPlayerLayer];
        
        [self.avPlayer seekToTime:kCMTimeZero];
        [self.avPlayer play];
        
    }
    [collectionView reloadData];
}

#pragma mark -- Edit Done Button

//- (IBAction)editDoneButtonTapped:(UIButton *)sender {
-(void) editDoneButtonTapped {
    if (self.currentEditState == ProviderEditStateNormal)
    {
      
        self.navigationItem.rightBarButtonItem.title = @"Done";

        self.currentEditState = ProviderEditStateDelete;
        for(SOSortingCVC *cell in collectionView.visibleCells)
        {
            NSIndexPath *indexPath = [collectionView indexPathForCell:cell];
            if(indexPath.row == 0) {
                //hide x button for plus button cell
                [cell.deleteItemButton setHidden: YES];
            }
            else
                [cell.deleteItemButton setHidden:NO];
        }
    }
    else
    {
        SOSortingCVC *cell;
        
        cell.deleteItemButton.hidden = NO;
        self.navigationItem.rightBarButtonItem.title = @"Edit";

        self.currentEditState = ProviderEditStateNormal;
        [collectionView reloadData];
    }
}

- (void)deleteVideo: (UIButton *)sender
{
    long index;
    index = (sender.tag-1);
    
     [self.videoThumbnails removeObjectAtIndex:index];
    [self.videoAssetsArray removeObjectAtIndex:index];

    NSLog(@"count %lu", (unsigned long)self.videoThumbnails.count);
    NSLog(@"index %ld",index);
    NSLog(@"objectttt %@", [self.videoThumbnails objectAtIndex:index]);

    
//    [[sender.tag-1] deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//            [self loadObjects];
//        }
//    }];
    
     [collectionView reloadData];
    NSLog(@"count %lu", (unsigned long)self.videoThumbnails.count);

}


-(void) deleteVideoAlertView: (UIButton *)sender{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Delete this video" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        [self deleteVideo:sender];
    }]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}


#pragma mark - Reorderable layout

- (BOOL)collectionView:(UICollectionView *)collectionView canDragItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return NO;
    }
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath {
    if (toIndexPath.row == 0 ) {
        return NO;
    }
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
        
        draggedImageView.file = self.videoThumbnails[self.draggedIndex.row-1];
        [draggedImageView loadInBackground];
        draggedImageView.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
        
        [draggedView addSubview:draggedImageView];
    };
}

- (BMAReorderingAnimationBlock)animationForDragEndedInCollectionView:(UICollectionView *)acollectionView layout:(UICollectionViewLayout *)collectionViewLayout {
    return ^(UICollectionViewCell *draggedView){
        draggedView.transform = CGAffineTransformIdentity;
        
        [acollectionView bma_overlayView].alpha = 0;
    };
}

- (void)collectionView:(UICollectionView *)acollectionView didMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    [self.videoThumbnails bma_moveItemAtIndex:(NSUInteger)indexPath.item-1 toIndex:(NSUInteger)toIndexPath.item-1];
    
    [self.videoAssetsArray bma_moveItemAtIndex:(NSUInteger)indexPath.item-1 toIndex:(NSUInteger)toIndexPath.item-1];
    
    SOVideo *first = self.sortingProject.videos[indexPath.row-1];
    [self.sortingProject.videos replaceObjectAtIndex:indexPath.row-1 withObject:self.sortingProject.videos[toIndexPath.row-1]];
    [self.sortingProject.videos replaceObjectAtIndex:toIndexPath.row-1 withObject:first];
    [collectionView reloadData];
}

-(void)collectionViewBatchReload{
    
    NSMutableArray *indexPathArray = [NSMutableArray new];
    for(int i =1; i <=self.videoThumbnails.count; i++)
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