//
//  User.m
//  Shoutout
//
//  Created by Varindra Hart on 11/8/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "User.h"

@implementation User

@dynamic contacts;
@dynamic phoneNumber;

//+ (NSString *)parseClassName {
//    return @"User";
//}

-(instancetype)initWithContacts{
    
    if (self = [super init]) {
        self.contacts = [SOContacts new];
        return self;
        
    }
    return nil;
}

@end
