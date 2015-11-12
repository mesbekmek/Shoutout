//
//  ProjectsViewController.h
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 11/8/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOProject.h"
#import "SOVideo.h"
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>

@interface ProjectsViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic) SOProject *currentProject;

@end
