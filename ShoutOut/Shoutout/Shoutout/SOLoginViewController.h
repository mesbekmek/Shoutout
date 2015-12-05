//
//  SOLoginViewController.h
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 11/11/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
#import "SOProject.h"

@interface SOLoginViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic) NSString *projectID;
@property (nonatomic) SOProject *sortingProject;

@end
