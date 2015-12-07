//
//  SOShareViewController.h
//  Shoutout
//
//  Created by Varindra Hart on 11/29/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOProject.h"

@interface SOShareViewController : UIViewController

@property (nonatomic) NSString *shareUrl;
@property (nonatomic) SOProject *sharedProject;
@property (nonatomic) NSString *projectTitle;

@end
