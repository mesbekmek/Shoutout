//
//  SOSortingViewController.h
//  Shoutout
//
//  Created by Diana Elezaj on 11/12/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOProject.h"
#import "SOVideo.h"
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>

@interface SOSortingViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic) SOProject *currentProject;

@end
