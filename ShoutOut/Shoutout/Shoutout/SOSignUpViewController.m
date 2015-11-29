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
#import "SOContactsViewController.h"
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
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(view.center.x, view.center.y, 100, 100)];
    [view addSubview:label];
    
    label.text = @"Registering... This may take a few seconds";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:view];
    
    NSString *username = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    NSString *email = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    NSString *phoneNumber = self.phoneNumberTextField.text;
    
    
    if ((username && username.length) && (password && password.length) && (email && email.length) && ([phoneNumber length] == 10))
    {
        User *oldUser = [User currentUser];
        
        [User logOut];
        
        User *thisUser = [[User alloc]initWithContacts];
        
        thisUser.username = username;
        thisUser.password = password;
        thisUser.email = email;
        thisUser.phoneNumber = phoneNumber;
        
        [thisUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(!error){
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
                
                [[NSUserDefaults standardUserDefaults] setObject:thisUser.username forKey:@"username"];
                [[NSUserDefaults standardUserDefaults] setObject:thisUser.password forKey:@"password"];
                
                
                NSLog(@"Sign up succeded!");
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                
                UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"SOMainNavigationControllerIdentifier"];
                
                [[PFInstallation currentInstallation] setObject:thisUser forKey:@"user"];
                
                [[PFInstallation currentInstallation] saveInBackground];
                
                
                SOCachedObject *cached = [[SOCachedProjects sharedManager].cachedProjects objectForKey:self.projectID];
                
                cached.cachedProject.createdBy = thisUser.username;
                
                [[SOCachedProjects sharedManager].cachedProjects removeObjectForKey:cached.cachedProject.objectId];
                [[SOCachedProjects sharedManager].cachedProjects setObject:cached forKey:cached.cachedProject.objectId];
                
                
                [cached.cachedProject saveInBackground];
                

                
                SOContactsViewController *contactsVC = [storyboard instantiateViewControllerWithIdentifier:@"SOContactsViewControllerID"];
                contactsVC.projectId = self.projectID;
                [self presentViewController:contactsVC animated:YES completion:nil];
                
               // [self dismissViewControllerAnimated:YES completion:^{
                //    [[NSNotificationCenter defaultCenter] postNotificationName:@"SignUpComplete" object:nil];
                    
                //}];
            }else{
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"%@",errorString);
                
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:errorString preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    self.nameTextField.text = @"";
                    [alertController dismissViewControllerAnimated:YES completion:nil];
                }];
                
                [alertController addAction:okAction];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
            
        }];
    }
    else
    {
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
