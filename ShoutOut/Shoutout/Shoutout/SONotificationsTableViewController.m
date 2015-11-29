//
//  SONotificationsTableViewController.m
//  Shoutout
//
//  Created by Varindra Hart on 11/28/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SONotificationsTableViewController.h"
#import <MGSwipeTableCell/MGSwipeButton.h>
#import <MGSwipeTableCell/MGSwipeTableCell.h>
#import "SOVideo.h"
#import "SORequest.h";

typedef enum hasFetched{
    
    FETCHING = 0,
    FETCHINGCOMPLETE = 1
    
} FetchingStatus;

@interface SONotificationsTableViewController () <MGSwipeTableCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic)NSMutableArray *collaborationRequests;
@property (nonatomic)NSMutableArray *friendRequests;
@property (nonatomic)NSMutableArray *responseRequests;

@end

@implementation SONotificationsTableViewController{
    FetchingStatus fetchingStatus;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    SORequest *request = [SORequest new];
    fetchingStatus = FETCHING;
    [request fetchAllRequests:^(NSMutableArray<SORequest *> *collaborationRequests, NSMutableArray<SORequest *> *friendRequests, NSMutableArray<SORequest *> *responseRequests) {
        self.collaborationRequests = [NSMutableArray arrayWithArray:collaborationRequests];
        self.friendRequests = friendRequests;
        self.responseRequests = responseRequests;
        fetchingStatus = FETCHINGCOMPLETE;
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    if (fetchingStatus == FETCHING) {
        return 0;
    }
    else{
        switch (section) {
            case 0:
                return self.collaborationRequests.count;
                break;
            case 1:
                return self.responseRequests.count;
                break;
            case 2:
                return self.friendRequests.count;
                break;
            default:
                return 0;
                break;
        }
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationCell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        
        MGSwipeTableCell * MG_Cell = [self.tableView dequeueReusableCellWithIdentifier:@"MGCell"];
        if (!MG_Cell) {
            MG_Cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MGCell"];
        }
        SORequest *req = self.collaborationRequests[indexPath.row];
        
        MG_Cell.textLabel.text = [NSString stringWithFormat:@"%@ would like you to collaborate on %@",req.requestSentFrom, req.projectTitle? req.projectTitle: req.projectId];
        //Date goes here
//        MG_Cell.detailTextLabel.text = @"%@";
        MG_Cell.delegate = self; //optional
        
        
        //configure left buttons
        MG_Cell.leftButtons = @[[MGSwipeButton buttonWithTitle:@"X" backgroundColor:[UIColor redColor]]];
        MG_Cell.leftSwipeSettings.transition = MGSwipeTransitionBorder;
        
        //configure right buttons
//        MG_Cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor redColor]],
//                                 [MGSwipeButton buttonWithTitle:@"More" backgroundColor:[UIColor lightGrayColor]]];
//        MG_Cell.rightSwipeSettings.transition = MGSwipeTransition3D;
        return MG_Cell;
        
    }
    
    if (indexPath.section == 1) {
        SORequest *req = self.responseRequests[indexPath.row];
        NSString *response = [NSString stringWithFormat:@"%@ has %@ %@", req.requestSentTo, req.isAccepted? @"submitted a video to":@"declined your invite to collaborate on",req.projectTitle?req.projectTitle:req.projectId];
        cell.textLabel.text = response;
        return cell;
    }
    else{
        cell.textLabel.text = @"Some friend Request";
    }
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    switch (section) {
        case 0:
            return @"Collaboration Requests";
            break;
        case 1:
            return @"Invite Replies";
            break;
        case 2:
            return @"Friend Requests";
            break;
        default:
            return nil;
            break;
    }
    
}
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
