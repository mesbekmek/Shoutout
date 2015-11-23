//
//  SOCachedObject.h
//  Shoutout
//
//  Created by Varindra Hart on 11/22/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Parse/Parse.h>
#import "SOModel.h"

@interface SOCachedObject : NSObject

@property (nonatomic) SOProject *cachedProject;
@property (nonatomic) NSMutableArray <AVAsset*> *avassetsArray;
@property (nonatomic) NSMutableArray <PFFile *> *thumbnailsArray;

@end
