//
//  SORequest.h
//  Shoutout
//
//  Created by Jason Wang on 11/15/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface SORequest : PFObject <PFSubclassing>

@property (nonatomic) NSString *requestSentFrom;
@property (nonatomic) NSString *requestSentTo;
@property (nonatomic) BOOL hasDecided;
@property (nonatomic) BOOL isAccepted;


-(instancetype)initWithPendingRequestTo:(NSString *)requestedUser;

+(void)updateRequestWithDecided:(BOOL)didDecided withDidAccepted:(BOOL)didAccepted;

+(NSString*)parseClassName;

+(void)sendRequestTo:(NSString *)requestedUser;
@end
