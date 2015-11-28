//
//  SOCachedObject.h
//  Shoutout
//
//  Created by Varindra Hart on 11/28/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SOProject.h"
#import "SORequests.h"
#import "SOCachedProjects.h"

@interface SOCachedObject : NSObject

@property (nonatomic) SOProject *cachedProject;
@property (nonatomic) SOCachedProjects *prokect;

@property (nonatomic) NSMutableArray <AVAsset*> *avassetsArray;
@property (nonatomic) NSMutableArray <PFFile *> *thumbnailsArray;

@property (nonatomic) SOVideo *video;


@property (nonatomic) NSMutableArray <SORequests *> *collaborationRequestsArray;
@property (nonatomic) NSMutableArray <SORequests *> *friendRequestsArray;
@property (nonatomic) NSMutableArray <SORequests *> *responseRequestsArray;

@end
