//
//  SOContacts.h
//  Shoutout
//
//  Created by Jason Wang on 11/15/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <Parse/Parse.h>

@interface SOContacts : PFObject <PFSubclassing>

@property (nonatomic) NSArray *contactsList;

+ (NSString *)parseClassName;

@end