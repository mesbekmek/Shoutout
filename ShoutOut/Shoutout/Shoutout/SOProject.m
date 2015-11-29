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
                             NSMutableArray <PFFile *>* thumbnails) )onCompletion{
    
    NSMutableArray<SOVideo *> *videoFilesArray = [[NSMutableArray alloc]init];
    
//    if (self.collaboratorHasAddedVideo)
//    {
//        [self.videos addObjectsFromArray:self.collaboratorSentVideos];
//        [self.collaboratorSentVideos removeAllObjects];
//        self.collaboratorHasAddedVideo = NO;
//    }
    
    
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
                        vid.projectId = @"";
                        i++;
                    }
                    [videoFilesArray addObject:vid];
                }
                
                //[self resortVideosArray];
                
                if(videoFilesArray.count == self.videos.count)
                {
                    NSMutableArray<SOVideo *> *sortedVideoFilesArray =  [self resortVideoFilesArray:videoFilesArray];
                    self.videos = sortedVideoFilesArray;
                    [self reindexVideos];
                    
                    SOCachedObject *newCache = [[SOCachedObject alloc]init];
                    newCache.cachedProject = self;
                    newCache.avassetsArray = [self videoAssestsArray:sortedVideoFilesArray];
                    newCache.thumbnailsArray = [sortedVideoFilesArray valueForKey:@"thumbnail"];
                    
                    [[SOCachedProjects sharedManager].cachedProjects setObject:newCache forKey:self.objectId];
                    [self saveInBackground];
                    onCompletion(self.videos, newCache.avassetsArray, [sortedVideoFilesArray valueForKey: @"thumbnail"]);
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

- (void)resortVideosArray{
    
    NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
    NSArray <SOVideo*> *sorted = [self.videos sortedArrayUsingDescriptors:@[desc]];
    self.videos = [NSMutableArray arrayWithArray:sorted];
    
}

- (void)getNewVideosIfNeeded:(void (^)(NSMutableArray <SOVideo *>*fetchedVideos, NSMutableArray <AVAsset *> *avAssets, NSMutableArray <PFFile *>*allThumbnails)) onCompletion{
    
    PFQuery *query = [PFQuery queryWithClassName:@"SOProject"];
    [query whereKey:@"objectId" containsString:self.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error){
            
            SOProject *temp = (SOProject *)objects[0];
            if (temp.collaboratorHasAddedVideo) {
                
                NSArray <NSString *> *collabObjIds = [self.collaboratorSentVideos valueForKey:@"objectId"];
                PFQuery *collaboratorQuery = [PFQuery queryWithClassName:@"SOVideo"];
                [collaboratorQuery whereKey:@"objectId" containedIn:collabObjIds];
                [collaboratorQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                    
                    if (!error) {
                        SOCachedObject *cached = [SOCachedProjects sharedManager].cachedProjects[self.objectId];
                        [self.videos addObjectsFromArray:objects];
                        [self reindexVideos];
                        for (SOVideo *video in objects) {
                            [cached.avassetsArray addObject:video.assetFromVideoFile];
                            [cached.thumbnailsArray addObject:video.thumbnail];
                        }
                        [temp.collaboratorSentVideos removeAllObjects];
                        self.collaboratorsDeclined = temp.collaboratorsDeclined;
                        self.collaboratorsReceivedFrom = temp.collaboratorsReceivedFrom;
                        self.collaboratorsSentTo = temp.collaboratorsSentTo;
                        self.collaboratorHasAddedVideo = NO;
                        [self reindexVideos];
                        
                        cached.cachedProject = self;
                        
                        [[SOCachedProjects sharedManager].cachedProjects removeObjectForKey:self.objectId];
                        [[SOCachedProjects sharedManager].cachedProjects setObject:cached forKey:self.objectId];
                        
                        [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            onCompletion(self.videos, cached.avassetsArray, cached.thumbnailsArray);
                        }];
                    }
                    else {
                        NSLog(@"Error %@", [error localizedDescription]);
                    }
                    
                }];
                
            }
            else{
                
                SOCachedObject *cached = [[SOCachedProjects sharedManager].cachedProjects objectForKey:self.objectId];
                onCompletion(cached.cachedProject.videos, cached.avassetsArray, cached.thumbnailsArray);
            }
            
        }
        else{
            NSLog(@"Error %@",[error localizedDescription]);
        }
    }];
}
@end
