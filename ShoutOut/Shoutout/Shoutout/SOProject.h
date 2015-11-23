//
//  SOProject.h
//  Shoutout
//
//  Created by Varindra Hart on 11/8/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <Parse/Parse.h>
#import "User.h"
#import "SOVideo.h"

//const NSInteger maxVideos = 12;

@interface SOProject : PFObject <PFSubclassing>

@property (nonatomic) NSString *createdBy;
@property (nonatomic) NSMutableArray <SOVideo*> *videos;
@property (nonatomic) NSMutableArray <SOVideo*> *collaboratorSentVideos;
@property (nonatomic) NSMutableArray <NSString *> *collaboratorsSentTo;
@property (nonatomic) NSMutableArray <NSString *> *collaboratorsReceivedFrom;
@property (nonatomic) NSMutableArray <NSString *> *collaboratorsDeclined;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *description;
@property (nonatomic) NSDate *endDate;
@property (nonatomic) SOVideo *shoutout;
@property (nonatomic) BOOL isCompleted;
@property (nonatomic) BOOL collaboratorHasAddedVideo;

+(NSString *)parseClassName;

//May be used if user is signed into parse
-(instancetype)initWithTitle:(NSString *)title;

//Use this method if the user has not yet signed up on Parse
-(instancetype)initWithUUID:(NSString *)uuid;

- (void)reindexVideos;

-(void)fetchVideos:(void (^)(NSMutableArray <SOVideo *> *fetchedVideos,
                             NSMutableArray <AVAsset *> *fetchedVideoAssets,
                             NSMutableArray <PFFile *>* thumbnails) )onCompletion;

- (void)getNewVideosIfNeeded:(void (^)(NSMutableArray <SOVideo *>*fetchedVideos,
                                       NSMutableArray <AVAsset *> *avAssets,
                                       NSMutableArray <PFFile *>*allThumbnails)) onCompletion;

@end
