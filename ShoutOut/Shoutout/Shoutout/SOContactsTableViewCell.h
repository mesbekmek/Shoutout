//
//  SOContactsTableViewCell.h
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 11/29/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOContactsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (nonatomic) BOOL isHighlighted;

- (IBAction)addButtonTapped:(UIButton *)sender;

@end
