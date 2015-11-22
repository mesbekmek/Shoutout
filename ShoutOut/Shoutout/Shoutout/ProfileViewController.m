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
- (IBAction)addByUserNameButtonTapped:(UIButton *)sender {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.navigationController.navigationBarHidden = YES;
    
    [self queryCurrentUserContactsListOnParse];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"DID RECEIVE MEMORY WARNING!!!!");
}

#pragma - mark IBAction
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
    
    
        [self checkSORequestStatus];
}

-(void)checkSORequestStatus {
    PFQuery *query = [PFQuery queryWithClassName:@"SORequest"];
    [query whereKey:@"requestSentTo" equalTo:[User currentUser].username];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
     {
         NSLog(@"SORequest %@",objects);
         for (SORequest *newRequest in objects){
             
             if (!newRequest.hasDecided && !newRequest.isAccepted){
                 
                 [self newRequestReceivedAlert:newRequest.requestSentFrom withSORequestObject:newRequest];
             }
         }
     }];
    
    PFQuery *queryRequestResult = [PFQuery queryWithClassName:@"SORequest"];
    [queryRequestResult whereKey:@"requestSentFrom" equalTo:[User currentUser].username];
    [queryRequestResult findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        for (SORequest *requestResult in objects) {
            if (requestResult.hasDecided && requestResult.isAccepted) {
                [self.currentUserContacts addObject:requestResult.requestSentTo];
                [self pushContactListToParse];
            }
        }
    }];
    
}

-(void)newRequestReceivedAlert:(NSString *)newFriend withSORequestObject: (SORequest *)object{
    UIAlertController *newFriendRequest = [UIAlertController alertControllerWithTitle:@"New Request" message:[NSString stringWithFormat:@"%@ wants to add you",newFriend] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ignore = [UIAlertAction actionWithTitle:@"Ignore" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        object.isAccepted = NO;
        object.hasDecided = YES;
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            NSLog(@"saved reject BOOL value to parse");
        }];
        [newFriendRequest dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *accept = [UIAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        object.isAccepted = YES;
        object.hasDecided = YES;
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            NSLog(@"saved accept BOOL value in parse");
        }];
        [self.currentUserContacts addObject:newFriend];
        [self pushContactListToParse];
//        [self addSelfToFromRequest:object];
    }];
    
    [newFriendRequest addAction:ignore];
    [newFriendRequest addAction:accept];
    
    [self presentViewController:newFriendRequest animated:YES completion:nil];
}

-(void)pushContactListToParse{
    
    [User currentUser].contacts.contactsList = self.currentUserContacts;
    [[User currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"new contact list saved to parse");
    }];
    [self.tableView reloadData];
}

//-(void)addSelfToFromRequest:(SORequest *)request{
//    
//    
//}



#pragma - mark UITableView Delegate and DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.currentUserContacts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0){
        UITableViewCell *addFriendCell = [tableView dequeueReusableCellWithIdentifier:@"addByUserNameCellID" forIndexPath:indexPath];
        return addFriendCell;
    } else {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"currentUserContactsCellID" forIndexPath:indexPath];
    cell.textLabel.text = self.currentUserContacts[indexPath.row +1];
    
    return cell;
    }
}

@end
