//
//  ProfileViewController.m
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 11/8/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "SOModel.h"

@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *currentUserContacts;

@end

@implementation ProfileViewController
- (IBAction)backButtonTapped:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)settingButtonTapped:(UIButton *)sender {
    
}

- (IBAction)friendContactsButtonTapped:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"Friends"]) {
        [self queryCurrentUserContactsListOnParse];
    } else {
        self.currentUserContacts = [NSMutableArray new];
        [self.tableView reloadData];
        NSLog(@"contacts TVC");
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.navigationController.navigationBarHidden = YES;
    
    [self queryCurrentUserContactsListOnParse];

    
}

-(void)queryCurrentUserContactsListOnParse{
    User *currentUser = [User currentUser];
    
    PFQuery *query1 = [PFQuery queryWithClassName:@"SOContacts"];
    [query1 whereKey:@"objectId" equalTo:currentUser.contacts.objectId];
    
    [query1 findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count > 0) {
            SOContacts *contact = objects[0];
            
            for (NSString *name in contact.contactsList) {
                NSLog(@"Contact from Parse == %@",name);
            }
            
            self.currentUserContacts = [[NSMutableArray alloc]initWithArray:contact.contactsList];
            [self.tableView reloadData];
        }
        else{
            NSLog(@"query contacts ERROR == %@",error);
        }
    }];
    
    
//        [self checkSORequestStatus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"DID RECEIVE MEMORY WARNING!!!!");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.currentUserContacts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"currentUserContactsCellID" forIndexPath:indexPath];
    cell.textLabel.text = self.currentUserContacts[indexPath.row];
    
    return cell;
}

@end
