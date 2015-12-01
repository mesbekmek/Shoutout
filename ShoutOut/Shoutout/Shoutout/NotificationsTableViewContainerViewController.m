//
//  NotificationsTableViewContainerViewController.m
//  Shoutout
//
//  Created by Varindra Hart on 11/30/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "NotificationsTableViewContainerViewController.h"
#import "SONotificationsTableViewController.h"

@interface NotificationsTableViewContainerViewController ()
@property (nonatomic) SONotificationsTableViewController *notifTVC;
@property (nonatomic) IBOutlet UIView *tableViewHolder;

@end

@implementation NotificationsTableViewContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self embedNotificationTableViewController];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)embedNotificationTableViewController{
    
    self.notifTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationTableViewController"];
    [self addChildViewController:self.notifTVC];
    self.notifTVC.view.frame = self.tableViewHolder.bounds;
    [self.tableViewHolder addSubview:self.notifTVC.view];
    [self.notifTVC willMoveToParentViewController:self];

}

@end
