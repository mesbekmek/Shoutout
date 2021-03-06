//
//  SOVideo.m
//  Shoutout
//
//  Created by Varindra Hart on 11/8/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOVideo.h"
#import "NSURL+ImageGenerator.h"

@implementation SOVideo

@dynamic video;
@dynamic thumbnail;
@dynamic username;
@dynamic details;

+(NSString*)parseClassName{
    
    return @"SOVideo";
}

- (instancetype)initWithVideoUrl:(NSURL *)url{
    
    
    if (self = [super init]){
        
        self.username = [PFUser currentUser].username;
        
        if (url) {
            UIImage *thumbnail = url.thumbnailImagePreview;
            self.thumbnail = [PFFile fileWithData:UIImageJPEGRepresentation(thumbnail, .8f) contentType:@"image/jpeg"];
            NSData *videoData = [NSData dataWithContentsOfURL:url];
            self.video = [PFFile fileWithData:videoData contentType:@"video/mp4"];
            
            return self;
            
        }
        else{
            return self;
        }
    }
    
    return nil;
    
}

- (AVAsset*)assetFromVideoFile{
    
    if (self.video) {
        
        NSString *videoURLString = self.video.url;
        NSURL *videoURL = [NSURL URLWithString:videoURLString];
        AVAsset *asset = [AVAsset assetWithURL:videoURL];
        return asset;
        
    }
    
    return nil;
}


@end
