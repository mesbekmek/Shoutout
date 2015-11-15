//
//  User.h
//  Shoutout
//
//  Created by Varindra Hart on 11/8/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <Parse/Parse.h>
#import "SOContacts.h"

@interface User : PFUser <PFSubclassing>

@property (nonatomic) SOContacts *contact;

//+ (NSString *)parseClassName;

@end
