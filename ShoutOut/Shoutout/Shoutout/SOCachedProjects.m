//
//  SOCachedProjects.m
//  Shoutout
//
//  Created by Varindra Hart on 11/22/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOCachedProjects.h"

@implementation SOCachedProjects

+ (instancetype)sharedManager{
    
    static SOCachedProjects *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
        sharedMyManager.cachedProjects = [NSMutableDictionary new];
    });
    return sharedMyManager;

}

@end
