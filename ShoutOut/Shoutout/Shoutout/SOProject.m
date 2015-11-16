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
@dynamic collaboratorsSentTo;
@dynamic collaboratorsReceivedFrom;
@dynamic collaboratorsDeclined;
@dynamic title;
@dynamic description;
@dynamic endDate;
@dynamic shoutout;

-(instancetype)initWithTitle:(NSString *)title{
    
    if (self = [super init]) {
        self.videos = [NSMutableArray new];
        self.collaboratorsSentTo = [NSMutableArray new];
        self.collaboratorsReceivedFrom = [NSMutableArray new];
        self.collaboratorsDeclined = [NSMutableArray new];
        self.title = title;
        
        self.createdBy = [User currentUser].username;
        
        return self;
    }
    return nil;
}

+(NSString *)parseClassName{
    
        return @"SOProject";
}



@end
