//
//  SOFriend.h
//  Shoutout
//
//  Created by Jason Wang on 11/11/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <Parse/Parse.h>

@interface SOFriend : PFObject

@property (nonatomic) NSMutableArray *friendsRequestSent;
@property (nonatomic) NSMutableArray *friendsReceived;
@property (nonatomic) NSMutableArray *friendsAccepted;

@end
