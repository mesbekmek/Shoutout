//
//  SOShoutout.m
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 11/30/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOShoutout.h"
#import "User.h"

@implementation SOShoutout


@dynamic videosArray;
@dynamic receipients;
@dynamic collaborators;
@dynamic projectTitle;

+ (NSString*)parseClassName{
    return @"SOShoutout";
}

-(instancetype)init{
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

- (void)fetchAllShoutouts:(void (^)(NSMutableArray<SOShoutout *> *, NSMutableArray<SOShoutout *> *))onCompletion{

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"collaborators == %@ OR receipients == %@",[User currentUser].username];
    PFQuery *query = [PFQuery queryWithClassName:@"SOShoutout" predicate:pred];

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {

        if (!error) {
            //doo something

            if (objects.count >0) {
                for (SOShoutout *shoutout in objects){

                    NSArray *videosId = [shoutout.videosArray valueForKey:@"objectId"];
                    PFQuery *videoQuery = [PFQuery queryWithClassName:@"SOVideo"];
                    [videoQuery whereKey:@"objectId" containedIn:videosId];
                    [videoQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {

                        shoutout.videosArray = (NSMutableArray <SOVideo*>*)objects;
                        shoutout.videosArray = (NSMutableArray <SOVideo *>*) [NSMutableArray arrayWithArray: [shoutout.videosArray sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]]]];

                    }];

                }
            }
        }

        else{

        }



    }];




}












@end
