//
//  SORequest.m
//  Shoutout
//
//  Created by Jason Wang on 11/15/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SORequest.h"
#import "User.h"
#import "SOCachedProjects.h"
#import "SOCachedObject.h"

@implementation SORequest

@dynamic requestSentFrom;
@dynamic requestSentTo;
@dynamic hasDecided;
@dynamic isAccepted;
@dynamic isFriendRequest;
@dynamic projectId;
@dynamic projectTitle;




- (instancetype)initWithPendingRequestTo:(NSString *)requestedUser {
    if (self = [super init]) {
        self.requestSentFrom = [User currentUser].username;
        self.requestSentTo = requestedUser;
        self.hasDecided = NO;
        self.isAccepted = NO;
        self.isFriendRequest = YES;
        return self;
    }
    return nil;
}

+ (NSString*)parseClassName{
    
    return @"SORequest";
}

//Collaborations
+ (void)sendRequestTo:(NSString *)requestedUser forProjectId:(NSString *)projId andTitle:(NSString *)title{
    
    SORequest *request = [[SORequest alloc]initWithPendingRequestTo:requestedUser];
    request.isFriendRequest = NO;
    request.projectId = projId;
    request.projectTitle = title;
    [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"Request send to %@",requestedUser);
    }];
}

//Friend Requests
+ (void)sendRequestTo:(NSString *)requestedUser withBlock:(void (^)(BOOL succeeded))onCompletion{
    
    PFQuery *checkForDoubleRequest = [PFQuery queryWithClassName:@"SORequest"];
    [checkForDoubleRequest whereKey:@"requestSentFrom" equalTo:[User currentUser].username];
    [checkForDoubleRequest whereKey:@"requestSentTo" equalTo:requestedUser];
    [checkForDoubleRequest whereKey:@"isFriendRequest" equalTo:[NSNumber numberWithBool:YES]];
    [checkForDoubleRequest whereKey:@"hasDecided" equalTo:[NSNumber numberWithBool:NO]];
    [checkForDoubleRequest whereKey:@"isAccepted" equalTo:[NSNumber numberWithBool:NO]];
    [checkForDoubleRequest findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count == 0) {
            SORequest *request = [[SORequest alloc]initWithPendingRequestTo:requestedUser];
            
            [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                NSLog(@"Request send to %@",requestedUser);
                onCompletion (succeeded);
            }];
        } else {
            NSLog(@"Friend request is still pending");
            BOOL isSucceeded = NO;
            onCompletion(isSucceeded);
        }
    }];
    

}

- (void)fetchAllRequests:(void (^)(NSMutableArray<SORequest *> *collaborationRequests, NSMutableArray<SORequest *> *friendRequests, NSMutableArray<SORequest *> *responseRequests))onCompletion{
    
    
    NSMutableArray <SORequest *> *collaborationReq = [NSMutableArray new];
    NSMutableArray <SORequest *> *friendReq        = [NSMutableArray new];
    NSMutableArray <SORequest *> *responseReq      = [NSMutableArray new];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"requestSentTo == %@ OR requestSentFrom == %@", [User currentUser].username, [User currentUser].username] ;
    PFQuery *reqQuery = [PFQuery queryWithClassName:@"SORequest" predicate:predicate];
    [reqQuery orderByDescending:@"updatedAt"];
    [reqQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error ) {
            
            for (SORequest *req in objects) {
                if ([req.requestSentFrom isEqualToString:[User currentUser].username]) {
                    if (req.hasDecided!=0) {
                        [responseReq addObject:req];
                    }
                    
                }
                else if([req.requestSentTo isEqualToString:[User currentUser].username] && !req.isFriendRequest){
                    if (req.hasDecided == 0) {
                        [collaborationReq addObject:req];
                    }
                }
                else{
                    if(req.hasDecided == 0){
                        [friendReq addObject:req];
                    }
                }
            }
            //[self cacheCollaborationArray:collaborationReq friendRequests:friendReq andResponseRequests:responseReq];
            onCompletion(collaborationReq,friendReq,responseReq);
        }
        else{
            NSLog(@"Error: %@",[error localizedDescription]);
            onCompletion(collaborationReq,friendReq,responseReq);
        }
    }];
    
}

- (void)cacheCollaborationArray:(NSMutableArray <SORequest *> *)collReq friendRequests:(NSMutableArray <SORequest *> *)friendReq andResponseRequests:(NSMutableArray <SORequest *> *)respReq{
    
    SOCachedObject *reqObj = [[SOCachedObject alloc]init];
    reqObj.collaborationRequestsArray = collReq;
    reqObj.friendRequestsArray = friendReq;
    reqObj.responseRequestsArray = respReq;
    [[SOCachedProjects sharedManager].cachedRequests setObject:reqObj forKey:@"cachedRequests"];
    
    
    
}

- (void)fetchForUpdates:(void (^)(NSMutableArray<SORequest *> *, NSMutableArray<SORequest *> *, NSMutableArray<SORequest *> *))onCompletion{
    
}

- (void)fetchAllFriendRequests:(void (^)( NSMutableArray<NSString *> *friendRequestsAcceptedUsernames))onCompletion{
    
    NSMutableArray <NSString*> *friendReq = [NSMutableArray new];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"requestSentFrom == %@", [User currentUser].username, [User currentUser].username] ;
    
    PFQuery *reqQuery = [PFQuery queryWithClassName:@"SORequest" predicate:predicate];
    [reqQuery orderByDescending:@"updatedAt"];
    
    [reqQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error ) {
            
            for (SORequest *req in objects) {
                if ([req.requestSentFrom isEqualToString:[User currentUser].username]) {
                    if (req.hasDecided == YES && req.isAccepted == YES && req.isFriendRequest) {
                        [friendReq addObject:req.requestSentTo];
                        [req deleteInBackground];
                    }
                }
            }
                       onCompletion(friendReq);
        }
        else{
            NSLog(@"Error: %@",[error localizedDescription]);
            
        }
    }];
    
}


@end
