//
//  SOSortingCVC.m
//  Shoutout
//
//  Created by Diana Elezaj on 11/12/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOSortingCVC.h"

@implementation SOSortingCVC

- (id)copyWithZone:(NSZone *)zone {
    UICollectionViewCell *cell = [[SOSortingCVC alloc] initWithFrame:self.frame];
    // Just copying background color for demo purposes. You really want to copy your custom cell as needed
    cell.backgroundColor = self.backgroundColor;
    return cell;
}



- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        self.deleteItemButton = [[UIButton alloc]init];
        
        [self.deleteItemButton setBackgroundImage:[UIImage imageNamed:@"deleteItemIcon"] forState:UIControlStateNormal];
        
        [self addSubview:self.videoImageView];
        [self addSubview:self.deleteItemButton];
    }
    return self;
}

@end
