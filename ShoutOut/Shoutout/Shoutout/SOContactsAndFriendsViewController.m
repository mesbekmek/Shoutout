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
#import "SOContactsFormatter.h"


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

@property (nonatomic) NSArray<APContact *> *phoneBookContacts;

@property (nonatomic) NSArray<APContact *> *phoneBookContactsWithShoutout;

@property (nonatomic) NSArray<APContact *> *phoneBookContactsWithOutShoutout;

@property (nonatomic) NSMutableDictionary *phoneBookDictionary;

@property (nonatomic) NSMutableDictionary *usernamesForNames;





@end

@implementation SOContactsAndFriendsViewController
{
    ActionType actionType;
}
#pragma mark Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.phoneBookDictionary = [NSMutableDictionary new];
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
            self.phoneBookContacts = contacts;
            self.phoneBookName = [NSMutableArray new];
            self.phoneBookUserName = [NSMutableArray new];
            Contact *queryParse = [Contact new];
            
            [queryParse queryParseContactsBasedOnPhoneBook:contacts withBlock:^(NSMutableDictionary *apContactsForNumbers, NSMutableDictionary *usernameForNumbers) {
                
                NSMutableArray *allKeysOfPhoneContactsNotOnShoutout = [NSMutableArray new];
                for (int i=0; i < [apContactsForNumbers allKeys].count; i++)
                {
                    NSString *apContactPhoneNumber = [NSString stringWithFormat:@"%@",[apContactsForNumbers allKeys][i]];
                    
                    for(int j = 0; j < [usernameForNumbers allKeys].count; j++)
                    {
                        NSString *shoutoutUserPhoneNumber = [NSString stringWithFormat:@"%@",[usernameForNumbers allKeys][j]];
                        
                        if([apContactPhoneNumber isEqualToString:shoutoutUserPhoneNumber]){
                            break;
                        }
                        else if( j == [usernameForNumbers allKeys].count - 1)
                        {
                            [allKeysOfPhoneContactsNotOnShoutout addObject:apContactPhoneNumber];
                        }
                    }
                    
                }
                
                //Contacts without shoutout
              NSArray<SOContactsFormatter *> *contactsWithoutShoutout = [SOContactsFormatter getNameAndPhoneNumberForDictionary:apContactsForNumbers andKeys:allKeysOfPhoneContactsNotOnShoutout];
                //Contacts with shoutout
             NSArray<SOContactsFormatter*>* contactsWithShoutout =    [SOContactsFormatter getNameAndUsernameForDictionary:apContactsForNumbers andDictionary:usernameForNumbers];
                
                [self.phoneBookDictionary setObject:contactsWithShoutout forKey:@"Contacts With Shoutout"];
                [self.phoneBookDictionary setObject:contactsWithoutShoutout forKey:@"Contacts Without Shoutout"];
                
//                self.phoneBookContactsWithShoutout = contacts;
//                
//                self.phoneBookContactsWithOutShoutout = [self getContactsWithoutShout];
                
//                [self.phoneBookDictionary setObject:self.phoneBookContactsWithShoutout forKey:@"Contacts With Shoutout"];
//                [self.phoneBookDictionary setObject:self.phoneBookContactsWithOutShoutout forKey:@"Contacts Without Shoutout"];
                
//                for (User *user in users)
//                {
//                    NSString *phoneNumber = user.phoneNumber;
//                    NSString *phoneBookName = [namesForNumbers objectForKey:phoneNumber];
//                    
//                    [self.phoneBookName addObject:phoneBookName];
//                    [self.phoneBookUserName addObject:user.username];
//                    [self.usernamesForNames setObject:user.username forKey:phoneBookName];
//                    
//                }
                [self.tableView reloadData];
            }];
            
            
            //            [queryParse contactsQueryParseBaseOnPhoneBook: contacts withBlock:^(NSMutableDictionary *namesForNumbers, NSArray<User *> *users) {
            //                for (User *user in users) {
            //                    NSString *phoneNumber = user.phoneNumber;
            //                    NSString *phoneBookName = [namesForNumbers objectForKey:phoneNumber];
            //                    [self.phoneBookUserName addObject:phoneBookName];
            //                    [self.phoneBookName addObject:user.username];
            //                }
            //                [self.tableView reloadData];
            //            }];
        } else {
            NSLog(@"Error!!! == %@",error);
        }
    }];
    
}

-(NSArray<APContact *>*)getContactsWithoutShout{
    NSMutableSet *allContacts = [NSMutableSet setWithArray:self.phoneBookContacts];
    NSMutableSet *allContactsWithShoutout = [NSMutableSet setWithArray:self.phoneBookContactsWithShoutout];
    
    
    
    NSMutableSet *contactsWithShoutout2 = [NSMutableSet new];
    
    for(APContact *contact in allContactsWithShoutout){
        NSString *phone1 = [NSString stringWithFormat:@"%@",contact.phones[0]];
        for(APContact *contact2 in allContacts)
        {
            NSString *phone2 = [NSString stringWithFormat:@"%@",contact2.phones[0]];
            
            if([phone1 isEqualToString:phone2])
            {
                [contactsWithShoutout2 addObject:contact];
                break;
            }
        }
    }
    
    [allContacts minusSet:contactsWithShoutout2];
    
    NSArray<APContact *> *contactsWithoutShout = [allContacts allObjects];
    
    return contactsWithoutShout;
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
        return [self.phoneBookDictionary allKeys].count;
    }
    else
    {
        return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.isOnContact)
    {
        NSArray *array = section == 0 ? self.phoneBookDictionary[@"Contacts With Shoutout"]  : self.phoneBookDictionary[@"Contacts Without Shoutout"];
        
        return array.count;
        
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
        
        if(indexPath.section == 0){
            
            SOContactsFormatter *object = [self.phoneBookDictionary objectForKey:@"Contacts With Shoutout"][indexPath.row];
            
            cell.nameLabel.text = object.name;
            cell.usernameLabel.text = object.username;
        }
        else
        {
            SOContactsFormatter *object = [self.phoneBookDictionary objectForKey:@"Contacts Without Shoutout"][indexPath.row];
            
            cell.nameLabel.text = object.name;
            cell.usernameLabel.text = object.phoneNumber;
        }
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

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(self.isOnContact){
        return section == 0 ? @"Contacts With Shoutout" : @"Contacts Without Shoutout";
    }
    return nil;
}


#pragma mark Title For Header In Section

-(NSString *)titleForHeaderInSection:(NSIndexPath *)indexPath{
    UITableViewHeaderFooterView* header =[self.tableView headerViewForSection:indexPath.section];
    return header.textLabel.text;
}



@end
