//
//  NotificationsTableViewContainerViewController.m
//  Shoutout
//
//  Created by Varindra Hart on 11/30/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "NotificationsTableViewContainerViewController.h"
#import "SORequest.h"
#import "SONotificationsTableViewController.h"
#import "SONotificationsHeader.h"
#import "SOVideo.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <ChameleonFramework/Chameleon.h>
#import "NotificationsTableViewCell.h"
#import "FriendRequestTableViewCell.h"
#import "User.h"

typedef enum hasFetched{

    FETCHING = 0,
    FETCHINGCOMPLETE = 1

} FetchingStatus;

@interface NotificationsTableViewContainerViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, NotificationsTableViewCellDelegate, FriendRequestTableViewCellDelegate>

@property (nonatomic) SONotificationsTableViewController *notifTVC;
@property (weak, nonatomic) IBOutlet UIView *tableViewHolder;
@property (nonatomic) NSMutableArray *collaborationRequests;
@property (nonatomic) NSMutableArray *friendRequests;
@property (nonatomic) NSMutableArray *responseRequests;
@property (nonatomic) UIImagePickerController *imagePicker;
@property (nonatomic) NSString *currentProjectId;
@property (nonatomic) SORequest *currentRequest;
@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet UISegmentedControl *segmentedController;
@property (nonatomic) NSMutableArray <SORequest *> *collabAndFriendRequests;
@property (nonatomic) UIRefreshControl *refresh;
@property (nonatomic) BOOL sentCollabResponse;

@end

@implementation NotificationsTableViewContainerViewController{
    FetchingStatus fetchingStatus;
}
- (IBAction)segmentedControllerChanged:(UISegmentedControl *)sender {
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"F07179"];
    self.segmentedController.tintColor = [UIColor colorWithHexString:@"F07179"];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"futura-medium" size:25]}];
    self.navigationItem.title = @"Notifications";

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.sentCollabResponse) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Success!" message:@"Succesfully submitted video" preferredStyle:UIAlertControllerStyleAlert];
        NSLog(@"Saved current request");
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [controller dismissViewControllerAnimated:YES completion:nil];
        }];
        [controller addAction:okAction];
        [self presentViewController:controller animated:YES completion:nil];
        self.sentCollabResponse = NO;
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsMultipleSelection = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"NotificationsHeader" bundle:nil] forHeaderFooterViewReuseIdentifier:@"SOHeaderIdentifier"];
    self.tableView.estimatedRowHeight = 20.0f;

    self.refresh = [[UIRefreshControl alloc]init];

    [self.refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];

    [self.tableView addSubview:self.refresh];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newUser) name:@"UserDidLogIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newUser) name:@"UserSignedOutNotification" object:nil];
    fetchingStatus = FETCHING;
    [self fetchFirstBatch];
}

- (void)fetchFirstBatch{

    SORequest *request = [SORequest new];
    [request fetchAllRequests:^(NSMutableArray<SORequest *> *collaborationRequests, NSMutableArray<SORequest *> *friendRequests, NSMutableArray<SORequest *> *responseRequests) {
        self.collaborationRequests = [NSMutableArray arrayWithArray:collaborationRequests];
        self.friendRequests = friendRequests;
        self.responseRequests = responseRequests;

        self.collabAndFriendRequests = [NSMutableArray arrayWithArray:self.collaborationRequests];
        [self.collabAndFriendRequests addObjectsFromArray:self.friendRequests];
        [self.collabAndFriendRequests sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];

        fetchingStatus = FETCHINGCOMPLETE;

        if ([self.refresh isRefreshing]) {
            [self.refresh endRefreshing];
        }

        [self.tableView reloadData];
    }];

}

- (void)refresh:(UIRefreshControl *)refControl{
    if (fetchingStatus==FETCHINGCOMPLETE) {
        [self fetchFirstBatch];
    }
}

- (IBAction)backButtonTapped:(UIButton *)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (fetchingStatus == FETCHING) {
        return 0;
    }

    else{
        switch (self.segmentedController.selectedSegmentIndex) {
            case 0:
                return self.collabAndFriendRequests.count;
                break;
            case 1:
                return self.responseRequests.count;
                break;
            default:
                return 0;
                break;
        }

    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {


    switch (self.segmentedController.selectedSegmentIndex) {
        case 0:
        {
            SORequest *req = self.collabAndFriendRequests[indexPath.row];
            if (req.isFriendRequest) {
                FriendRequestTableViewCell *frTVC = [tableView dequeueReusableCellWithIdentifier:@"FriendRequestIdentifier"];
                if (!frTVC) {
                    [self.tableView registerNib:[UINib nibWithNibName:@"NotificationsFriendCell" bundle:nil] forCellReuseIdentifier:@"FriendRequestIdentifier"];
                    frTVC = [tableView dequeueReusableCellWithIdentifier:@"FriendRequestIdentifier"];
                }
                frTVC.indexValue = indexPath.row;
                frTVC.mainLabel.text = [NSString stringWithFormat:@"%@ wants to add you",req.requestSentFrom];
                frTVC.delegate = self;
                return  frTVC;
            }
            else{
                NotificationsTableViewCell *notifTVC = [tableView dequeueReusableCellWithIdentifier:@"CollaborationRequestIdentifier"];

                if(!notifTVC){
                    [self.tableView registerNib:[UINib nibWithNibName:@"NotificationsCollaborationCell" bundle:nil] forCellReuseIdentifier:@"CollaborationRequestIdentifier"];
                    notifTVC = [tableView dequeueReusableCellWithIdentifier:@"CollaborationRequestIdentifier"];
                }

                notifTVC.mainLabel.text = @"";
                notifTVC.usernameLabel.text = req.requestSentFrom;
                //                CGRect origFrame = notifTVC.frame;
                //                origFrame.origin.y = 0;
                //                notifTVC.frame = origFrame;
                if (req.projectTitle) {

                    notifTVC.mainLabel.text = [NSString stringWithFormat:@"Collaborate on %@",req.projectTitle];
                }
                notifTVC.indexValue = indexPath.row;
                notifTVC.delegate = self;
                return notifTVC;
            }
            break;
        }
        case 1:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            SORequest * req = self.responseRequests[indexPath.row];
            NSString *response = [NSString stringWithFormat:@"%@ has %@ %@", req.requestSentTo, req.isAccepted? @"submitted a video to":@"declined your invite to collaborate on",req.projectTitle?req.projectTitle:req.projectId];
            cell.textLabel.text = response;
            return cell;
        }
        default:
            break;
    }


    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationCell" forIndexPath:indexPath];

    return cell;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    switch (self.segmentedController.selectedSegmentIndex) {
        case 1: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationCell" forIndexPath:indexPath];
            if(cell.selectionStyle == UITableViewCellSelectionStyleNone){
                return nil;
            }
        }
    }

    return indexPath;
}



# pragma mark - Video camera setup

- (void)setupCamera{

    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = [[NSArray alloc]initWithObjects:(NSString *)kUTTypeMovie, nil];
    self.imagePicker.videoMaximumDuration = 10.0;
    self.imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}


# pragma mark - Image Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{

    SOVideo *video = [[SOVideo alloc]initWithVideoUrl:info [UIImagePickerControllerMediaURL] andProjectId:self.currentProjectId];
    self.currentRequest.isAccepted = YES;
    self.currentRequest.hasDecided = YES;
    [self.collabAndFriendRequests removeObject:self.currentRequest];
    [self.tableView reloadData];
    [video saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"New Video Submitted");

    }];

    [self.currentRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded)
        {
            NSLog(@"Saved request");
        }else{
            NSLog(@"Failed to send request, error:%@",[error localizedDescription]);
        }
    }];
    self.sentCollabResponse = YES;
    [picker dismissViewControllerAnimated:YES completion:nil];

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{

    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (self.segmentedController.selectedSegmentIndex) {
        case 0:{

            SORequest *req = self.collabAndFriendRequests[indexPath.row];
            req.isAccepted = NO;
            req.hasDecided = YES;
            [self.collabAndFriendRequests removeObject:req];
            [self.tableView reloadData];
            [req saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {

            }];
            break;
        }

        case 1:{
            SORequest *req = self.responseRequests[indexPath.row];
            [self.responseRequests removeObject:req];
            [self.tableView reloadData];
            [req deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            }];
            break;

        }
        default:
            break;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 60.0f;
}

- (void)didTapActionButtonAtRow:(NSInteger)row{

    SORequest *req = self.collabAndFriendRequests[row];
    req.hasDecided = YES;
    req.isAccepted = YES;
    [self.collabAndFriendRequests removeObject:req];
    [self.tableView reloadData];
    [req saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {

    }];
    if ([User currentUser].contacts == nil) {
        SOContacts *contacts = [[SOContacts alloc]initWithNewList];
        [User currentUser].contacts = contacts;
    }
    [[User currentUser].contacts fetchAndReturn:^(BOOL success) {
        if (success) {

            [[User currentUser].contacts.contactsList addObject:req.requestSentFrom];

            [[User currentUser] saveInBackground];
        }
    }];



}

- (void)didTapButtonAtRow:(NSInteger)row{

    if (self.segmentedController.selectedSegmentIndex == 0) {
        self.currentRequest = self.collabAndFriendRequests[row];
        self.currentProjectId = self.currentRequest.projectId;
        [self setupCamera];
    }
    
}

- (void)newUser{
    
    if (fetchingStatus == FETCHINGCOMPLETE) {
        [self fetchFirstBatch];
    }
    
}

@end
