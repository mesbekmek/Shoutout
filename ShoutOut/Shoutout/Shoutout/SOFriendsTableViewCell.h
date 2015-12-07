//
//  SOFriendsTableViewCell.h
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 11/29/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SOFriendsTableViewCellDelegate <NSObject>

- (void)didTapButtonAtFriendRow:(NSInteger)row;


@end

@interface SOFriendsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *collaborateButton;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (nonatomic) BOOL isHighlighted;
@property (nonatomic) NSInteger indexValue;


- (IBAction)collaborateButtonTapped:(UIButton *)sender;
@property (weak,nonatomic) id<SOFriendsTableViewCellDelegate> delegate;

@end
