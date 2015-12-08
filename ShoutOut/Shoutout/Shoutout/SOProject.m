//
//  SOProject.m
//  Shoutout
//
//  Created by Varindra Hart on 11/8/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOProject.h"
#import "SOCachedProjects.h"
#import "SOCachedObject.h"

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
@dynamic collaboratorHasAddedVideo;
@dynamic collaboratorSentVideos;
@dynamic isCompleted;

-(instancetype)initWithTitle:(NSString *)title{
    
    if (self = [super init]) {
        self.videos = [NSMutableArray new];
        self.collaboratorsSentTo = [NSMutableArray new];
        self.collaboratorsReceivedFrom = [NSMutableArray new];
        self.collaboratorsDeclined = [NSMutableArray new];
        self.collaboratorSentVideos = [NSMutableArray new];
        self.title = title;
        
        self.createdBy = [User currentUser].username;
        
        return self;
    }
    return nil;
}

- (instancetype)initWithUUID:(NSString *)uuid{
    
    if (self = [super init]) {
        self.videos = [NSMutableArray new];
        self.collaboratorsSentTo = [NSMutableArray new];
        self.collaboratorsReceivedFrom = [NSMutableArray new];
        self.collaboratorsDeclined = [NSMutableArray new];
        
        self.createdBy = uuid;
        
        return self;
    }
    return nil;
    
}

+(NSString *)parseClassName{
    
    return @"SOProject";
}

-(void)fetchVideos:(void (^)(NSMutableArray <SOVideo *> *fetchedVideos,
                             NSMutableArray <AVAsset *> *fetchedVideoAssets,
                             NSMutableArray <NSString *>*usernames,
                             NSMutableArray <PFFile *>* thumbnails))onCompletion{
    
    NSMutableArray<SOVideo *> *videoFilesArray = [[NSMutableArray alloc]init];
    
    
    NSPredicate *pred = [NSPredicate predicateWithFormat: @"objectId IN %@ OR projectId == %@", [self.videos valueForKey:@"objectId"], self.objectId];
    PFQuery *query = [PFQuery queryWithClassName:@"SOVideo" predicate:pred];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            int i = 1;
            for (SOVideo *vid in objects)
            {
                if (vid.index == -1) {
                    vid.index = objects.count - i;
                    [self.videos addObject:vid];
                    if(![self.collaboratorsReceivedFrom containsObject:vid.username])
                    {
                        [self.collaboratorsReceivedFrom addObject:vid.username];
                    }
                    if([self.collaboratorsSentTo containsObject:vid.username])
                    {
                        [self.collaboratorsSentTo removeObject:vid.username];
                    }
                    vid.projectId = @"";
                    i++;
                }
                [videoFilesArray addObject:vid];
            }
            
            //[self resortVideosArray];
            
            if(videoFilesArray.count == self.videos.count)
            {
                NSMutableArray<SOVideo *> *sortedVideoFilesArray =  [self resortVideosArray:videoFilesArray];
                self.videos = sortedVideoFilesArray;
                [self reindexVideos];
                
                SOCachedObject *newCache = [[SOCachedObject alloc]init];
                newCache.cachedProject = self;
                newCache.avassetsArray = [self videoAssestsArray:sortedVideoFilesArray];
                newCache.thumbnailsArray = [sortedVideoFilesArray valueForKey:@"thumbnail"];
                newCache.collaboratorsArray = [sortedVideoFilesArray valueForKey:@"username"];

                
                [[SOCachedProjects sharedManager].cachedProjects setObject:newCache forKey:self.objectId];
                [self saveInBackground];
                onCompletion(self.videos, newCache.avassetsArray,[sortedVideoFilesArray valueForKey: @"username"] ,[sortedVideoFilesArray valueForKey: @"thumbnail"]);
            }
        }
        else{
            NSLog(@"Error: %@",[error localizedDescription]);
        }
    }];
}

- (NSMutableArray<SOVideo *> *)resortVideoFilesArray:(NSArray <SOVideo *>*)videoFilesArray{
    
    NSMutableArray <SOVideo *> *sortedArray = [NSMutableArray new];
    for (SOVideo *video in self.videos)
    {
        for (SOVideo *unsortedVideo in videoFilesArray)
        {
            if ([unsortedVideo.objectId isEqualToString:video.objectId])
            {
                [sortedArray addObject:unsortedVideo];
                break;
            }
        }
    }
    return sortedArray;
}

-(NSMutableArray<AVAsset * > *)videoAssestsArray:(NSArray <SOVideo *>*)sortedVideoFilesArray
{
    NSMutableArray<AVAsset *> *videoAssetsArray = [NSMutableArray new];
    for (SOVideo *video in sortedVideoFilesArray)
    {
        AVAsset *videoAsset = [video assetFromVideoFile];
        [videoAssetsArray addObject:videoAsset];
    }
    return videoAssetsArray;
}

- (void)reindexVideos{
    
    for (int i = 0; i<self.videos.count; i++) {
        self.videos[i].index = i;
    }
    
}

- (NSMutableArray <SOVideo *>*)resortVideosArray:(NSMutableArray <SOVideo *> *)videosArray{
    
    NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
    NSArray <SOVideo*> *sorted = [videosArray sortedArrayUsingDescriptors:@[desc]];
    NSMutableArray <SOVideo *> *sortedMutableArray = [NSMutableArray arrayWithArray:sorted];
    return sortedMutableArray;
}

- (void)getNewVideosIfNeeded:(void (^)(NSMutableArray <SOVideo *>*fetchedVideos, NSMutableArray <AVAsset *> *avAssets, NSMutableArray <NSString * > *usernames,NSMutableArray <PFFile *>*allThumbnails)) onCompletion{
    
    PFQuery *query = [PFQuery queryWithClassName:@"SOVideo"];
    [query whereKey:@"projectId" containsString:self.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error){
            
            SOCachedObject *cached = [SOCachedProjects sharedManager].cachedProjects[self.objectId];
            if (objects.count>0) {
                
                for (SOVideo *video in objects) {
                
                        if (video.index == -1) {
                            video.index = self.videos.count;
                            [self.videos addObject:video];
                            if(![self.collaboratorsReceivedFrom containsObject:video.username])
                            {
                                [self.collaboratorsReceivedFrom addObject:video.username];
                            }
                            if([self.collaboratorsSentTo containsObject:video.username])
                            {
                                [self.collaboratorsSentTo removeObject:video.username];
                            }
                            video.projectId = @"";
                            
                        }

                    
                    [cached.avassetsArray addObject:video.assetFromVideoFile];
                    [cached.thumbnailsArray addObject:video.thumbnail];
                    [cached.collaboratorsArray addObject:video.username];
                    
                    
                }
                
                [self reindexVideos];
                
                cached.cachedProject = self;
                
                [[SOCachedProjects sharedManager].cachedProjects removeObjectForKey:self.objectId];
                [[SOCachedProjects sharedManager].cachedProjects setObject:cached forKey:self.objectId];
                
                [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    onCompletion(self.videos, cached.avassetsArray, cached.collaboratorsArray, cached.thumbnailsArray);
                }];
            }
            else{

                if ((cached.avassetsArray.count == 0 || cached.thumbnailsArray.count == 0) && cached.cachedProject.videos.count>0) {
                    cached.avassetsArray = [NSMutableArray new];
                    cached.thumbnailsArray = [NSMutableArray new];
                    cached.collaboratorsArray = [self.videos valueForKey:@"username"];
                    for (SOVideo *vid in cached.cachedProject.videos) {
                        [cached.avassetsArray addObject:[vid assetFromVideoFile]];
                        [cached.thumbnailsArray addObject:vid.thumbnail];
                    }
                    cached.cachedProject = self;
                    [[SOCachedProjects sharedManager].cachedProjects removeObjectForKey:self.objectId];
                    [[SOCachedProjects sharedManager].cachedProjects setObject:cached forKey:self.objectId];
                }
                onCompletion(self.videos, cached.avassetsArray, cached.collaboratorsArray, cached.thumbnailsArray);
            }
        }
        else{
            NSLog(@"Error %@",[error localizedDescription]);
        }
    }];
}
@end
