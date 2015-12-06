//
//  FriendRequestTableViewCell.m
//  
//
//  Created by Varindra Hart on 12/5/15.
//
//

#import "FriendRequestTableViewCell.h"

@implementation FriendRequestTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)actionButtonTapped:(id)sender {

    [self.delegate didTapActionButtonAtRow:self.indexValue];
}



@end
