//
//  ContactsTableViewController.m
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 11/8/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "ContactsTableViewController.h"
#import <Parse/Parse.h>


@interface ContactsTableViewController ()

@property (nonatomic) NSArray *allUsers;
@property (nonatomic) NSArray *storeUsersContacts;
@property (nonatomic) NSMutableArray *friendedContacts;
@property (nonatomic) NSArray *currentUserContacts;

@end

@implementation ContactsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFUser *currentUser =  [PFUser currentUser];
    self.currentUserContacts = [currentUser objectForKey:@"contacts"];
    NSLog(@"%@",self.currentUserContacts);
    
//    PFQuery *query = [PFUser query];
//
//    [query whereKey:@"username" containedIn: [currentUser objectForKey:@"contacts"]];
//    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
//        NSLog(@"%@",objects);
//        self.storeUsersContacts = objects;
//        [self grabContacts];
//        NSLog(@"%@",error);
//    }];
    
}

//-(void)grabContacts {
//    for (PFUser *contact in self.storeUsersContacts) {
//        if ([[contact objectForKey:@"contacts"] containsObject: [PFUser currentUser][@"username"]]) {
//            [self.friendedContacts addObject:contact];
//        }
//        NSLog(@"contacts == %@",[contact objectForKey:@"contacts"]);
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentUserContacts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"currentUserContactsCellID" forIndexPath:indexPath];
    cell.textLabel.text = self.currentUserContacts[indexPath.row];
    
    return cell;
}

@end
