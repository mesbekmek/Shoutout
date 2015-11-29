//
//  ProfileViewController.m
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 11/8/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "ProfileViewController.h"
#import "SOModel.h"
#import "Contact.h"
#import "PhoneContactTableViewCell.h"
#import "APAddressBook.h"
#import "APContact.h"
#import "APPhone.h"

#import <Contacts/Contacts.h>
#import <Parse/Parse.h>

@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *currentUserContacts;
@property (nonatomic) NSMutableArray <Contact *> *contactsFromPhoneBook;
@property (nonatomic) BOOL isOnContact;

//@property (nonatomic) NSArray <APContact *> *phoneBookContactList;
@property (nonatomic, strong) APAddressBook *addressBook;
@property (nonatomic) NSMutableArray *phoneBookUserName;
@property (nonatomic) NSMutableArray *phoneBookName;


@end

@implementation ProfileViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.navigationController.navigationBarHidden = YES;
    self.isOnContact = NO;


    
    [self queryCurrentUserContactsListOnParse];
    self.tableView.estimatedRowHeight = 12.0f;
    
    
    
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
        self.isOnContact = NO;
        
    } else {
        
        
        self.isOnContact = YES;
        self.contactsFromPhoneBook  = [NSMutableArray new];
        
        [self quryPhoneBookContact];
        
//        Contact *queryContact = [Contact new];
//        [queryContact contactsQuery:^(NSMutableArray<Contact *> *allContacts, BOOL didComplete) {
//            
//            if (didComplete) {
//                
//                self.contactsFromPhoneBook = allContacts;
//                [self.tableView reloadData];
//            }
//        }];
//        //[self grabDeviceContacts];
//        
//        [self.tableView reloadData];
//        NSLog(@"contacts TVC");
    }
    
}

-(void)quryPhoneBookContact{
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

- (IBAction)addFriendsByUserButtonTapped:(UIButton *)sender {
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



#pragma mark - Phonebook Contact List

//-(void)grabDeviceContacts{
//    CNContactStore *store = [[CNContactStore alloc]init];
//    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
//        if (granted == YES) {
//            NSArray *keys = @[CNContactGivenNameKey, CNContactPhoneNumbersKey];
//            NSString *containerId = store.defaultContainerIdentifier;
//            NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
//            NSError *error;
//            NSArray *cnContact = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
//            if (error) {
//                NSLog(@"Error fetching contacts %@",error);
//            } else {
//
//                for (CNContact *contact in cnContact) {
//                    Contact *newContact = [[Contact alloc]initWithPhoneNumberArray];
//                    newContact.firstName = contact.givenName;
//                    NSLog(@"first name %@",newContact.firstName);
////                    newContact.lastName = contact.familyName;
//
//                    for (CNLabeledValue *label in contact.phoneNumbers) {
//                        NSString *phoneNumber = [label.value stringValue];
//                        if (phoneNumber != nil) {
//                            [newContact.phoneNumber addObject:[label.value stringValue]];
//                            NSLog(@"phone number %@", newContact.phoneNumber);
//                        } else {
//                            [newContact.phoneNumber addObject:@"N/A"];
//                        }
//                    }
//
//                    [self.contactsFromPhoneBook addObject:newContact];
//                    NSLog(@"adding to contacts from phone book array");
//
//                }
//                NSLog(@"%@ \ncount:%lu",self.contactsFromPhoneBook,self.contactsFromPhoneBook.count);
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:nil];
//            }
//        }
//    }];
//
//}

- (void)callReload{
    [self.tableView reloadData];
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
}

#pragma mark - Pase Contact List
-(void)checkUsernameInParseWithName:(NSString *)enteredName {
    
    if ([enteredName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length != 0) {
        
        
        PFQuery *query = [User query];
        
        [query whereKey:@"username" equalTo:enteredName];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            NSLog(@"object count = %lu",objects.count);
            if (objects.count == 0) {
                NSLog(@"NO USER FOUND");
                [self noUserFoundAlert];
            }
            
            
            User *searchedUser = objects[0];
            if (!error && ![searchedUser.username isEqualToString:[User currentUser].username]) {
                NSLog(@"match");
                // matched and wants to add user
                if (![self checkDuplicateConctact:searchedUser.username]) {
                    [self.tableView reloadData];
                    [SORequest sendRequestTo:searchedUser.username];
                } else {
                    [self contactDuplicateAlert];
                }
            } else {
                NSLog(@"can't add yourself");
            }
        }];
    }
}

//-(void)sendFriendRequest:(NSString *)user {
//    [SORequest sendRequestTo:user];
//}

-(void)checkUsernameInParseWithPhoneNumber:(NSString *)phoneNumber {
    
    if ([phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 10) {
        
        
        PFQuery *query = [User query];
        
        [query whereKey:@"phoneNumber" equalTo:phoneNumber];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            NSLog(@"object count = %lu",objects.count);
            if (objects.count == 0) {
                NSLog(@"NO USER FOUND");
                [self noUserFoundAlert];
            }
            User *searchedUser = objects[0];
            if (!error && ![searchedUser.phoneNumber isEqualToString:[User currentUser].phoneNumber]) {
                NSLog(@"match");
                // matched and wants to add user
                if (![self checkDuplicateConctact:searchedUser.username]) {
                    [self.tableView reloadData];
                    [SORequest sendRequestTo:searchedUser.username];
                } else {
                    [self contactDuplicateAlert];
                }
            } else {
                NSLog(@"can't add yourself or there's an Error %@", error);
            }
        }];
    }
}

-(void)noUserFoundAlert {
    UIAlertController *noUserAlert = [UIAlertController alertControllerWithTitle:@"No User Found" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [noUserAlert addAction:ok];
    [self presentViewController:noUserAlert animated:YES completion:nil];
}

-(void)contactDuplicateAlert {
    UIAlertController *duplicateAlert = [UIAlertController alertControllerWithTitle:@"Contact Already Saved" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [duplicateAlert dismissViewControllerAnimated:YES completion:nil];
    }];
    [duplicateAlert addAction:ok];
    [self presentViewController:duplicateAlert animated:YES completion:nil];
}

-(BOOL)checkDuplicateConctact:(NSString *)username {
    for (int i = 0; i < self.currentUserContacts.count; i++) {
        if ([username isEqualToString:self.currentUserContacts[i]]) {
            return 1;
        }
    }
    return 0;
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

//-(void)addSelfToFromRequest:(SORequest *)request{
//
//
//}



#pragma - mark UITableView Delegate and DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isOnContact) {
//        return self.contactsFromPhoneBook.count;
//        return self.phoneBookContactList.count;
        return self.phoneBookName.count;
    } else {
        return self.currentUserContacts.count + 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.isOnContact) {
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [addButton setTag:indexPath.row];
        addButton.frame = CGRectMake(330.0f, 5.0f, 40.0f, 40.0f);
        addButton.backgroundColor = [UIColor greenColor];
        [addButton setTitle:@"+" forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(addButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        PhoneContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"currentUserContactsCellID" forIndexPath:indexPath];
//        cell.nameLabel.text = self.contactsFromPhoneBook[indexPath.row].firstName;
//        cell.phoneNumberLabel.text = self.contactsFromPhoneBook[indexPath.row].phoneNumber[0];
        
//        NSString *lastName;
//        if (!self.phoneBookContactList[indexPath.row].name.lastName) {
//            lastName = @"";
//        } else {
//            lastName = self.phoneBookContactList[indexPath.row].name.lastName;
//        }
//        
//        cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@",self.phoneBookContactList[indexPath.row].name.firstName, lastName];
//        cell.phoneNumberLabel.text = self.phoneBookContactList[indexPath.row].phones[0].number;
        
        cell.nameLabel.text = self.phoneBookUserName[indexPath.row];
        cell.phoneNumberLabel.text = self.phoneBookName[indexPath.row];
        
        
        [cell addSubview:addButton];
        return cell;
    } else {
        if (indexPath.row == 0){
            UITableViewCell *addFriendCell = [tableView dequeueReusableCellWithIdentifier:@"addByUserNameCellID" forIndexPath:indexPath];
            return addFriendCell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addByUserNameCellID2" forIndexPath:indexPath];
            cell.textLabel.text = self.currentUserContacts[indexPath.row - 1];
            return cell;
        }
    }
}

-(void)addButtonTapped:(UIButton *)sender{
    NSLog(@"Button tapped %ld", sender.tag);
//    NSString *selectedPhoneNumber = self.phoneBookContactList[sender.tag].phones[0].number;
//    NSLog(@"phone number selected = %@",selectedPhoneNumber);
//    NSString *formatedPhoneNumber = [[selectedPhoneNumber componentsSeparatedByCharactersInSet:
//                                      [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
//                                     componentsJoinedByString:@""];
//    if ([formatedPhoneNumber length] == 10) {
//        
//        [self checkUsernameInParseWithPhoneNumber:formatedPhoneNumber];
//        NSLog(@"Number selected %@",formatedPhoneNumber);
//        
//    } else if ([formatedPhoneNumber length] == 11 && [formatedPhoneNumber hasPrefix:@"1"]) {
//        
//        [self checkUsernameInParseWithPhoneNumber:[formatedPhoneNumber substringFromIndex:1]];
//        NSLog(@"Number selected %@",[formatedPhoneNumber substringFromIndex:1]);
//        
//    }
}

-(void)formatePhoneNumberToDigitsOnly:(NSString *)phoneNumber{
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isOnContact) {
        return 50.0;
    } else {
        if (indexPath.row > 0) {
            return 40.0;
        } else {
            return 70.0;
        }
    }
    
}

@end
