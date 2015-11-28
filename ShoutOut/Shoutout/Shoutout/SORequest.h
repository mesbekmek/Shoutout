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
@property (nonatomic) NSString *projectId;
@property (nonatomic) NSString *projectTitle;




- (instancetype)initWithPendingRequestTo:(NSString *)requestedUser;

+ (NSString*)parseClassName;

+ (void)sendRequestTo:(NSString *)requestedUser;

+ (void)sendRequestTo:(NSString *)requestedUser forProjectId:(NSString *)projId;

- (void)fetchAllRequests:(void (^)(NSMutableArray <SORequest *> *collaborationRequests, NSMutableArray <SORequest *> *friendRequests,  NSMutableArray <SORequest *> *responseRequests))onCompletion;

- (void)fetchForUpdates:(void (^)(NSMutableArray <SORequest *> *collaborationRequests,NSMutableArray <SORequest *> *friendRequests, NSMutableArray <SORequest *> *responseRequests))onCompletion;

@end
