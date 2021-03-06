//
//  SOLoginViewController.m
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 11/11/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOLoginViewController.h"
#import "SOSignUpViewController.h"
#import "SOProjectsViewController.h"
#import "SOModel.h"
#import "SOContactsFriendsViewController.h"

@interface SOLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation SOLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)forgotPasswordButtonTapped:(UIButton *)sender {
}

- (IBAction)signUpButtonTapped:(UIButton *)sender {
    SOSignUpViewController *signUp = [[SOSignUpViewController alloc] init];
    [self presentViewController:signUp animated:YES completion:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (IBAction)signInButtonTapped:(UIButton *)sender {
    NSString *username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ((username && username.length) && (password && password.length))
    {
        [User logOut];
        User *thisUser = [User user];
        
        thisUser.username = username;
        thisUser.password = password;
        
        [User logInWithUsernameInBackground:thisUser.username password:thisUser.password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
                if (!error) {
//                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//                    
//                    UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"SOMainNavigationControllerIdentifier"];

                    [[PFInstallation currentInstallation] setObject:user forKey:@"user"];
                    
                    [[PFInstallation currentInstallation] saveInBackground];


                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"signedIn"];
                    [[NSUserDefaults standardUserDefaults]setObject:@YES forKey:@"signedIn"];


                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];

                    [[NSUserDefaults standardUserDefaults] setObject:thisUser.username forKey:@"username"];
                    [[NSUserDefaults standardUserDefaults] setObject:thisUser.password forKey:@"password"];


                    [[NSNotificationCenter defaultCenter]postNotificationName:@"UserDidLogIn" object:nil];
                    
                    //SOProjectsViewController *vc = (SOProjectsViewController *)nc.topViewController;
                    
//                    SOContactsAndFriendsViewController *contactsVC = [SOContactsAndFriendsViewController new];
//                    contactsVC.sortingProject = self.sortingProject;
//                    [self presentViewController:contactsVC animated:YES completion:nil];

                    
//                    [self presentViewController:nc animated:YES completion:nil];

                    [self.navigationController popViewControllerAnimated:YES];
                    
                } else {
                    NSLog(@"Error: %@", error.localizedDescription);
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Invalid sign in parameters. Please re-enter your username and password." preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        self.usernameTextField.text = @"";
                        self.passwordTextField.text = @"";
                        [alertController dismissViewControllerAnimated:YES completion:nil];
                    }];
                    [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
        }];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Either the username field or the password field or both are either empty, please type them in. " preferredStyle:UIAlertControllerStyleAlert];
        
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
