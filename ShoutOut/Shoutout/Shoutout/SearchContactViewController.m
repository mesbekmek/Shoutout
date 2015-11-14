//
//  SearchContactViewController.m
//  Shoutout
//
//  Created by Jason Wang on 11/13/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SearchContactViewController.h"
#import <Parse/Parse.h>

@interface SearchContactViewController ()
@property (nonatomic) NSArray *friendRequestPendingArray;

@end

@implementation SearchContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PFQuery *query = [PFQuery queryWithClassName:@"SORequest"];
    [query whereKey:@"requestSentTo" equalTo:[PFUser currentUser][@"username"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error) {
            self.friendRequestPendingArray = objects;
            NSLog(@"pending request == %@",objects);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
