//
//  SOVideo.h
//  Shoutout
//
//  Created by Varindra Hart on 11/8/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <Parse/Parse.h>
#import <AVFoundation/AVFoundation.h>

@interface SOVideo : PFObject <PFSubclassing>

@property (nonatomic) PFFile *video;
@property (nonatomic) PFFile *thumbnail;
@property (nonatomic) NSString *username;
@property (nonatomic) NSString *details;
@property (nonatomic) NSInteger index;

+ (NSString*)parseClassName;
- (instancetype)initWithVideoUrl:(NSURL *)url;
- (AVAsset*)assetFromVideoFile;

@end
