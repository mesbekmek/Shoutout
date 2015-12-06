//
//  FriendRequestTableViewCell.h
//  
//
//  Created by Varindra Hart on 12/5/15.
//
//

#import <UIKit/UIKit.h>

@protocol FriendRequestTableViewCellDelegate <NSObject>

- (void)didTapActionButtonAtRow:(NSInteger)row;

@end


@interface FriendRequestTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (nonatomic) NSInteger indexValue;
@property (nonatomic,weak) id <FriendRequestTableViewCellDelegate> delegate;

@end
