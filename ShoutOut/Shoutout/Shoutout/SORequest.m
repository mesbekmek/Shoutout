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

+(void)updateRequestWithDecided:(BOOL)didDecided withDidAccepted:(BOOL)didAccepted {
//    PFQuery *query = [PFQuery queryWithClassName:@"SORequest"];
//    [query whereKey:@"requestSendto" equalTo:[User currentUser].username];
//    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
//        SORequest *updateRequest = object;
//        [updateRequest setValue:didDecided forKey:@"hasDecided"];
//        [updateRequest setValue:didAccepted forKey:@"isAccepted"];
//        [updateRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//            NSLog(@"update request to parse");
//        }];
//    }];
    
    
    
    
    SORequest *request = [[SORequest alloc]init];
    request.hasDecided = didDecided;
    request.isAccepted = didAccepted;
    [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"Request Status Updated");
              }];
}

@end
