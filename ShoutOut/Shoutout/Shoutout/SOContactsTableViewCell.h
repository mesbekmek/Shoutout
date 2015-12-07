//
//  SOContactsTableViewCell.h
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 11/29/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SOContactsTableViewCellDelegate <NSObject>

- (void)didTapButtonAtRow:(NSInteger)row;


@end

@interface SOContactsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (nonatomic) BOOL isHighlighted;
@property (nonatomic) NSInteger indexValue;


- (IBAction)addButtonTapped:(UIButton *)sender;

@property (weak,nonatomic) id<SOContactsTableViewCellDelegate> delegate;

@end
