//
//  SOContactsTableViewCell.m
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 11/29/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOContactsTableViewCell.h"
#import <ChameleonFramework/Chameleon.h>

@implementation SOContactsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)addButtonTapped:(UIButton *)sender {
    
    if(!self.isHighlighted){
        self.isHighlighted = YES;
        
        UIImage *image = [UIImage imageNamed:@"checkmarkIcon"];
        [self.addButton setBackgroundImage:image forState:UIControlStateNormal];
    }else{
        
        self.isHighlighted = NO;
        [self.addButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
    [self.delegate didTapButtonAtRow:self.indexValue];
}

@end
