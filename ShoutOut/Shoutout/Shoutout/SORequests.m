//
//  SORequest.m
//  Shoutout
//
//  Created by Jason Wang on 11/15/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SORequests.h"
#import "User.h"
#import "SOCachedProjects.h"


@implementation SORequests

@dynamic requestSentFrom;
@dynamic requestSentTo;
@dynamic hasDecided;
@dynamic isAccepted;
@dynamic projectId;
@dynamic projectTitle;




- (instancetype)initWithPendingRequestTo:(NSString *)requestedUser {
    if (self = [super init]) {
        self.requestSentFrom = [User currentUser].username;
        self.requestSentTo = requestedUser;
        self.hasDecided = NO;
        self.isAccepted = NO;
        return self;
    }
    return nil;
}

+ (NSString*)parseClassName{
    
    return @"SORequest";
}

//Collaborations
+ (void)sendRequestTo:(NSString *)requestedUser forProjectId:(NSString *)projId{
    
    SORequests *request = [[SORequests alloc]initWithPendingRequestTo:requestedUser];
    request.projectId = projId;
    
    [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"Request send to %@",requestedUser);
    }];
}

//Friend Requests
+ (void)sendRequestTo:(NSString *)requestedUser{
    
    SORequests *request = [[SORequests alloc]initWithPendingRequestTo:requestedUser];
    
    [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"Request send to %@",requestedUser);
    }];
}

- (void)fetchAllRequests:(void (^)(NSMutableArray<SORequests *> *collaborationRequests, NSMutableArray<SORequests *> *friendRequests, NSMutableArray<SORequests *> *responseRequests))onCompletion{
    
    
    NSMutableArray <SORequests *> *collaborationReq = [NSMutableArray new];
    NSMutableArray <SORequests *> *friendReq        = [NSMutableArray new];
    NSMutableArray <SORequests *> *responseReq      = [NSMutableArray new];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"requestSentTo == %@ OR requestSentFrom == %@", [User currentUser].username, [User currentUser].username] ;
    PFQuery *reqQuery = [PFQuery queryWithClassName:@"SORequest" predicate:predicate];
    [reqQuery orderByDescending:@"updatedAt"];
    [reqQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error ) {
            
            for (SORequests *req in objects) {
                if ([req.requestSentFrom isEqualToString:[User currentUser].username]) {
                    [responseReq addObject:req];
                }
                else if([req.requestSentTo isEqualToString:[User currentUser].username]){
                    [collaborationReq addObject:req];
                }
                else{
                    [friendReq addObject:req];
                }
            }
            [self cacheCollaborationArray:collaborationReq friendRequests:friendReq andResponseRequests:responseReq];
            onCompletion(collaborationReq,friendReq,responseReq);
        }
        else{
            NSLog(@"Error: %@",[error localizedDescription]);
            onCompletion(collaborationReq,friendReq,responseReq);
        }
    }];
    
}

- (void)cacheCollaborationArray:(NSMutableArray <SORequests *> *)collReq friendRequests:(NSMutableArray <SORequest *> *)friendReq andResponseRequests:(NSMutableArray <SORequests *> *)respReq{
    
    SOCachedObject *reqObj = [[SOCachedObject alloc]init];
    reqObj.collaborationRequestsArray = collReq;
    reqObj.friendRequestsArray = friendReq;
    reqObj.responseRequestsArray = respReq;
    [[SOCachedProjects sharedManager].cachedRequests setObject:reqObj forKey:@"cachedRequests"];
    
    
    
}

- (void)fetchForUpdates:(void (^)(NSMutableArray<SORequests *> *, NSMutableArray<SORequests *> *, NSMutableArray<SORequests *> *))onCompletion{
    
}

@end
