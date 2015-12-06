//
//  NotificationsTableViewCell.m
//  Shoutout
//
//  Created by Varindra Hart on 12/5/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "NotificationsTableViewCell.h"

@implementation NotificationsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)buttonTapped:(id)sender{

    [self.delegate didTapButtonAtRow:self.indexValue];

}



@end
