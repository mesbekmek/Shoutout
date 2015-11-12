//
//  ProjectsViewController.m
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 11/8/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "ProjectsViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSURL+ImageGenerator.h"


const float kVideoLengthMax = 10.0;



@interface ProjectsViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) UIImagePickerController *imagePicker;

@end


@implementation ProjectsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

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
