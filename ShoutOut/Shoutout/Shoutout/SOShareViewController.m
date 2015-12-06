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
@property (nonatomic) NSMutableDictionary *shareContactsDict;
@property (nonatomic) NSMutableArray <NSString *> *sharedTo;

@end

@implementation SOShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.allowsMultipleSelection = YES;
    self.shareContactsDict = [NSMutableDictionary new];
    self.sharedTo = [NSMutableArray new];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"34A6FF"];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"futura-medium" size:25]}];
    self.navigationItem.title = @"Notifications";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    cell.textLabel.text = self.sharedProject.collaboratorsReceivedFrom[indexPath.row];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sharedProject.collaboratorsReceivedFrom.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //    return [self.shareContactsDict allKeys].count;
    return 1;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.sharedTo addObject:self.sharedProject.collaboratorsReceivedFrom[indexPath.row]];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.sharedTo removeObject:self.sharedProject.collaboratorsReceivedFrom[indexPath.row]];
}

- (IBAction)shareButtonTapped:(id)sender{
    
    if (self.sharedTo.count>0) {
        
        [SOShoutout sendVideo:self.sharedProject.videos withTitle:@"FirstShoutout" toCollaborators:self.sharedTo toReceipents:@[]];

        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

@end
