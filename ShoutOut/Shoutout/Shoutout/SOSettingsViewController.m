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

@interface SOSettingsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *signedInAs;
@property (nonatomic, weak) IBOutlet UIButton *logInLogOut;
@property (nonatomic) BOOL signedInStatus;

@end

@implementation SOSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setup];
}

- (void)setup{

    self.signedInStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"signedIn"];

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

        }];

    }

}




@end
