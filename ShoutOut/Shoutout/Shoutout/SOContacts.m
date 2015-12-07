//
//  SOContacts.m
//  Shoutout
//
//  Created by Jason Wang on 11/15/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOContacts.h"

@implementation SOContacts

@dynamic contactsList;


+(NSString*)parseClassName{
    
    return @"SOContacts";
}

- (instancetype)initWithNewList{
    
    if (self = [super init]){
        
        self.contactsList = [NSMutableArray new];
        
        return self;
    }
    return nil;
}

- (void)fetchAndReturn:(void (^)(BOOL success))onCompletion{

    PFQuery *query = [PFQuery queryWithClassName:@"SOContacts"];
    [query whereKey:@"objectId" containsString:self.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error) {
            SOContacts *cont = objects[0];
            self.contactsList = cont.contactsList;
            onCompletion(YES);
        }
        else{
            NSLog(@"error in SOContacts");
        }
    }];

}

@end
