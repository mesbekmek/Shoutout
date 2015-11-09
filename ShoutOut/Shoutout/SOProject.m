//
//  SOProject.m
//  Shoutout
//
//  Created by Varindra Hart on 11/8/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOProject.h"

@implementation SOProject

@dynamic createdBy;
@dynamic videos;
@dynamic collaborators;
@dynamic title;
@dynamic description;
@dynamic endDate;
@dynamic shoutout;

-(instancetype)initWithTitle:(NSString *)title{
    
    if (self = [super init]) {
        self.videos = [NSMutableArray new];
        self.collaborators = [NSMutableArray new];
        self.title = title;
        
        return self;
    }
    return nil;
}

+(NSString *)parseClassName{
    
        return @"SOProject";
}

@end
