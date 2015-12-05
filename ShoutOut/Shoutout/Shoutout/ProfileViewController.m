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
#import "SOCachedProjects.h"
#import "ResultTableViewController.h"

#import <Contacts/Contacts.h>
#import <ChameleonFramework/Chameleon.h>

#import <Parse/Parse.h>

typedef enum eventsType{
    
    FRIENDS = 0,
    CONTACTS_LIST
    
} EventsType;


@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,
UISearchControllerDelegate, UISearchResultsUpdating>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
// friend's contact
@property (nonatomic) NSMutableArray <Contact *> *contactsFromPhoneBook;
@property (nonatomic) NSMutableArray <NSString *> *currentUserContacts;
@property (nonatomic) NSMutableArray *phoneBookUserName;
@property (nonatomic) NSMutableArray *phoneBookName;

// filtered list
@property (nonatomic) NSMutableArray <NSString *> *currentUserFilterContacts;
@property (nonatomic) NSMutableArray *phoneBookFilterUserName;
@property (nonatomic) NSMutableArray *phoneBookFilterName;

@property (nonatomic, strong) APAddressBook *addressBook;
@property (nonatomic) BOOL isOnContact;
@property (nonatomic) BOOL isAnimating;
@property (nonatomic) BOOL isFetching;


@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
//@property (nonatomic, strong) UISearchController *searchController;
//@property (nonatomic, strong) ResultTableViewController *resultTableViewController;

@end

@implementation ProfileViewController{
    EventsType currentEventType;
}
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.isOnContact = NO;
    self.isFetching = NO;
    
    // searchbar
//    self.resultTableViewController = [[ResultTableViewController alloc] init];
//    self.searchController = [UISearchController alloc]initWithSearchResultsController:self.resultTableViewController];
//    self.searchController.searchResultsUpdater = self;
//    self.searchController.searchBar.placeholder = @"Search by Name, Username, or Phone Number";
//    [self.searchController.searchBar sizeToFit];
//    self.tableView.tableHeaderView = self.searchController.searchBar;
//    
//    self.resultTableViewController.tableView.delegate = self;
//    self.searchController.delegate = self;
//    self.searchController.dimsBackgroundDuringPresentation = YES;
//    self.searchController.searchBar.delegate = self;
//    
//    self.definesPresentationContext = YES;
    
        [self queryCurrentUserContactsListOnParse];
    self.contactsFromPhoneBook  = [NSMutableArray new];
    
    [self queryPhoneBookContact];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"34A6FF"];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"futura-medium" size:25]}];
    self.navigationItem.title = @"Friends";
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
        self.currentUserContacts = [NSMutableArray new];
        [self queryCurrentUserContactsListOnParse];
        self.isOnContact = NO;
        
    } else {
        
        self.isOnContact = YES;
        self.contactsFromPhoneBook  = [NSMutableArray new];
        
        [self queryPhoneBookContact];
        
    }
    if (self.isAnimating || (sender.tag ==0 && currentEventType == FRIENDS) || (sender.tag == 1 && currentEventType == CONTACTS_LIST)) {
        return;
    }
//    [self animateUnderlineBar];
}

-(IBAction)addButtonTapped:(UIButton *)sender{
    NSLog(@"%@", self.phoneBookUserName[sender.tag]);
    
    [SORequest sendRequestTo:self.phoneBookUserName[sender.tag] withBlock:^(BOOL succeeded) {
        NSString *failedTitle = @"Request Send Failed";
        NSString *failedMessage = [NSString stringWithFormat: @"Previous request still pending. Please wait until %@ to respond before sending another one", self.phoneBookName[sender.tag]];
        NSString *succeededTitle = @"Awesome!";
        NSString *succeededMessage = @"Request Send";
        
        if (succeeded) {
            [self friendRequestSendSucceededWithTitle:succeededTitle andMessage:succeededMessage];
        } else {
            [self friendRequestSendSucceededWithTitle:failedTitle andMessage:failedMessage];
        }
    }];

}

-(void)friendRequestSendSucceededWithTitle:(NSString *)title  andMessage:(NSString *)message{
    UIAlertController *requestSendStatus = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [requestSendStatus addAction:ok];
    [self presentViewController:requestSendStatus animated:YES completion:nil];
}

#pragma mark - Animation
//- (void)animateUnderlineBar{
//    
//    if (!self.isAnimating) {
//        
//        CGFloat newX = currentEventType == FRIENDS? self.underlineBar.bounds.size.width : 0;
//        CGRect newFrame = CGRectMake(newX, self.underlineBar.frame.origin.y, self.underlineBar.bounds.size.width, self.underlineBar.bounds.size.height);
//        
//        self.isAnimating = YES;
//        
//        [UIView animateWithDuration:.25f animations:^{
//            
//            self.underlineBar.frame = newFrame;
//            
//        } completion:^(BOOL finished) {
//            
//            self.isAnimating = NO;
//            currentEventType = currentEventType == FRIENDS? CONTACTS_LIST : FRIENDS;
//        }];
//        
//    }
//    
//}



-(void)queryPhoneBookContact{
    
    if (self.isFetching == NO) {
        self.isFetching = YES;
        self.addressBook = [[APAddressBook alloc]init];
        self.addressBook.fieldsMask = APContactFieldAll;
        self.addressBook.filterBlock = ^BOOL(APContact *contact) {
            return contact.phones.count > 0;
        };
        self.addressBook.sortDescriptors = @[
                                             [NSSortDescriptor sortDescriptorWithKey:@"name.firstName" ascending:YES],
                                             [NSSortDescriptor sortDescriptorWithKey:@"name.lastName" ascending:YES]];
        
        [self.addressBook loadContacts:^(NSArray<APContact *> * _Nullable contacts, NSError * _Nullable error) {
            if (!error) {
                self.phoneBookName = [NSMutableArray new];
                self.phoneBookUserName = [NSMutableArray new];
                Contact *queryParse = [Contact new];
                [queryParse contactsQueryParseBaseOnPhoneBook: contacts withBlock:^(NSMutableDictionary *namesForNumbers, NSArray<User *> *users) {
                    for (User *user in users) {
                        NSString *phoneNumber = user.phoneNumber;
                        NSString *phoneBookName = [namesForNumbers objectForKey:phoneNumber];
                        [self.phoneBookUserName addObject:user.username];
                        [self.phoneBookName addObject:phoneBookName];
                    }
                    [self.tableView reloadData];
                    self.isFetching = NO;
                }];
            } else {
                NSLog(@"Error!!! == %@",error);
            }
            
        }];
    }
    
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
                    [SORequest sendRequestTo:searchedUser.username withBlock:nil];
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
                    [SORequest sendRequestTo:searchedUser.username withBlock:nil];
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
    
    if(currentUser.contacts != nil && self.isFetching == NO){
        self.isFetching = YES;
        PFQuery *query1 = [PFQuery queryWithClassName:@"SOContacts"];
        [query1 whereKey:@"objectId" equalTo:currentUser.contacts.objectId];
        
        [query1 findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (objects.count > 0) {
                SOContacts *contact = objects[0];
                
                self.currentUserContacts = [[NSMutableArray alloc]initWithArray:contact.contactsList];
                [self.tableView reloadData];
            }
            else{
                NSLog(@"query contacts ERROR == %@",error);
            }
            self.isFetching = NO;
        }];
        [self checkSORequestStatus];
    }
}

-(void)checkSORequestStatus {
    
    if (self.isFetching == NO) {
        self.isFetching = YES;
        PFQuery *query = [PFQuery queryWithClassName:@"SORequest"];
        [query whereKey:@"requestSentTo" equalTo:[User currentUser].username];
        [query whereKey:@"isFriendRequest" equalTo:[NSNumber numberWithBool:YES]];
        [query whereKey:@"hasDecided" equalTo:[NSNumber numberWithBool:NO]];
        [query whereKey:@"isAccepted" equalTo:[NSNumber numberWithBool:NO]];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            NSLog(@"SORequest %@",objects);
            for (SORequest *newRequest in objects){
                
                if (!newRequest.hasDecided && !newRequest.isAccepted){
                    
                    for (NSString *friend in self.currentUserContacts) {
                        if ([newRequest.requestSentFrom isEqualToString:friend]) {
                            NSLog(@"you already have %@ on your list", newRequest.requestSentFrom);
                        } else {
                            [self newRequestReceivedAlertWithSORequestObject:newRequest];
                        }
                    }
                    
                }
            }
            self.isFetching = NO;
        }];
        
        PFQuery *queryRequestResult = [PFQuery queryWithClassName:@"SORequest"];
        [queryRequestResult whereKey:@"requestSentFrom" equalTo:[User currentUser].username];
        [queryRequestResult whereKey:@"isFriendRequest" equalTo:[NSNumber numberWithBool:YES]];
        [queryRequestResult whereKey:@"hasDecided" equalTo:[NSNumber numberWithBool:YES]];
        [queryRequestResult whereKey:@"isAccepted" equalTo:[NSNumber numberWithBool:YES]];
        [queryRequestResult findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            self.isFetching = YES;
            for (SORequest *requestResult in objects) {
                for (NSString *username in self.currentUserContacts) {
                    if (![requestResult.requestSentTo isEqualToString:username]) {
                        [self.currentUserContacts addObject:requestResult.requestSentTo];
                    }
                }
                
            }
            [self pushContactListToParse];
            self.isFetching = NO;
        }];
    }

    
}

//-(void)newRequestReceivedAlert:(NSString *)newFriend withSORequestObject: (SORequest *)parseObject{
-(void)newRequestReceivedAlertWithSORequestObject: (SORequest *)parseObject{
    UIAlertController *newFriendRequest = [UIAlertController alertControllerWithTitle:@"New Request" message:[NSString stringWithFormat:@"%@ wants to add you",parseObject.requestSentFrom] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ignore = [UIAlertAction actionWithTitle:@"Ignore" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        parseObject.isAccepted = NO;
        parseObject.hasDecided = YES;
        [parseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            NSLog(@"saved reject BOOL value to parse");
        }];
        [newFriendRequest dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *accept = [UIAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        parseObject.isAccepted = YES;
        parseObject.hasDecided = YES;
        [parseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            NSLog(@"saved accept BOOL value in parse");
        }];
        [self.currentUserContacts addObject:parseObject.requestSentFrom];
        [self pushContactListToParse];
    }];
    
    [newFriendRequest addAction:ignore];
    [newFriendRequest addAction:accept];
    
    [self presentViewController:newFriendRequest animated:YES completion:nil];
}

-(void)pushContactListToParse{
    if (self.isFetching == NO) {
        self.isFetching = YES;
        [User currentUser].contacts.contactsList = self.currentUserContacts;
        [[User currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            NSLog(@"new contact list saved to parse");
        }];
        [self.tableView reloadData];

    }
    self.isFetching =NO;
}


#pragma - mark UITableView Delegate and DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 3;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        switch (section) {
            case 0:
                return self.currentUserFilterContacts.count;
                break;
            case 1:
                return self.phoneBookFilterName.count;
                break;
            default:
                break;
        }
        
    } else {
        switch (section) {
            case 0:
                return self.currentUserContacts.count;
                break;
            case 1:
                return self.phoneBookName.count;
                break;
            default:
                break;
        }
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    switch (section) {
        case 0:
            return @"Friends List";
            break;
        case 1:
            return @"PhoneBook Contacts";
            break;
        default:
            return nil;
            break;
    }
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        if (indexPath.section == 1) {
            
            PhoneContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"currentUserContactsCellID" forIndexPath:indexPath];
            
            UIButton *addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [addButton setTag:indexPath.row];
            addButton.frame = CGRectMake(cell.bounds.size.width - 45.0f, 5.0f, 40.0f, 40.0f);
            addButton.backgroundColor = [UIColor greenColor];
            [addButton setTitle:@"+" forState:UIControlStateNormal];
            [addButton addTarget:self action:@selector(addButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:addButton];
            
            cell.nameLabel.text = self.phoneBookFilterName[indexPath.row];
            cell.phoneNumberLabel.text = self.phoneBookFilterUserName[indexPath.row];
            return cell;
            
        } else if (indexPath.section == 0){
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addByUserNameCellID2" forIndexPath:indexPath];
            cell.textLabel.text = self.currentUserContacts[indexPath.row - 1];
            return cell;
        }
        
    } else {
        
        if (indexPath.section == 1) {
            
            PhoneContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"currentUserContactsCellID" forIndexPath:indexPath];
            
            UIButton *addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [addButton setTag:indexPath.row];
            addButton.frame = CGRectMake(cell.bounds.size.width - 45.0f, 5.0f, 40.0f, 40.0f);
            addButton.backgroundColor = [UIColor greenColor];
            [addButton setTitle:@"+" forState:UIControlStateNormal];
            [addButton addTarget:self action:@selector(addButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:addButton];
            
            cell.nameLabel.text = self.phoneBookName[indexPath.row];
            cell.phoneNumberLabel.text = self.phoneBookUserName[indexPath.row];
            return cell;
            
        } else if (indexPath.section == 0){
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addByUserNameCellID2" forIndexPath:indexPath];
            cell.textLabel.text = self.currentUserContacts[indexPath.row - 1];
            return cell;
        }
    }
    return nil;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}



#pragma mark - SearchFilter

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self filterContentForSearchText:searchText];
    [self.tableView reloadData];
}


-(void)filterContentForSearchText:(NSString *)searchText{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@",searchText];
    // filter by username
    self.currentUserFilterContacts = [self.currentUserContacts filteredArrayUsingPredicate:predicate];
    
    self.phoneBookFilterName = [self.phoneBookName filteredArrayUsingPredicate:predicate];
    
    self.phoneBookFilterUserName = [self.phoneBookUserName filteredArrayUsingPredicate:predicate];
    
}






#pragma mark - search result update

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *searchText = searchController.searchBar.text;
    
    if (searchText == nil) {
        NSLog(@"DO NOTHING search textfield is empty");
    } else {
        
    }
    
}






@end
