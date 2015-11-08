//
//  Video.h
//  Shoutout
//
//  Created by Jason Wang on 11/8/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;

@interface Video : NSObject

@property (nonatomic) AVAsset *videoFile;
@property (nonatomic) NSString *username;

@end
