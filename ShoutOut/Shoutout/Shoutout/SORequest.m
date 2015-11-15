//
//  SORequest.m
//  Shoutout
//
//  Created by Jason Wang on 11/15/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SORequest.h"

@implementation SORequest

@dynamic requestSentFrom;
@dynamic requestSentTo;
@dynamic hasDecided;
@dynamic isAccepted;

+(NSString*)parseClassName{
    
    return @"SORequest";
}

@end
