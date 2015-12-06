//
//  SOShareViewController.m
//  Shoutout
//
//  Created by Varindra Hart on 11/29/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOShareViewController.h"
#import <MessageUI/MessageUI.h>
#import <ChameleonFramework/Chameleon.h>
#import "SOShoutout.h"


@interface SOShareViewController () <MFMailComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic) NSMutableArray <NSString *> *sharedToCollaborators;
@property (nonatomic) NSMutableArray <NSString *> *sharedToRecipients;
@property (nonatomic) NSMutableArray<NSString *> *shoutoutFriends;
@property (nonatomic) SOContacts *contact;

@end

@implementation SOShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.allowsMultipleSelection = YES;
    self.sharedToCollaborators = [NSMutableArray new];
    self.sharedToRecipients = [NSMutableArray new];
    self.shoutoutFriends = [NSMutableArray new];
    self.contact = [SOContacts new];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"34A6FF"];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"futura-medium" size:25]}];
    self.navigationItem.title = @"Notifications";
    [self contactsQuery];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)contactsQuery{
    
    if([User currentUser].contacts != nil)
    {
        PFQuery *query = [PFQuery queryWithClassName:@"SOContacts"];
        [query whereKey:@"objectId" containsString:[User currentUser].contacts.objectId];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            
            if(!error)
            {
                self.contact = (SOContacts *)objects[0];
                if(self.contact.contactsList.count > 0)
                {
                    self.shoutoutFriends = self.contact.contactsList;
                    
                    [self.shoutoutFriends sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                    
                    //change sort descriptor nsarry result into mutable version
                    self.shoutoutFriends = [NSMutableArray arrayWithArray:self.shoutoutFriends];
                    
                    NSMutableIndexSet *indexesToBeRemoved = [NSMutableIndexSet new];
                    for(int i = 0; i < self.sharedProject.collaboratorsReceivedFrom.count; i++)
                    {
                        NSString *collabString = self.sharedProject.collaboratorsReceivedFrom[i];
                        NSString *friendString = self.shoutoutFriends[i];
                        if([collabString isEqualToString:friendString]){
                            [indexesToBeRemoved addIndex:i];
                        }
                    }
                    if(indexesToBeRemoved.count > 0)
                    {
                        [self.shoutoutFriends removeObjectsAtIndexes:indexesToBeRemoved];
                    }
                    
                    
                    [self.tableview reloadData];
                }
            }
            else
            {
                NSLog(@"%@",[error localizedDescription]);
            }
        }];
    }
    
}

- (IBAction)backButtonTapped:(UIButton *)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendAsEmailButtonTapped:(UIButton *)sender{
    if ([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];

        // Email Subject
        NSString *emailTitle = @"Shoutout!";
        // Email Content
        NSString *messageBody = [NSString stringWithFormat: @"Video Message from Shoutout: %@", self.shareUrl];
        // To address
        NSArray *toRecipents = @[];
        
        
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:YES];
        [mc setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }
    else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Your device currently has no email set to it" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Table View Data Source And Delegate Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SOShareCellID" forIndexPath:indexPath];
    if (indexPath.section == 0)
    {
        cell.textLabel.text = self.shoutoutFriends[indexPath.row];
    }
    else
    {
        cell.textLabel.text = self.sharedProject.collaboratorsReceivedFrom[indexPath.row];
    }
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return section == 0 ? @"Friends" : @"Collaborators";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? self.shoutoutFriends.count : self.sharedProject.collaboratorsReceivedFrom.count;
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        [self.sharedToRecipients addObject:self.shoutoutFriends[indexPath.row]];
    }
    else
    {
        [self.sharedToCollaborators addObject:self.sharedProject.collaboratorsReceivedFrom[indexPath.row]];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 0)
    {
        [self.sharedToRecipients removeObject:self.shoutoutFriends[indexPath.row]];
    }
    else
    {
        [self.sharedToCollaborators removeObject:self.sharedProject.collaboratorsReceivedFrom[indexPath.row]];
    }
}

- (IBAction)shareButtonTapped:(id)sender{
    
    if (self.sharedToCollaborators.count>0 && self.sharedToRecipients.count > 0)
    {
        [SOShoutout sendVideo:self.sharedProject.videos withTitle:@"FirstShoutout" toCollaborators:self.sharedToCollaborators toReceipents:self.sharedToRecipients];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (self.sharedToRecipients.count > 0)
    {
        [SOShoutout sendVideo:self.sharedProject.videos withTitle:@"FirstShoutout" toCollaborators:@[] toReceipents:self.sharedToRecipients];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (self.sharedToCollaborators.count > 0)
    {
        [SOShoutout sendVideo:self.sharedProject.videos withTitle:@"FirstShoutout" toCollaborators:self.sharedToCollaborators toReceipents:@[]];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
