//
//  SOFriendsTableViewCell.m
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 11/29/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOFriendsTableViewCell.h"
#import <ChameleonFramework/Chameleon.h>


@implementation SOFriendsTableViewCell

- (void)awakeFromNib {
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
    
    // Configure the view for the selected state
}
- (IBAction)collaborateButtonTapped:(UIButton *)sender {
    if(!self.isHighlighted){
        self.isHighlighted = YES;
        [self.buttonView setBackgroundColor:[UIColor colorWithHexString:@"#F07179"]];
    }else{
        [self.buttonView setBackgroundColor:[UIColor clearColor]];
        self.isHighlighted = NO;
    }
    [self.delegate didTapButtonAtFriendRow:self.indexValue];

}




@end
