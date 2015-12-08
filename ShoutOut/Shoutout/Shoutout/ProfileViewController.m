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

#import <Contacts/Contacts.h>
#import <ChameleonFramework/Chameleon.h>

#import <Parse/Parse.h>

typedef enum eventsType{
    
    FETCHING = 0,
    FETCHINGCOMPLETED = 1,
    
} FetchingType;


@interface ProfileViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
UISearchBarDelegate,
UISearchDisplayDelegate,
UISearchControllerDelegate
>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
// friend's contact
@property (nonatomic) NSMutableArray <Contact *> *contactsFromPhoneBook;
@property (nonatomic) NSMutableArray <NSString *> *currentUserContacts;
@property (nonatomic) NSMutableArray *phoneBookUserName;
@property (nonatomic) NSMutableArray *phoneBookName;

@property (nonatomic, strong) APAddressBook *addressBook;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic) UITapGestureRecognizer *tapReconizer;
@property (nonatomic) UIRefreshControl *refresh;
@property (nonatomic) NSMutableArray <NSString *> *friendsByUsername;

@end

@implementation ProfileViewController{
    FetchingType fetchingStatus;
}
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    
    self.friendsByUsername = [NSMutableArray new];
    self.currentUserContacts = [NSMutableArray new];
    
    self.refresh = [[UIRefreshControl alloc]init];
    [self.refresh addTarget:self action:@selector(refreshParsePhoneBook:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refresh];
    
    [[User currentUser].contacts fetchAndReturn:^(BOOL success) {
        [self fetchAcceptedRequestUsernames];
    }];
    [self keyboardGestureRecognizer];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //UI color stuff
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"F07179"];
    [[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithHexString:@"F07179"]];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"futura-medium" size:25]}];
    self.navigationItem.title = @"Friends";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"DID RECEIVE MEMORY WARNING!!!!");
}

-(void)refreshParsePhoneBook:(UIRefreshControl *)refControl {
    if ([self.refresh isRefreshing]) {
        [self fetchAcceptedRequestUsernames];
        [self.refresh endRefreshing];
    }
}

#pragma - mark IBAction
-(IBAction)addButtonTapped:(UIButton *)sender{
    NSLog(@"%@", self.phoneBookUserName[sender.tag]);
    
    [SORequest sendRequestTo:self.phoneBookUserName[sender.tag] withBlock:^(BOOL succeeded) {
        NSString *failedTitle = @"Request Pending";
        NSString *failedMessage = [NSString stringWithFormat: @"Previous request still pending. Please wait until %@ to respond before sending another one", self.phoneBookName[sender.tag]];
        NSString *succeededTitle = @"Awesome!";
        NSString *succeededMessage = @"Request Send";
        
        if (succeeded) {
            [self friendRequestSendSucceededAlertWithTitle:succeededTitle andMessage:succeededMessage];
        } else {
            [self friendRequestSendSucceededAlertWithTitle:failedTitle andMessage:failedMessage];
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

-(void)friendRequestSendSucceededAlertWithTitle:(NSString *)title  andMessage:(NSString *)message{
    UIAlertController *requestSendStatus = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [requestSendStatus addAction:ok];
    [self presentViewController:requestSendStatus animated:YES completion:nil];
}

-(void)queryPhoneBookContact{
    self.contactsFromPhoneBook  = [NSMutableArray new];
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
                // remove the doublicate
                for (User *user in users) {
                    if (![self.friendsByUsername containsObject:user.username] && ![[User currentUser].phoneNumber isEqualToString:user.phoneNumber]) {
                        NSString *phoneNumber = user.phoneNumber;
                        NSString *phoneBookName = [namesForNumbers objectForKey:phoneNumber];
                        [self.phoneBookUserName addObject:user.username];
                        [self.phoneBookName addObject:phoneBookName];
                    }
                }
                NSLog(@"Contact");
                [self.tableView reloadData];
            }];
        } else {
            NSLog(@"addressBook query error!!! == %@",error);
        }
    }];
    
}

#pragma mark - Pase Contact List
-(void)checkUsernameInParseWithName:(NSString *)enteredName {
    if ([enteredName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length != 0) {
        PFQuery *query = [User query];
        [query whereKey:@"username" equalTo:enteredName];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (objects.count == 0) {
                NSLog(@"NO USER FOUND");
                [self noUserFoundAlert];
            }
            User *searchedUser = objects[0];
            if (!error && ![searchedUser.username isEqualToString:[User currentUser].username]) {
                NSLog(@"match");
                // matched and wants to add user
                [self confirmAddUser:searchedUser];
                
            } else {
                NSLog(@"can't add yourself");
            }
        }];
    }
}

-(void)confirmAddUser:(User *)user{
    UIAlertController *confirmAdd = [UIAlertController alertControllerWithTitle:@"User Found" message:[NSString stringWithFormat:@"Add %@",user.username] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (![self checkDuplicateConctact:user.username]) {
            [self.tableView reloadData];
            [SORequest sendRequestTo:user.username withBlock:nil];
        } else {
            [self contactDuplicateAlert];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [confirmAdd addAction:ok];
    [confirmAdd addAction:cancel];
    
    [self presentViewController:confirmAdd animated:YES completion:nil];
}

-(void)checkUsernameInParseWithPhoneNumber:(NSString *)phoneNumber {
    if ([phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 10) {
        PFQuery *query = [User query];
        [query whereKey:@"phoneNumber" equalTo:phoneNumber];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
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

#pragma - mark UITableView Delegate and DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.friendsByUsername.count;
    } else {
        return self.phoneBookName.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"Friends List";
    } else {
        return @"PhoneBook Contacts";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendsListCellID" forIndexPath:indexPath];
        cell.textLabel.text = self.friendsByUsername[indexPath.row];
        
        return cell;
    } else {
        PhoneContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"phoneContactCellID" forIndexPath:indexPath];
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addButton setTag:indexPath.row];
        addButton.frame = CGRectMake(cell.bounds.size.width - 45.0f, 5.0f, 40.0f, 40.0f);
        [addButton setImage:[UIImage imageNamed:@"plusButtonIcon"] forState:UIControlStateNormal];
        
        [addButton addTarget:self action:@selector(addButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:addButton];
        cell.nameLabel.text = self.phoneBookName[indexPath.row];
        cell.phoneNumberLabel.text = self.phoneBookUserName[indexPath.row];
        
        return cell;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}



#pragma mark - SearchBar

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // check self contact list
    if (![self checkDuplicateConctact:searchBar.text]) {
        // check parse pending
        PFQuery *userQuery = [User query];
        [userQuery whereKey:@"username" equalTo:searchBar.text];
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (objects.count == 0) {
                NSString *failedTitle = @"No User Found";
                NSString *failedMessage = @"Please check your spelling";
                [self friendRequestSendSucceededAlertWithTitle:failedTitle andMessage:failedMessage];
                searchBar.text = @"";
            } else {
                // alert to user to add
                UIAlertController *addUser = [UIAlertController alertControllerWithTitle:@"User Found" message:[NSString stringWithFormat:@"Add user %@?",searchBar.text] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *add = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [SORequest sendRequestTo:searchBar.text withBlock:^(BOOL succeeded) {
                        if (succeeded) {
                            NSString *succeededTitle = @"Awesome!";
                            NSString *succeededMessage = @"Request Sent";
                            [self friendRequestSendSucceededAlertWithTitle:succeededTitle andMessage:succeededMessage];
                        } else {
                            NSString *failedTitle = @"Request Pending";
                            NSString *failedMessage = [NSString stringWithFormat: @"Previous request still pending. Please wait until %@ to respond before sending another one",searchBar.text];
                            [self friendRequestSendSucceededAlertWithTitle:failedTitle andMessage:failedMessage];
                        }
                        searchBar.text = @"";
                    }];
                }];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    searchBar.text = @"";
                }];
                [addUser addAction:add];
                [addUser addAction:cancel];
                [self presentViewController:addUser animated:YES completion:nil];
            }
        }];
    } else {
        NSString *failedTitle = [NSString stringWithFormat:@"%@ already in Friends List",searchBar.text];
        NSString *failedMessage = @"";
        [self friendRequestSendSucceededAlertWithTitle:failedTitle andMessage:failedMessage];
        searchBar.text = @"";
    }
    
}

-(void)keyboardGestureRecognizer {
    NSNotificationCenter *keyboard = [NSNotificationCenter defaultCenter];
    [keyboard addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [keyboard addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.tapReconizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnyWhere:)];
}

-(void)keyboardWillShow: (NSNotification *)show {
    [self.view addGestureRecognizer:self.tapReconizer];
}

-(void)keyboardWillHide: (NSNotification *)hide {
    [self.view removeGestureRecognizer:self.tapReconizer];
}

-(void)didTapAnyWhere: (UITapGestureRecognizer *)reconizer {
    [self.searchBar resignFirstResponder];
}

- (void)fetchAcceptedRequestUsernames{
    SORequest *req = [SORequest new];
    [req fetchAllFriendRequests:^(NSMutableArray<NSString *> *friendRequestsAcceptedUsernames) {
        [[User currentUser].contacts fetchAndReturn:^(BOOL success) {
            if (success) {
                [[User currentUser].contacts.contactsList addObjectsFromArray:friendRequestsAcceptedUsernames];
                [User currentUser].contacts.contactsList = [[User currentUser].contacts.contactsList valueForKeyPath:@"@distinctUnionOfObjects.self"];
                self.friendsByUsername = [User currentUser].contacts.contactsList;
                [[User currentUser]saveInBackground];
                [self queryPhoneBookContact];
            }
        }];
    }];
}

@end