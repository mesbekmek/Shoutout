//
//  SOCachedProjects.h
//  Shoutout
//
//  Created by Varindra Hart on 11/22/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOCachedProjects.h"

@interface SOCachedProjects : NSObject

@property (nonatomic) NSMutableDictionary *cachedProjects;
@property (nonatomic) NSMutableDictionary *cachedRequests;

+ (instancetype)sharedManager;

@end
