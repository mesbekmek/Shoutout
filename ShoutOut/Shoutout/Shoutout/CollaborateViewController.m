//
//  CollaborateViewController.m
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 11/8/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <ParseUI/ParseUI.h>
#import "CollaborateViewController.h"
#import "SOModel.h"

const float kVideoLengthMax1 = 10.0;


@interface CollaborateViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) IBOutlet PFImageView *imageView;
@property (nonatomic) IBOutlet UIView *videoView;
@property (nonatomic) UIImagePickerController *imagePicker;
@property (nonatomic) SOVideo *collaboratorsVideo;

@end

@implementation CollaborateViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)addNewVideoButtonTapped:(id)sender{
    
    [self setupCamera];
    
}

- (IBAction)done:(id)sender{
    
    if (self.collaboratorsVideo) {
        
        PFQuery *query = [PFQuery queryWithClassName:@"SOProject"];
        [query whereKey:@"objectId" equalTo:self.collaborationProject.objectId];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            
            //Add video to project (query to be sure you add to the latest version)
            SOProject *project = [objects firstObject];
            [project.videos addObject:self.collaboratorsVideo];
            
            [project.collaboratorsSentTo removeObject:[User currentUser]];
            [project.collaboratorsReceivedFrom addObject:[User currentUser]];
            
            /* Adding details and so on go here, finally we save project in background again if anything was added to it after the video is created;
             
             Animate spinner to show activity */
            
            [project saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                
                //Stop animating
                
                NSLog(@"Saved current PROJECT in background");
                
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
    }
}

- (void)playBackButtonTapped{
    
    [self playVideo];
    
}

# pragma mark - Video camera setup
- (void)setupCamera{
    
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = [[NSArray alloc]initWithObjects:(NSString *)kUTTypeMovie, nil];
    self.imagePicker.videoMaximumDuration = kVideoLengthMax1;
    self.imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
    
}

# pragma mark - Image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    NSURL *mediaURL = [NSURL URLWithString:info[UIImagePickerControllerMediaURL]];
    self.collaboratorsVideo = [[SOVideo alloc]initWithVideoUrl:mediaURL];
    
    self.imageView.file = self.collaboratorsVideo.thumbnail;
    [self.imageView loadInBackground];
    
    //Save current project in background with confirmation block. Alternative
    //is to use saveEventually, allowing saving when connection is available
    
}

- (void)playVideo{
    
    //Code to play video
}
@end
