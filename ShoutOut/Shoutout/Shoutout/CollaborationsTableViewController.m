//
//  CollaborationsTableViewController.m
//  Shoutout
//
//  Created by Varindra Hart on 11/13/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "CollaborationsTableViewController.h"
#import <Parse/Parse.h>
#import "CollaborateViewController.h"
#import "SOModel.h"

@interface CollaborationsTableViewController ()

@property (nonatomic) NSMutableArray <SOProject*> *collaborationsArray;

@end

@implementation CollaborationsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self query];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Query

- (void)query{
    
    PFQuery *query = [PFQuery queryWithClassName:@"SOProjects"];
    [query whereKey:@"collaboratorsSentTo" equalTo:[User currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error) {
            self.collaborationsArray = [[NSMutableArray alloc]initWithArray:objects];
            [self.tableView reloadData];
        }
        else{
            NSLog(@"%@",error);
        }
    }];

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.collaborationsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"collaborationIdentifier" forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", self.collaborationsArray[indexPath.row].createdBy, self.collaborationsArray[indexPath.row].description];
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CollaborateViewController *collaborateVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CollaborateViewController"];
    collaborateVC.collaborationProject = self.collaborationsArray[indexPath.row];
    [self.navigationController pushViewController:collaborateVC animated:YES];
    
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
