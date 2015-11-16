//
//  SORequest.m
//  Shoutout
//
//  Created by Jason Wang on 11/15/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SORequest.h"
#import "User.h"


@implementation SORequest

@dynamic requestSentFrom;
@dynamic requestSentTo;
@dynamic hasDecided;
@dynamic isAccepted;

-(instancetype)initWithPendingRequestTo:(NSString *)requestedUser {
    if (self = [super init]) {
        self.requestSentFrom = [User currentUser].username;
        self.requestSentTo = requestedUser;
        self.hasDecided = NO;
        self.isAccepted = NO;
        return self;
    }
    return nil;
}

+(NSString*)parseClassName{
    
    return @"SORequest";
}

+(void)sendRequestTo:(NSString *)requestedUser{
    
    SORequest *request = [[SORequest alloc]initWithPendingRequestTo:requestedUser];
    [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"Request send to %@",requestedUser);
    }];
}

@end
