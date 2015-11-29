//
//  SONotificationsHeader.h
//  Shoutout
//
//  Created by Varindra Hart on 11/29/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SONotificationsHeader : UITableViewHeaderFooterView

@property (nonatomic) IBOutlet UILabel *headerTitle;
@property (weak, nonatomic) IBOutlet UIView *headerUnderline;

@end
