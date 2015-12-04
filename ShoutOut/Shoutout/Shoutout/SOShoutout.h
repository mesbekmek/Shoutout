//
//  SOShoutout.h
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 11/30/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "PFObject.h"
#import "SOVideo.h"
#import <Parse/Parse.h>

@interface SOShoutout : PFObject <PFSubclassing>

+ (NSString*)parseClassName;

@property (nonatomic) NSString *projectTitle;
@property (nonatomic) NSMutableArray<SOVideo *> *videosArray;
@property (nonatomic) NSMutableArray <NSString *> *collaborators;
@property (nonatomic) NSMutableArray <NSString *> *receipients;

-(instancetype)init;

+(void)sendVideo:(NSArray<SOVideo *> *)videosArray withTitle:(NSString *)title toCollaborators:(NSArray<NSString *>*)collaborators toReceipents:(NSArray<NSString *>*)receipients;

- (void)fetchAllShoutouts:(void (^) (NSMutableArray <SOShoutout *> *shoutoutsCollaborationsArray, NSMutableArray <SOShoutout *> *shoutoutsReceipientsArray))onCompletion;

- (void)fetchIfUpdatesAvailable:(void (^) (NSMutableArray <SOShoutout *> *shoutoutsCollaborationsArray, NSMutableArray <SOShoutout *> *shoutoutsReceipientsArray))onCompletion;

@end
