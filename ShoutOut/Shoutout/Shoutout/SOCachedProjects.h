//
//  SOCachedProjects.h
//  Shoutout
//
//  Created by Varindra Hart on 11/22/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOCachedObject.h"

@interface SOCachedProjects : NSObject

@property (nonatomic) NSMutableDictionary *cachedProjects;

+ (instancetype)sharedManager;

@end
