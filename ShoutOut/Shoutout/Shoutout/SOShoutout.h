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


@property (nonatomic) NSMutableArray<SOVideo *> *videosArray;
@property (nonatomic) NSMutableArray *collabortators;
@property (nonatomic) NSMutableArray *receipients;

-(instancetype)init;

+(void)sendVideo:(NSArray<SOVideo *> *)shoutout toCollaborators:(NSArray*)collaborators;

+(void)sendVideo:(NSArray<SOVideo *> *)shoutout toReceipents:(NSArray*)receipients;

@end
