//
//  SOSettingsViewController.m
//  Shoutout
//
//  Created by Varindra Hart on 12/6/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOSettingsViewController.h"
#import "User.h"
#import "SOLoginViewController.h"
#import <SSKeychain/SSKeychain.h>
#import <ChameleonFramework/Chameleon.h>

@interface SOSettingsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *signedInAs;
@property (nonatomic, weak) IBOutlet UIButton *logInLogOut;
@property (nonatomic) BOOL signedInStatus;
@property (nonatomic) UIView *activityView;

@end

@implementation SOSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"F07179"];

    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"futura-medium" size:25]}];

    self.navigationItem.title = @"Settings";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissViewControllerAnimated:completion:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    [self setup];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion{

    [super dismissViewControllerAnimated:YES completion:nil];

}

- (void)setup{

    self.signedInStatus = [[[NSUserDefaults standardUserDefaults] objectForKey:@"signedIn"] boolValue];

    if (self.signedInStatus) {
        [self.logInLogOut setTitle:@"Logout" forState:UIControlStateNormal];
        self.signedInAs.text = [NSString stringWithFormat:@"Signed in as: %@", [User currentUser].username];
    }
    else{
        [self.logInLogOut setTitle:@"Log In!" forState:UIControlStateNormal];
        self.signedInAs.text = [NSString stringWithFormat:@"Not signed in"];
    }

}

- (IBAction)logInLogOut:(id)sender{

    if (self.signedInStatus) {

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Logout" message:@"Are you sure you want to logout? You will have to login next time to enable all of Shoutout's awesome features" preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Logout Anyways" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self userConfirmsLogout];
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:action];
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"Nevermind" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:actionOK];
        [self presentViewController:alert animated:YES completion:nil];

    }
    else{

        SOLoginViewController *loginVC = [[SOLoginViewController alloc]initWithNibName:@"SOLoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginVC animated:YES];

    }
}

- (void)setupActivityIndicator{

    if (!self.activityView) {
        self.activityView = [[UIView alloc] initWithFrame:self.view.bounds];
        [self.activityView setBackgroundColor:[UIColor whiteColor]];
        self.activityView.alpha = .6f;

        UIActivityIndicatorView *activityIndicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];

        activityIndicator.center= self.activityView.center;
        activityIndicator.color = [UIColor blackColor];

        [activityIndicator startAnimating];
        [self.activityView addSubview:activityIndicator];
        [self.view addSubview:self.activityView];
        [self.view bringSubviewToFront:activityIndicator];

    }


}

- (void)userConfirmsLogout{

    User *tempUser = [User user];
    tempUser.username = [[NSUserDefaults standardUserDefaults]objectForKey:@"uuidUsername"];
    tempUser.password = [[NSUserDefaults standardUserDefaults]objectForKey:@"uuidPassword"];

    [self setupActivityIndicator];

    [User logInWithUsernameInBackground:tempUser.username password:tempUser.password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        
        if (!error) {


            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
            [[NSUserDefaults standardUserDefaults] setObject:tempUser.username  forKey:@"username"];
            [[NSUserDefaults standardUserDefaults] setObject:tempUser.password forKey:@"password"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"signedIn"];
            [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"signedIn"];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"UserSignedOutNotification" object:nil];

        }
        else{
            NSLog(@"%@", [error localizedDescription]);
        }

        [self.activityView removeFromSuperview];
        self.activityView = nil;
        [self setup];

    }];

}


@end
