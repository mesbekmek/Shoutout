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

@interface SOSignUpViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation SOSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.nameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (IBAction)joinButtonTapped:(UIButton *)sender {
    NSString *username = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *email = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ((username && username.length) && (password && password.length) && (email && email.length))
    {
        User *thisUser = [[User alloc]initWithContacts];
        
        thisUser.username = username;
        thisUser.password = password;
        thisUser.email = email;
        
        [thisUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(!error){
                NSLog(@"Sign up succeded!");
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                
                UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"SOMainNavigationControllerID"];
                
                ViewController *vc = (ViewController *)nc.topViewController;
                [self presentViewController:nc animated:YES completion:nil];
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
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter a value for all fields" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
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
