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

@interface SOProject : PFObject <PFSubclassing>

@property (nonatomic) NSString *createdBy;
@property (nonatomic) NSMutableArray <SOVideo*> *videos;
@property (nonatomic) NSMutableArray <NSString *> *collaboratorsSentTo;
@property (nonatomic) NSMutableArray <NSString *> *collaboratorsReceivedFrom;
@property (nonatomic) NSMutableArray <NSString *> *collaboratorsDeclined;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *description;
@property (nonatomic) NSDate *endDate;
@property (nonatomic) SOVideo *shoutout;

-(instancetype)initWithTitle:(NSString *)title;
+(NSString *)parseClassName;

-(void)fetchVideos:(void (^)(NSMutableArray <SOVideo *> *fetchedVideos,
                             NSMutableArray <AVAsset *> *fetchedVideoAssets,
                             NSMutableArray <PFFile *>* thumbnails) )onCompletion;
@end
