//
//  SOContactsAndFriendsViewController.m
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 11/29/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOContactsAndFriendsViewController.h"
#import "SOContactsTableViewCell.h"
#import "SOFriendsTableViewCell.h"
#import "APAddressBook.h"
#import "APContact.h"
#import "APPhone.h"
#import "Contact.h"


typedef enum actionType{
    
    MY_FRIENDS = 0,
    MY_CONTACTS
} ActionType;


@interface SOContactsAndFriendsViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) BOOL isAnimating;
@property (weak, nonatomic) IBOutlet UIView *underlineBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) APAddressBook *addressBook;
@property (nonatomic) NSMutableArray *phoneBookUserName;
@property (nonatomic) NSMutableArray *phoneBookName;
@property (nonatomic) BOOL isOnContact;
@property (nonatomic) NSMutableArray *currentUserContacts;

@end

@implementation SOContactsAndFriendsViewController
{
    ActionType actionType;
}
#pragma mark Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // SOContacts XIB
    UINib *soContactsNib = [UINib nibWithNibName:@"SOContactsTableViewCell" bundle:nil];
    [self.tableView registerNib:soContactsNib forCellReuseIdentifier:@"ContactsCell"];
    
    // SOFriends XIB
    UINib *soFriendsNib = [UINib nibWithNibName:@"SOFriendsTableViewCell" bundle:nil];
    [self.tableView registerNib:soFriendsNib forCellReuseIdentifier:@"SOFriendsCell"];
    
    [self queryCurrentUserContactsListOnParse];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Friends or Contacts Button Action
- (IBAction)friendsAndContactsButtonTapped:(UIButton *)sender {
    
    if(sender.tag == 0)
    {
        [self queryCurrentUserContactsListOnParse];
        self.isOnContact = NO;
    }
    else
    {
        self.isOnContact = YES;
        [self queryPhoneBookContacts];
    }
    
    
    if (self.isAnimating || (sender.tag == 0 && actionType == MY_FRIENDS) || (sender.tag == 1 && actionType == MY_CONTACTS)) {
        return;
    }
    
    [self animateUnderlineBar];
}
#pragma mark Phone Book Query
-(void)queryPhoneBookContacts{
    //    self.phoneBookContactList = [NSArray new];
    self.addressBook = [[APAddressBook alloc]init];
    self.addressBook.fieldsMask = APContactFieldAll;
    self.addressBook.filterBlock = ^BOOL(APContact *contact)
    {
        return contact.phones.count > 0;
    };
    self.addressBook.sortDescriptors = @[
                                         [NSSortDescriptor sortDescriptorWithKey:@"name.firstName" ascending:YES],
                                         [NSSortDescriptor sortDescriptorWithKey:@"name.lastName" ascending:YES]];
    
    [self.addressBook loadContacts:^(NSArray<APContact *> * _Nullable contacts, NSError * _Nullable error) {
        if (!error) {
            //            self.phoneBookContactList =
            self.phoneBookName = [NSMutableArray new];
            self.phoneBookUserName = [NSMutableArray new];
            Contact *queryParse = [Contact new];
            [queryParse contactsQueryParseBaseOnPhoneBook: contacts withBlock:^(NSMutableDictionary *namesForNumbers, NSArray<User *> *users) {
                for (User *user in users) {
                    NSString *phoneNumber = user.phoneNumber;
                    NSString *phoneBookName = [namesForNumbers objectForKey:phoneNumber];
                    [self.phoneBookUserName addObject:phoneBookName];
                    [self.phoneBookName addObject:user.username];
                }
                [self.tableView reloadData];
            }];
        } else {
            NSLog(@"Error!!! == %@",error);
        }
    }];
    
}


-(void)queryCurrentUserContactsListOnParse{
    User *currentUser = [User currentUser];
    
    if(currentUser.contacts != nil){
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


#pragma mark UnderLineBar Animation
- (void)animateUnderlineBar{
    
    if (!self.isAnimating) {
        
        CGFloat newX = actionType == MY_FRIENDS? self.underlineBar.bounds.size.width : 0;
        CGRect newFrame = CGRectMake(newX, self.underlineBar.frame.origin.y, self.underlineBar.bounds.size.width, self.underlineBar.bounds.size.height);
        
        self.isAnimating = YES;
        
        [UIView animateWithDuration:.25f animations:^{
            
            self.underlineBar.frame = newFrame;
            
        } completion:^(BOOL finished) {
            
            self.isAnimating = NO;
            actionType = actionType == MY_FRIENDS? MY_CONTACTS : MY_FRIENDS;
            
        }];
        
    }
    
}
#pragma mark Navigation
- (IBAction)backButtonTapped:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneButtonTapped:(UIButton *)sender {
}

#pragma mark Tablview data source and delegate methods

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.isOnContact)
    {
        return 2;
    }
    else
    {
        return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.isOnContact)
    {
        return self.phoneBookName.count;
    }
    else
    {
        return self.currentUserContacts.count;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.isOnContact)
    {
        SOContactsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactsCell" forIndexPath:indexPath];
        //So that the cell won't be highlighted when it's tapped
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        //        cell.nameLabel.text = self.phoneBookUserName[indexPath.row];
        //        cell.usernameLabel.text =
        return cell;
    }
    else
    {
        SOFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SOFriendsCell" forIndexPath:indexPath];
        cell.nameLabel.text = self.currentUserContacts[indexPath.row];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
    
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%ld",(long)indexPath.row);
}


@end
