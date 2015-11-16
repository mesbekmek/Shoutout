//
//  SOCreateNewProjectViewController.m
//  Shoutout
//
//  Created by Diana Elezaj on 11/13/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOCreateNewProjectViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>


//const float kVideoLengthMax = 10.0;

@interface SOCreateNewProjectViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;

@end

@implementation SOCreateNewProjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)addNewVideoButtonTapped:(id)sender{
    
    [self setupCamera];
    
}

- (IBAction)done:(id)sender{

        SOProject *project = [[SOProject alloc]initWithTitle:self.titleTextField.text];
        project.description = self.descriptionTextField.text;
    
        [project saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(!error){
                NSLog(@"Saved current PROJECT in background");
            }
         }];
}



# pragma mark - Video camera setup
- (void)setupCamera{
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = [[NSArray alloc]initWithObjects:(NSString *)kUTTypeMovie, nil];
    //self.imagePicker.videoMaximumDuration = kVideoLengthMax;
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
