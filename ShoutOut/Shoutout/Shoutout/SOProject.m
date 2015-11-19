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

-(void)fetchVideos:(void (^)(NSArray <SOVideo *> *fetchedVideos, NSArray <AVAsset *> *fetchedVideoAssets, NSArray <PFFile *>* thumbnails))onCompletion{
    NSMutableArray<SOVideo *> *videoFilesArray = [[NSMutableArray alloc]init];
    
    
    for (SOVideo *video in self.videos) {
        
        PFQuery *query = [PFQuery queryWithClassName:@"SOVideo"];
        
        [query whereKey:@"objectId" containsString:video.objectId];

        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error) {
                NSLog(@"video objects %@",objects);
                for (SOVideo *vid in objects) {
                    NSLog(@"Current video is: %@", vid.video);
                    //add video  PFiles to videoFiles array
                    [videoFilesArray addObject:vid];
                    //
                }
                if(videoFilesArray.count == self.videos.count){
                    
                    [self resortVideoFilesArray:videoFilesArray];
                    
                    onCompletion(videoFilesArray, [self videoAssestsArray], [videoFilesArray valueForKey: @"thumbnail"]);
                    
                }
            }
            
            else{
                NSLog(@"Error: %@",error);
            }
        }];
    }
    
    
}

- (NSArray *)resortVideoFilesArray:(NSArray <SOVideo *>*)videoFilesArray{
    
    NSMutableArray <SOVideo *> *sortedArray = [NSMutableArray new];
    
    for (SOVideo *video in self.videos) {
        
        for (SOVideo *unsortedVideo in videoFilesArray) {
            if ([unsortedVideo.objectId isEqualToString:video.objectId]) {
                
                [sortedArray addObject:unsortedVideo];
                
                break;
            }
        }
        
    }
    return sortedArray;
    
}



-(NSMutableArray<AVAsset * > *)videoAssestsArray
{
    NSMutableArray<AVAsset *> *videoAssetsArray = [NSMutableArray new];
    for (int i=0; i < self.videoFilesArray.count; i++)
    {
        SOVideo *currentVideo = self.videoFilesArray[i];
        AVAsset *videoAsset = [currentVideo assetFromVideoFile];
        [videoAssetsArray addObject:videoAsset];
    }
    return videoAssetsArray;
}

@end
