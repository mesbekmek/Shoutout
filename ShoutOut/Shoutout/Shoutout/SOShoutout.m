//
//  SOShoutout.m
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 11/30/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOShoutout.h"
#import "User.h"
#import "SOCachedProjects.h"

@implementation SOShoutout


@dynamic videosArray;
@dynamic receipients;
@dynamic collaborators;
@dynamic projectTitle;

+ (NSString*)parseClassName{
    return @"SOShoutout";
}

-(instancetype)initShoutout
{
    if(self = [super init]){
        self.collaborators = [NSMutableArray new];
        self.receipients = [NSMutableArray new];
        self.videosArray = [NSMutableArray new];
        return self;
    }
    return nil;
}

+(void)sendVideo:(NSArray<SOVideo *> *)videosArray withTitle:(NSString *)title toCollaborators:(NSArray<NSString *> *)collaborators toReceipents:(NSArray<NSString *> *)receipients
{
    if (videosArray.count>0) {

        SOShoutout *shoutout = [[SOShoutout alloc] init];

        shoutout.videosArray = [NSMutableArray arrayWithArray:videosArray];
        if (collaborators.count > 0) {
            shoutout.collaborators = [NSMutableArray arrayWithArray:collaborators];
        }
        if (receipients.count>0) {
            shoutout.receipients = [NSMutableArray arrayWithArray:receipients];
        }

        shoutout.projectTitle = title;

        [shoutout saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            NSLog(@"Saved Shoutout");
        }];
    }
}

- (void)fetchAllCollabs:(void (^) (NSMutableArray <SOShoutout *> *shoutoutsCollaborationsArray))onCompletion{

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"collaborators == %@",[User currentUser].username];
    PFQuery *query = [PFQuery queryWithClassName:@"SOShoutout" predicate:pred];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
     {
         if (!error)
         {
             if (objects.count >0)
             {
                 NSMutableArray<SOShoutout *> *orderedShoutouts = [NSMutableArray arrayWithArray:[objects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]]];

                 NSMutableArray<NSMutableArray <SOVideo *> *> * shoutoutArrayOfUnassignedVideosArray = [NSMutableArray<NSMutableArray <SOVideo *> *> new];

                 NSMutableArray<NSString *> *firstVideoIds = [NSMutableArray<NSString *> new];
                 for (SOShoutout *shoutout in orderedShoutouts)
                 {
                     NSString *firstVideoID = shoutout.videosArray[0].objectId;
                     [firstVideoIds addObject:firstVideoID];
                 }
                 PFQuery *videoQuery = [PFQuery queryWithClassName:@"SOVideo"];
                 [videoQuery whereKey:@"objectId" containedIn:firstVideoIds];
                 [videoQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
                  {
                      if(!error)
                      {
                          for(int i = 0; i < objects.count ; i++)
                          {
                              NSMutableArray<SOVideo *> *videoArray = [NSMutableArray<SOVideo *> new];
                              SOVideo *firstVideo = (SOVideo *)objects[i];
                              [videoArray addObject:firstVideo];
                              [shoutoutArrayOfUnassignedVideosArray addObject:videoArray];
                          }
                          if(shoutoutArrayOfUnassignedVideosArray.count == orderedShoutouts.count)
                          {
                              NSMutableArray<SOShoutout *> *shoutoutsArray =  [self matchVideosArray:shoutoutArrayOfUnassignedVideosArray withShoutoutArray:orderedShoutouts];

                              onCompletion(shoutoutsArray);
                          }
                      }
                      else{
                          NSLog(@"Error %@",[error localizedDescription]);
                      }
                  }];
             }
             else
             {
                 NSLog(@"Error %@", [error localizedDescription]);
             }
         }
     }];
}

- (void)fetchAllShoutouts:(void (^) (NSMutableArray <SOShoutout *> *shoutoutsCollaborationsArray))onCompletion{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"receipients == %@",[User currentUser].username];
    PFQuery *query = [PFQuery queryWithClassName:@"SOShoutout" predicate:pred];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
     {
         if (!error)
         {
             if (objects.count >0)
             {
                 NSMutableArray<SOShoutout *> *orderedShoutouts = [NSMutableArray arrayWithArray:[objects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]]];
                 
                 NSMutableArray<NSMutableArray <SOVideo *> *> * shoutoutArrayOfUnassignedVideosArray = [NSMutableArray<NSMutableArray <SOVideo *> *> new];
                 
                 NSMutableArray<NSString *> *firstVideoIds = [NSMutableArray<NSString *> new];
                 for (SOShoutout *shoutout in orderedShoutouts)
                 {
                     NSString *firstVideoID = shoutout.videosArray[0].objectId;
                     [firstVideoIds addObject:firstVideoID];
                 }
                 PFQuery *videoQuery = [PFQuery queryWithClassName:@"SOVideo"];
                 [videoQuery whereKey:@"objectId" containedIn:firstVideoIds];
                 [videoQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
                  {
                      if(!error)
                      {
                          for(int i = 0; i < objects.count ; i++)
                          {
                              NSMutableArray<SOVideo *> *videoArray = [NSMutableArray<SOVideo *> new];
                              SOVideo *firstVideo = (SOVideo *)objects[i];
                              [videoArray addObject:firstVideo];
                              [shoutoutArrayOfUnassignedVideosArray addObject:videoArray];
                          }
                          if(shoutoutArrayOfUnassignedVideosArray.count == orderedShoutouts.count)
                          {
                              NSMutableArray<SOShoutout *> *shoutoutsArray =  [self matchVideosArray:shoutoutArrayOfUnassignedVideosArray withShoutoutArray:orderedShoutouts];
                              
                              onCompletion(shoutoutsArray);
                          }
                      }
                      else{
                          NSLog(@"Error %@",[error localizedDescription]);
                      }
                  }];
             }
             else
             {
                 NSLog(@"Error %@", [error localizedDescription]);
             }
         }
     }];
}

-(NSMutableArray<SOShoutout *> *)matchVideosArray:(NSMutableArray<NSMutableArray<SOVideo *> *> *) videosArray withShoutoutArray:(NSMutableArray<SOShoutout *> *)shoutoutArray
{
    NSMutableArray<SOShoutout *> *correctShoutoutsArray = [NSMutableArray<SOShoutout *> new];
    for(int i=0; i < shoutoutArray.count ; i++)
    {
        SOShoutout *shoutout = shoutoutArray[i];
        NSString *firstVideoInShoutoutObjectID = shoutout.videosArray[0].objectId;

        for(int j=0 ; j < videosArray.count ; j++)
        {
            NSMutableArray<SOVideo *> *currentArrayOfSOVideos = videosArray[j];

            SOVideo *firstVideo = currentArrayOfSOVideos[0];
            NSString *firstVideoObjectID = firstVideo.objectId;

            if([firstVideoInShoutoutObjectID isEqualToString:firstVideoObjectID])
            {
                [shoutout.videosArray replaceObjectAtIndex:0 withObject:firstVideo];

                [videosArray removeObject:currentArrayOfSOVideos];

                [correctShoutoutsArray addObject:shoutout];
                break;
            }
        }
    }
    return correctShoutoutsArray;
}

-(void)fetchCompleteShoutoutVideosforShoutout:(void(^)(BOOL success))onCompletion;
{
    if(self.videosArray.count > 1){

        NSArray<NSString *> *videoIDsArray = [self.videosArray valueForKey:@"objectId"];


        PFQuery *query = [PFQuery queryWithClassName:@"SOVideo"];
        [query whereKey:@"objectId" containedIn:videoIDsArray];

        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (!error)
            {
                NSMutableArray<SOVideo *> *videos = [NSMutableArray arrayWithArray:objects];
                [videos sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]]];

                self.videosArray = videos;
                [[SOCachedProjects sharedManager].cachedProjects setObject:self forKey:self.objectId];
                onCompletion(YES);
            }
            else{
                onCompletion(NO);
            }
        }];

    }
    else{
        onCompletion(YES);
    }
}


- (void)fetchIfUpdatesAvailable:(void (^) (NSMutableArray <SOShoutout *> *shoutoutsCollaborationsArray, NSMutableArray <SOShoutout *> *shoutoutsReceipientsArray))onCompletion
{
    
}


@end
