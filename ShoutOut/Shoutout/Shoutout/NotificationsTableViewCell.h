//
//  NotificationsTableViewCell.h
//  Shoutout
//
//  Created by Varindra Hart on 12/5/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NotificationsTableViewCellDelegate <NSObject>

- (void)didTapButtonAtRow:(NSInteger)row;

@end


@interface NotificationsTableViewCell : UITableViewCell

@property (nonatomic) IBOutlet UILabel *usernameLabel;
@property (nonatomic) IBOutlet UILabel *mainLabel;
@property (nonatomic) NSInteger indexValue;
@property (nonatomic) IBOutlet UIButton *actionButton;

@property (weak, nonatomic) id <NotificationsTableViewCellDelegate> delegate;

@end
