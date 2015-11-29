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

@property (nonatomic) NSMutableArray *shoutoutFriends;
@property (nonatomic) NSMutableArray *collaborationFriends;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (nonatomic) BOOL nextButtonIsSelected;
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;


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
    self.shoutoutFriends = [NSMutableArray new];
    self.collaborationFriends = [NSMutableArray new];
    
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
            self.phoneBookContactList = contacts;
            [self.contactsTableView reloadData];
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

        for(NSIndexPath *indexPath in selectedFriendsIndexPaths)
        {
          //  SORequest sendRequestTo:self.shou forProjectId:<#(NSString *)#> andTitle:<#(NSString *)#>
            [self.collaborationFriends addObject:self.shoutoutFriends[indexPath.row]];
        }
    }
    
    self.nextButtonIsSelected = YES;
    currentActionType = currentActionType == ADD_FRIENDS ? ADD_COLLABORATORS :ADD_FRIENDS;
    
    
    if(self.nextButtonIsSelected){
        self.nextButton.titleLabel.text = currentActionType == ADD_FRIENDS ? @"Next" : @"Done";
        [self.nextButton setTitle:@"Done" forState:UIControlStateNormal];
    }
    
    self.actionLabel.text = @"Add collaborators";
    
    
    if([selectedCellIndexes count] == 0){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }]];
    }
    else
    {
        NSArray *selectedFriendsIndexPaths = [selectedCellIndexes allObjects];
        
        for(NSIndexPath *indexPath in selectedFriendsIndexPaths)
        {
            [self.shoutoutFriends addObject:self.phoneBookContactList[indexPath.row].name.firstName];
        }
        self.shoutoutFriends  = [NSMutableArray arrayWithArray:[self.shoutoutFriends sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
        
        [selectedCellIndexes removeAllObjects];
        
        [self.contactsTableView reloadData];
    }
    
    
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.nextButtonIsSelected)
    {
        self.nextButtonIsSelected = NO;
        return  [self.shoutoutFriends count];
        
    }
    return self.phoneBookContactList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactsCellID" forIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if([selectedCellIndexes containsObject:indexPath]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    if(self.shoutoutFriends.count>0)
    {
        cell.textLabel.text = self.shoutoutFriends[indexPath.row];
    }
    else{
        cell.textLabel.text = self.phoneBookContactList[indexPath.row].name.firstName;
        if(self.phoneBookContactList[indexPath.row].phones[0] != nil)
        {
            cell.detailTextLabel.text = self.phoneBookContactList[indexPath.row].phones[0].number;
        }
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if(currentActionType == ADD_FRIENDS){
        
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
    else{
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
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.titleTextField resignFirstResponder];
}



@end
