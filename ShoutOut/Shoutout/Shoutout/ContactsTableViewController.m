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
    
    /*
     PFQuery *query = [PFQuery queryWithClassName:@"SORequest"];
     [query whereKey:@"requestSentTo" equalTo:[PFUser currentUser].username];
     NSLog(@"username == %@",[PFUser currentUser].username);
     [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
     if (!error) {
     self.friendRequestPendingArray = objects;
     NSLog(@"pending request == %@",objects);
     }
     }];
     */
    
}

- (IBAction)addContactButtonTapped:(UIBarButtonItem *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Search user" message:@"Enter username" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"username";
//        textField.text;
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *search = [UIAlertAction actionWithTitle:@"Search" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *username = alert.textFields[0].text;
        NSLog(@"user name entered == %@",username);
        
        
    }];
    
    [alert addAction:cancel];
    [alert addAction:search];
    
    [self presentViewController:alert animated:YES completion:nil];
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
