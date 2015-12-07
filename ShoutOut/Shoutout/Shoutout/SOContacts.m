//
//  SOContacts.m
//  Shoutout
//
//  Created by Jason Wang on 11/15/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOContacts.h"

@implementation SOContacts

@dynamic contactsList;


+(NSString*)parseClassName{
    
    return @"SOContacts";
}

- (instancetype)initWithNewList{
    
    if (self = [super init]){
        
        self.contactsList = [NSMutableArray new];
        
        return self;
    }
    return nil;
}


@end
