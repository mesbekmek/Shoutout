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
@property (nonatomic) NSMutableArray *currentUserContacts;

@end

@implementation ContactsTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *relation = [currentUser relationForKey:@"contactsList"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        NSLog(@"object %@",objects);
        PFObject *contactObject = objects[0];
        self.currentUserContacts = contactObject[@"contactsList"];
        [self.tableView reloadData];
    }];
    
}

- (IBAction)addContactButtonTapped:(UIBarButtonItem *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Search user" message:@"Enter username" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"username";
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *add = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self checkUsernameInParseWithName:alert.textFields[0].text];
    }];
    
    [alert addAction:cancel];
    [alert addAction:add];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)checkUsernameInParseWithName:(NSString *)enteredName {
    PFQuery *query = [PFUser query];
    
    [query whereKey:@"username" containsString:enteredName];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        PFUser *searchedUser = objects[0];
        if (!error && ![searchedUser.username isEqualToString:[PFUser currentUser].username]) {
            NSLog(@"match");
            if (![self checkDouplicateConctact:searchedUser.username]) {
                [self.currentUserContacts addObject:searchedUser.username];
                [self.tableView reloadData];
                [self pushContactListToParse];
            } else {
                [self contactDuplicateAlert];
            }
        } else {
            NSLog(@"can't add yourself");
        }
    }];
}

-(void)contactDuplicateAlert {
    UIAlertController *duplicateAlert = [UIAlertController alertControllerWithTitle:@"Contact Already Saved" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       [duplicateAlert dismissViewControllerAnimated:YES completion:nil];
    }];
    [duplicateAlert addAction:ok];
    [self presentViewController:duplicateAlert animated:YES completion:nil];
}

-(BOOL)checkDouplicateConctact:(NSString *)username {
    for (int i = 0; i < self.currentUserContacts.count; i++) {
        if ([username isEqualToString:self.currentUserContacts[i]]) {
            return 1;
        }
    }
    return 0;
}

-(void)pushContactListToParse{
    
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
