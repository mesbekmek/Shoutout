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
    
//     UIImage *image = [UIImage imageNamed:@"checkmarkIcon"];
//    [self.collaborateButton setImage:image forState:UIControlStateNormal];
//    [self.collaborateButton setImage:image forState:UIControlStateHighlighted];
////    [self.collaborateButton setImage:image forState:UIControlStateSelected];
    
    
   
    if(!self.isHighlighted){
        self.isHighlighted = YES;
        
        UIImage *image = [UIImage imageNamed:@"checkmarkIcon"];
        [self.collaborateButton setBackgroundImage:image forState:UIControlStateNormal];
    }else{
        
        self.isHighlighted = NO;
        [self.collaborateButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
    [self.delegate didTapButtonAtFriendRow:self.indexValue];

}



@end
