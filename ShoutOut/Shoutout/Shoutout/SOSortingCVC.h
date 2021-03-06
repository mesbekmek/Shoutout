//
//  SOSortingCVC.h
//  Shoutout
//
//  Created by Diana Elezaj on 11/12/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <UIKit/UIKit.h>

@interface SOSortingCVC : UICollectionViewCell <NSCopying>
@property (weak, nonatomic) IBOutlet PFImageView *videoImageView;
@property (strong, nonatomic) IBOutlet UIButton *deleteItemButton;
@property (weak, nonatomic) IBOutlet UILabel *collaboratorUsernameLabel;

@end
