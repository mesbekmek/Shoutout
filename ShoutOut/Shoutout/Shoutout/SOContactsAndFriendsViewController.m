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
#import <ChameleonFramework/Chameleon.h>
#import <MessageUI/MessageUI.h>


typedef enum actionType{
    
    MY_FRIENDS = 0,
    MY_CONTACTS
} ActionType;


@interface SOContactsAndFriendsViewController ()<UITableViewDelegate, UITableViewDataSource,MFMessageComposeViewControllerDelegate>

@property (nonatomic) BOOL isAnimating;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) APAddressBook *addressBook;
@property (nonatomic) NSMutableArray *phoneBookUserName;
@property (nonatomic) NSMutableArray *phoneBookName;
@property (nonatomic) BOOL isOnContact;
@property (nonatomic) NSMutableArray *currentUserContacts;
@property (weak, nonatomic) IBOutlet UITextField *projectTitleTextField;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (nonatomic) NSArray<APContact *> *phoneBookContacts;

@property (nonatomic) NSArray<APContact *> *phoneBookContactsWithShoutout;

@property (nonatomic) NSArray<APContact *> *phoneBookContactsWithOutShoutout;

@property (nonatomic) NSMutableDictionary *phoneBookDictionary;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (nonatomic) NSMutableDictionary *usernamesForNames;
@end

@implementation SOContactsAndFriendsViewController
{
    NSMutableSet<NSIndexPath *> *selectedCellIndexesOnContactSection;
    NSMutableSet<NSIndexPath *> *selectedCellIndexesOnFriendsSection;
    ActionType actionType;
}
#pragma mark Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SetViewToHidden" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SOContactsLoaded" object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    //self.navigationController.navigationBarHidden = YES;
    
    
    
    
    
    
//    //create Back Button Item
//    NSString *shareProjectTitle = [NSString stringWithFormat: @"%@",self.projectTitle];
//    UIButton* customBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [customBackButton setImage:[UIImage imageNamed:@"backButton"] forState:UIControlStateNormal];
//    [customBackButton setTitle:shareProjectTitle forState:UIControlStateNormal];
//    [customBackButton sizeToFit];
//    
//    [customBackButton addTarget:self
//                         action:@selector(backBarButtonTapped)
//               forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem* customBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customBackButton];
//    self.navigationItem.leftBarButtonItem = customBarButtonItem;
//    
//    
//    //create Email Button Item
//    UIButton* customEmailButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [customEmailButton setImage:[UIImage imageNamed:@"email"] forState:UIControlStateNormal];
//    [customEmailButton sizeToFit];
//    
//    [customEmailButton addTarget:self
//                          action:@selector(sendAsEmailButtonTapped)
//                forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem* customBarButtonItem2 = [[UIBarButtonItem alloc] initWithCustomView:customEmailButton];
//    self.navigationItem.rightBarButtonItem = customBarButtonItem2;
//    
//    
//    //UI Stuff
//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"F07179"];
//    self.shareButton.backgroundColor = [UIColor colorWithHexString:@"F07179"];
//    [self.navigationController.navigationBar setTitleTextAttributes:
//     @{NSForegroundColorAttributeName:[UIColor whiteColor],
//       NSFontAttributeName:[UIFont fontWithName:@"futura-medium" size:25]}];
//    
//    self.navigationItem.title = @"Send to";
    
    
    
    
    //UI color stuff
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"F07179"];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"futura-medium" size:25]}];
    self.navigationItem.title = @"Shoutout";
    
    [[UIView appearance] setTintColor:[UIColor colorWithHexString:@"F07179"]];
    
    self.segmentedControl.tintColor = [UIColor colorWithHexString:@"F07179"];
    [self.backButton setTitleColor:[UIColor colorWithHexString:@"F07179"] forState:UIControlStateNormal ]  ;
//    self.doneButton.tintColor = [UIColor colorWithHexString:@"FFFFFF"];
    
   
}

-(void)setup
{
    self.phoneBookDictionary = [NSMutableDictionary new];
    selectedCellIndexesOnContactSection = [NSMutableSet new];
    selectedCellIndexesOnFriendsSection = [NSMutableSet new];
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

- (IBAction)friendsAndContactsButton:(UISegmentedControl *)sender {
    
    if (sender.selectedSegmentIndex == 0)
    {
        [self queryCurrentUserContactsListOnParse];
        self.isOnContact = NO;
    }
    else
    {
        self.isOnContact = YES;
        [self queryPhoneBookContacts];
    }
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
//    
//    if (self.isAnimating || (sender.tag == 0 && actionType == MY_FRIENDS) || (sender.tag == 1 && actionType == MY_CONTACTS)) {
//        return;
//    }
//    
//    [self animateUnderlineBar];
}
#pragma mark Phone Book Query
-(void)queryPhoneBookContacts{
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
                
                [self.tableView reloadData];
            }];
        } else {
            NSLog(@"Error: == %@",[error localizedDescription]);
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
        //   [self checkSORequestStatus];
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
//- (void)animateUnderlineBar{
//    
//    if (!self.isAnimating) {
//        
//        CGFloat newX = actionType == MY_FRIENDS? self.underlineBar.bounds.size.width : 0;
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
//            actionType = actionType == MY_FRIENDS? MY_CONTACTS : MY_FRIENDS;
//            
//        }];
//        
//    }
//    
//}
#pragma mark Navigation
- (IBAction)backButtonTapped:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneButtonTapped:(UIButton *)sender {
    NSString *title = [self.projectTitleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(self.isOnContact)
    {
        if([selectedCellIndexesOnContactSection count] == 0){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Wait..." message:@"Sorry, you need to select at least one person " preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                
                [alert dismissViewControllerAnimated:YES completion:nil];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
//        else if(!(title && title.length))
//        {
//            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Project Title!" message:@"Please title your event" preferredStyle:UIAlertControllerStyleAlert];
//            
//            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//                
//                [alert dismissViewControllerAnimated:YES completion:nil];
//            }]];
//            [self presentViewController:alert animated:YES completion:nil];
//        }
        else
        {
            NSArray *selectedFriendsIndexPaths = [selectedCellIndexesOnContactSection allObjects];
            
            NSArray<SOContactsFormatter*>* contactsWithShoutout = [self.phoneBookDictionary objectForKey:@"Contacts With Shoutout"];
            
            for(NSIndexPath *indexPath in selectedFriendsIndexPaths)
            {
                SOContactsFormatter *contact = contactsWithShoutout[indexPath.row];
                NSString *username = contact.username;
                
                //send collab request
                NSString *title = self.sortingProject.title? self.sortingProject.title : @"Event";
                
                [SORequest sendRequestTo:username forProjectId:self.sortingProject.objectId andTitle:title];
                
                //add username to collaborators array in the project
                if(![self.sortingProject.collaboratorsSentTo containsObject:username])
                {
                    [self.sortingProject.collaboratorsSentTo addObject:username];
                }
                [self.sortingProject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    NSLog(@"Successfully added new username to collaborators array");
                }];
                
                //send friend request
                [SORequest sendRequestTo:username withBlock:^(BOOL succeeded) {
                    if(succeeded)
                    {
                        NSLog(@"Successfully sent a friend request");
                    }
                }];
                
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
    else
    {
        if([selectedCellIndexesOnFriendsSection count] == 0)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Wait..." message:@"Sorry, you need to select at least one person " preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                
                [alert dismissViewControllerAnimated:YES completion:nil];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
//        else if(!(title && title.length))
//        {
//            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Project Title!" message:@"Please title your event" preferredStyle:UIAlertControllerStyleAlert];
//            
//            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//                
//                [alert dismissViewControllerAnimated:YES completion:nil];
//            }]];
//            [self presentViewController:alert animated:YES completion:nil];
//        }
        else{
            NSArray *selectedFriendsIndexPaths = [selectedCellIndexesOnFriendsSection allObjects];
            for(NSIndexPath *indexPath in selectedFriendsIndexPaths)
            {
                NSString *username = (NSString *)self.currentUserContacts[indexPath.row];
                [SORequest sendRequestTo:username forProjectId:self.sortingProject.objectId andTitle:self.projectTitleTextField.text];
                
                if(![self.sortingProject.collaboratorsSentTo containsObject:username])
                {
                    [self.sortingProject.collaboratorsSentTo addObject:username];
                }
                [self.sortingProject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    NSLog(@"Successfully added new username to collaborators array");
                }];
                
            }
            [self dismissViewControllerAnimated:YES completion:nil];

        }
    }
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
        
        [cell.buttonView setBackgroundColor:[UIColor clearColor]];
        //So that the cell won't be highlighted when it's tapped
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        if([selectedCellIndexesOnContactSection containsObject:indexPath]){
            [cell.buttonView setBackgroundColor:[UIColor colorWithHexString:@"#F07179"]];
        }
        
        if(indexPath.section == 0)
        {
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
        
        [cell.buttonView setBackgroundColor:[UIColor clearColor]];
        //So that the cell won't be highlighted when it's tapped
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        if([selectedCellIndexesOnFriendsSection containsObject:indexPath]){
            [cell.buttonView setBackgroundColor:[UIColor redColor]];
        }
        
        cell.nameLabel.text = self.currentUserContacts[indexPath.row];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.isOnContact)
    {
        if(indexPath.section == 0)
        {
            SOContactsTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell addButtonTapped:cell.addButton];
            if(cell.isHighlighted ){
                [selectedCellIndexesOnContactSection addObject:indexPath];
            }
            else if(!cell.isHighlighted && [selectedCellIndexesOnContactSection containsObject:indexPath])
            {
                [selectedCellIndexesOnContactSection removeObject:indexPath];
            }
        }
        else{
            SOContactsFormatter *contact = [self.phoneBookDictionary objectForKey:@"Contacts Without Shoutout"][indexPath.row];
            
            [self sendSMSToPerson:contact.name andPhoneNumber:contact.phoneNumber];
        }
    }
    else
    {
        SOFriendsTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell collaborateButtonTapped:cell.collaborateButton];
        
        if(cell.isHighlighted)
        {
            [selectedCellIndexesOnFriendsSection addObject:indexPath];
        }
        else if(!cell.isHighlighted && [selectedCellIndexesOnFriendsSection containsObject:indexPath])
        {
            [selectedCellIndexesOnFriendsSection removeObject:indexPath];
        }
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(self.isOnContact)
    {
        return section == 0 ? @"Contacts With Shoutout" : @"Contacts Without Shoutout";
    }
    return nil;
}

#pragma mark - TextField Delegate
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.projectTitleTextField endEditing:YES];
}

#pragma mark - Messaging
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Error" message:@"Failed to send SMS" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [controller dismissViewControllerAnimated:YES completion:nil];
            }];
            [controller addAction:okAction];
            [self presentViewController:controller animated:YES completion:nil];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendSMSToPerson:(NSString *)person andPhoneNumber:(NSString *)phoneNumber{
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSArray *recipents = @[phoneNumber];
    NSString *message = [NSString stringWithFormat:@"Hey, %@. Please download Shoutout from the app store so that we can collaborate. ", person];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

@end
