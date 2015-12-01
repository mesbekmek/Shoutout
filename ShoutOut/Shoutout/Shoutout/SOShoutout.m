//
//  SOShoutout.m
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 11/30/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOShoutout.h"

@implementation SOShoutout


@dynamic videosArray;
@dynamic receipients;
@dynamic collabortators;

+ (NSString*)parseClassName{
    return @"SOShoutout";
}

-(instancetype)init{
    if(self = [super init]){
        self.collabortators = [NSMutableArray new];
        self.receipients = [NSMutableArray new];
        self.videosArray = [NSMutableArray new];
        return self;
    }
    return nil;
}

+(void)sendVideo:(NSArray<SOVideo *> *)shoutOut toCollaborators:(NSArray*)collaborators
{
    SOShoutout *shoutout = [[SOShoutout alloc] init];
    
    shoutout.videosArray = [NSMutableArray arrayWithArray:shoutOut];
    shoutout.collabortators = [NSMutableArray arrayWithArray:collaborators];
    
    [shoutout saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"Saved Shoutout");
    }];
}

+(void)sendVideo:(NSArray<SOVideo *> *)shoutOut toReceipents:(NSArray*)receipients
{
    SOShoutout *shoutout = [[SOShoutout alloc] init];
    
    shoutout.videosArray = [NSMutableArray arrayWithArray:shoutOut];
    shoutout.receipients = [NSMutableArray arrayWithArray:receipients];
    
    [shoutout saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"Saved Shoutout");
    }];
}

@end
