//
//  SOVideoCVC.h
//  Shoutout
//
//  Created by Diana Elezaj on 11/12/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface SOVideoCVC : UICollectionViewCell
@property (weak, nonatomic) IBOutlet PFImageView *videoImageView;

@property (weak, nonatomic) IBOutlet UILabel *projectTitle;

@end
