//
//  ProjectsViewController.m
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 11/8/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "ProjectsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSURL+ImageGenerator.h"
#import "SOVideo.h"
#import "SOProject.h"
#import "VideoCVC.h"

const float kVideoLengthMax = 10.0;



@interface ProjectsViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    IBOutlet UIView *centerView;
    IBOutlet UICollectionView *collectionView;
    
    NSMutableArray *imagesArray;
}


@property (nonatomic) UIImagePickerController *imagePicker;

@end


@implementation ProjectsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    [centerView.layer setBorderWidth:5.0];
//    [centerView.layer setBorderColor:[[UIColor colorWithPatternImage:[UIImage imageNamed:@"lines"]] CGColor]];
    
    

    
    
    //    imagesArray =  initWithSectionImages:@[[UIImage imageNamed:@"video1", @"video2", @"video3", @"video4", nil];
    
    
    
    //This array should fetch data from Parse

    imagesArray = [[NSMutableArray alloc] initWithObjects:@"video1.jpg", @"video2.jpg", @"video3.jpg", nil];
    

    // This nib file has a "live area" defined by an inner view. It's background is necessarily transparent
    UINib *myNib = [UINib nibWithNibName:@"VideoCollectionViewCell" bundle:nil];
    
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
        VideoCVC *appropriateCell = [aCollectionView dequeueReusableCellWithReuseIdentifier:@"VideoCellIdentifier"
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
    

    
    
    
    
    
    
    
    // -------- PARSE STUFF -----
//
//    SOVideo *vid = [[SOVideo alloc] init];
//    NSURL *url = [NSURL URLWithString:@"https://www.youtube.com/watch?v=zSQbUV-u5Xo"];
//    
//    [vid initWithVideoUrl:url];
//    
//    [vid saveInBackground];
    
    
//    
//    NSData *data = [@"Working at Parse is great!" dataUsingEncoding:NSUTF8StringEncoding];
//    PFFile *file = [PFFile fileWithName:@"video1.mp4" data:data];
//    
//    [file saveInBackground];
//    
//    
//    PFObject *saveVideo = [PFObject objectWithClassName:@"SOProject"];
//    saveVideo[@"description"] = @"bla bla";
////    saveVideo[@"shoutout"] = file;
//    [saveVideo saveInBackground];
//    
//    
//    
//    NSString *myUser = [PFUser currentUser].username;
//    
//    if (url) {
//        UIImage *thumbnail = url.thumbnailImagePreview;
//        self.thumbnail = [PFFile fileWithData:UIImageJPEGRepresentation(thumbnail, .8f) contentType:@"image/jpeg"];
//        NSData *videoData = [NSData dataWithContentsOfURL:url];
//        self.video = [PFFile fileWithData:videoData contentType:@"video/mp4"];
//        
//        return self;
//        
//    }
//    
//    
    
    
    
    
    
    
    
//    PFQuery *query = [PFQuery queryWithClassName:@"User"];
//    
//    [query whereKey:@"username" equalTo:@"Diana"];
//    
//    NSLog(@"query %@",query);
//    
//    
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            // The find succeeded.
//            NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
//            // Do something with the found objects
//            for (PFObject *object in objects) {
//                NSLog(@"Successfully %@", object.objectId);
//            }
//        } else {
//            // Log details of the failure
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        }
//    }];
    
    
    
    
    
    
    
    
    
    
    
    
    
    //create a query
//    PFQuery *query = [PFQuery queryWithClassName:@"Shoutout"];
    
    //excetute the query
    
//    [query whereKey:@"User" equalTo:@"Diana"];
//    
//    
//    NSLog(@"%@", query);
//
//    
//    
//    
    
    
//    
//    
//    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
//        NSLog(@"%@", objects);
//        
//    }];



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addNewVideoButtonTapped:(id)sender{
 
    [self setupCamera];
    
}

- (IBAction)done:(id)sender{
    
    //Adding details and so on go here, finally we save project in background again
    //if anything was added to it after the video is created;
}



# pragma mark - Video camera setup
- (void)setupCamera{
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = [[NSArray alloc]initWithObjects:(NSString *)kUTTypeMovie, nil];
    self.imagePicker.videoMaximumDuration = kVideoLengthMax;
    self.imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
    
}

# pragma mark - Image Picker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    NSURL *mediaURL = [NSURL URLWithString:info[UIImagePickerControllerMediaURL]];
    SOVideo *video = [[SOVideo alloc]initWithVideoUrl:mediaURL];
    
    //Add video to current projects
    [self.currentProject.videos addObject:video];
    
    //Save current project in background with confirmation block. Alternative
    //is to use saveEventually, allowing saving when connection is available
    [self.currentProject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"Saved current PROJECT in background");
    }];

}



@end
