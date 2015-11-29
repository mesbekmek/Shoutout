//
//  SOContactsViewController.m
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 11/28/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOContactsViewController.h"
#import "PhoneBookContactTableViewController.h"
#import "APAddressBook.h"
#import "APContact.h"
#import "APPhone.h"
#import "SORequest.h"
#import "Contact.h"

typedef enum actionType{
    
    ADD_FRIENDS = 0,
    ADD_COLLABORATORS
    
} ActionType;

@interface SOContactsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSArray <APContact *> *phoneBookContactList;
@property (nonatomic, strong) APAddressBook *addressBook;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;

@property (nonatomic) NSMutableArray *collaborationFriends;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (weak, nonatomic) IBOutlet UILabel *actionLabel;

@property (nonatomic) NSMutableArray *phoneBookName;
@property (nonatomic) NSMutableArray *phoneBookUserName;
@property (nonatomic) NSMutableDictionary *usernamesForNames;

@end

@implementation SOContactsViewController
{
    NSMutableSet<NSIndexPath *> *selectedCellIndexes;
    ActionType currentActionType;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self queryPhoneBookContact];
    
    self.contactsTableView.delegate = self;
    self.contactsTableView.dataSource = self;
    selectedCellIndexes = [NSMutableSet new];
    self.collaborationFriends = [NSMutableArray new];
    self.usernamesForNames = [NSMutableDictionary new];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SetViewToHidden" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SOContactsLoaded" object:nil];
    
}

-(void)queryPhoneBookContact{
    
    self.phoneBookContactList = [NSArray new];
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
                    [self.phoneBookName addObject:phoneBookName];
                    [self.phoneBookUserName addObject:user.username];
                    [self.usernamesForNames setObject:user.username forKey:phoneBookName];
                }
                [self.contactsTableView reloadData];
            }];
        } else {
            NSLog(@"Error!!! == %@",error);
        }
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Next Button
- (IBAction)nextButtonTapped:(UIButton *)sender {
    
    if([self.nextButton.titleLabel.text isEqualToString:@"Done"])
    {
        NSArray *selectedFriendsIndexPaths = [selectedCellIndexes allObjects];
        NSArray *keys = [[self.usernamesForNames allKeys]sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        for(NSIndexPath *indexPath in selectedFriendsIndexPaths)
        {
            NSString *username = (NSString *)self.usernamesForNames[keys[indexPath.row]];
            [SORequest sendRequestTo:username forProjectId:self.projectId andTitle:self.titleTextField.text];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
    
    
    if(currentActionType == ADD_FRIENDS)
    {
        [self.nextButton setTitle:@"Done" forState:UIControlStateNormal];
        currentActionType = currentActionType == ADD_FRIENDS ? ADD_COLLABORATORS :ADD_FRIENDS;
        self.actionLabel.text = @"Add collaborators";
    }
    
    if([selectedCellIndexes count] == 0){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else
    {
        NSArray *selectedFriendsIndexPaths = [selectedCellIndexes allObjects];
        
        NSMutableArray *tempUsernameArray = [NSMutableArray new];
        NSMutableArray *tempNameArray = [NSMutableArray new];
        NSMutableDictionary *tempUsernameForNames = [NSMutableDictionary new];
        NSArray *keys = [[self.usernamesForNames allKeys]sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        for(NSIndexPath *indexPath in selectedFriendsIndexPaths)
        {
            
//            [tempUsernameArray addObject:self.phoneBookUserName[indexPath.row]];
//            [tempNameArray addObject:self.phoneBookName[indexPath.row]];
            [tempUsernameForNames setObject:self.usernamesForNames[keys[indexPath.row]] forKey:keys[indexPath.row] ];
        }
        self.phoneBookUserName = tempUsernameArray;
        self.phoneBookName = tempNameArray;
        self.usernamesForNames = tempUsernameForNames;
        
        self.phoneBookName = [NSMutableArray arrayWithArray:[self.phoneBookName sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
        
        
        
        [selectedCellIndexes removeAllObjects];
        
        [self.contactsTableView reloadData];
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.usernamesForNames allKeys].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactsCellID" forIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSArray *keys = [[self.usernamesForNames allKeys]sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    if([selectedCellIndexes containsObject:indexPath]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
//    if(self.shoutoutFriends.count>0)
    if (keys.count>0)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", keys[indexPath.row]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [self.usernamesForNames objectForKey:keys[indexPath.row]]];
    }
    else{
        
    }
//    else{
//        cell.textLabel.text = self.phoneBookContactList[indexPath.row].name.firstName;
//        if(self.phoneBookContactList[indexPath.row].phones[0] != nil)
//        {
//            cell.detailTextLabel.text = self.phoneBookContactList[indexPath.row].phones[0].number;
//        }
//    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if(cell.accessoryType == UITableViewCellAccessoryCheckmark)
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
        if ([cell accessoryType] == UITableViewCellAccessoryCheckmark)
        {
            [selectedCellIndexes addObject:indexPath];
        }
        else if([selectedCellIndexes containsObject:indexPath])
        {
            [selectedCellIndexes removeObject:indexPath];
        }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.titleTextField resignFirstResponder];
}



@end
