//
//  ViewController.h
//  ShoutOut
//
//  Created by Mesfin Bekele Mekonnen on 8/13/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface ViewController : UIViewController<PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;

- (IBAction)logOutButton:(UIButton *)sender;

@end

