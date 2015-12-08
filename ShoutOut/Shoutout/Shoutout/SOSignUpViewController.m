//
//  SOSignUpViewController.m
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 11/11/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOSignUpViewController.h"
#import "ViewController.h"
#import "SOModel.h"
#import "ProfileViewController.h"
#import "SOProjectsViewController.h"
#import "SOCachedObject.h"
#import "SOCachedProjects.h"
#import "SOLoginViewController.h"
#import "SOContactsViewController.h"
#import "SOContactsFriendsViewController.h"

@interface SOSignUpViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;


@end

@implementation SOSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    [self.phoneNumberTextField sizeToFit];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissSignUp) name:@"SOContactsLoaded" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideSignUp) name:@"SetViewToHidden" object:nil];
    
}

-(void)dismissSignUp{
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)hideSignUp{
    [self.view setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.nameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.phoneNumberTextField resignFirstResponder];
}



- (IBAction)joinButtonTapped:(UIButton *)sender {
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
    
    NSString *username = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    NSString *email = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    NSString *phoneNumber = self.phoneNumberTextField.text;
    
    
    if ((username && username.length) && (password && password.length) && (email && email.length) && ([phoneNumber length] == 10))
    {
//        User *oldUser = [User currentUser];
        
        //[User logOut];
        
//        User *thisUser = [[User alloc]initWithContacts];
        User *thisUser = [User user];
        
        thisUser.username = username;
        thisUser.password = password;
        thisUser.email = email;
        thisUser.phoneNumber = phoneNumber;
        thisUser.contacts = [[SOContacts alloc] initWithNewList];
        
        [thisUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(!error){

                NSString *uuidUsername = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
                NSString *uuidPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];

                [[NSUserDefaults standardUserDefaults] setObject:uuidUsername forKey:@"uuidUsername"];
                [[NSUserDefaults standardUserDefaults] setObject:uuidPassword forKey:@"uuidPassword"];

                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
                
                [[NSUserDefaults standardUserDefaults] setObject:thisUser.username forKey:@"username"];
                [[NSUserDefaults standardUserDefaults] setObject:thisUser.password forKey:@"password"];
                
                [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"signedUpAlready"];
                [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"signedIn"];
                
                NSLog(@"Sign up succeded!");
                
                PFQuery *query = [PFQuery queryWithClassName:@"SOProject"];
                NSString *uuid = [[SOCachedProjects sharedManager].cachedProjects objectForKey:@"UUID"];
                [query whereKey:@"createdBy" containsString:uuid];
                
               __block NSMutableArray<SOProject *> *projects = [NSMutableArray<SOProject *> new];

                [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                    if(!error){
                        projects = [NSMutableArray arrayWithArray:objects];
                        
                    }
                }];
                if(projects.count > 0){
                    for(int i = 0; i < projects.count ; i++)
                    {
                        
                            SOProject *currentProject = projects[i];
                            currentProject.createdBy = thisUser.username;
                        for(int i = 0; i < currentProject.videos.count; i++)
                        {
                            SOVideo *currentVideo = currentProject.videos[i];
                            currentVideo.username = thisUser.username;
                        }
                        [currentProject saveInBackground];
                    }
                }
                
                [[PFInstallation currentInstallation] setObject:thisUser forKey:@"user"];
                
                [[PFInstallation currentInstallation] saveInBackground];
                
                
                SOCachedObject *cached = [[SOCachedProjects sharedManager].cachedProjects objectForKey:self.sortingProject.objectId];
                
                cached.cachedProject.createdBy = thisUser.username;
                
                [[SOCachedProjects sharedManager].cachedProjects removeObjectForKey:cached.cachedProject.objectId];
                [[SOCachedProjects sharedManager].cachedProjects setObject:cached forKey:cached.cachedProject.objectId];
                
                
                [cached.cachedProject saveInBackground];
                
                [activityIndicator stopAnimating];
                [activityIndicator removeFromSuperview];
                [activityIndicatorView removeFromSuperview];
                
//                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//                
//                SOContactsViewController *contactsVC = [storyboard instantiateViewControllerWithIdentifier:@"SOContactsViewControllerID"];
//                contactsVC.projectId = self.sortingProject.objectId;
                
//                contactsVC.sortingProject = self.sortingProject;
//                [self presentViewController:contactsVC animated:YES completion:nil];
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                
                SOContactsFriendsViewController *contactsAndFriendsVC = [storyboard instantiateViewControllerWithIdentifier:@"ContactsFriendsID"];
                contactsAndFriendsVC.sortingProject = self.sortingProject;
                [self presentViewController:contactsAndFriendsVC animated:YES completion:nil];
                
            }else{
                [activityIndicator stopAnimating];
                [activityIndicator removeFromSuperview];
                [activityIndicatorView removeFromSuperview];
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"%@",errorString);
                
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:errorString preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault  handler:^(UIAlertAction * _Nonnull action) {
                    [alertController dismissViewControllerAnimated:YES completion:nil];
                }];
                
                [alertController addAction:okAction];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
            
        }];
    }
    else
    {
        [activityIndicator stopAnimating];
        [activityIndicator removeFromSuperview];
        [activityIndicatorView removeFromSuperview];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter proper value for all fields" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}
- (IBAction)cancelButtonTapped:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
