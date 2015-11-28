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
#import "SORequest.h"

@interface SOCachedObject : NSObject

@property (nonatomic) SOProject *cachedProject;
@property (nonatomic) NSMutableArray <AVAsset*> *avassetsArray;
@property (nonatomic) NSMutableArray <PFFile *> *thumbnailsArray;

@property (nonatomic) NSMutableArray <SORequest *> *collaborationRequestsArray;
@property (nonatomic) NSMutableArray <SORequest *> *friendRequestsArray;
@property (nonatomic) NSMutableArray <SORequest *> *responseRequestsArray;
@end
