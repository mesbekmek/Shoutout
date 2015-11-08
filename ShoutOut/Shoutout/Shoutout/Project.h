//
//  Project.h
//  Shoutout
//
//  Created by Jason Wang on 11/8/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Video.h"

@interface Project : NSObject

@property (nonatomic) NSMutableArray *collaborators;
@property (nonatomic) NSMutableArray *videosArray;
@property (nonatomic) NSDate *dueDate;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *videoDescription;
@property (nonatomic) BOOL isCompleted;
@property (nonatomic) Video *video;

@end
