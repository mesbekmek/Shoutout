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

typedef enum hasFetched{
    
    FETCHING = 0,
    FETCHINGCOMPLETE = 1
    
} FetchingStatus;

@interface NotificationsTableViewContainerViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) SONotificationsTableViewController *notifTVC;
@property (weak, nonatomic) IBOutlet UIView *tableViewHolder;
@property (nonatomic)NSMutableArray *collaborationRequests;
@property (nonatomic)NSMutableArray *friendRequests;
@property (nonatomic)NSMutableArray *responseRequests;
@property (nonatomic)UIImagePickerController *imagePicker;
@property (nonatomic)NSString *currentProjectId;
@property (nonatomic)SORequest *currentRequest;
@property (nonatomic)IBOutlet UITableView *tableView;

@end

@implementation NotificationsTableViewContainerViewController{
    FetchingStatus fetchingStatus;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"34A6FF"];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"futura-medium" size:25]}];
    self.navigationItem.title = @"Notifications";

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsMultipleSelection = NO;
    SORequest *request = [SORequest new];
    fetchingStatus = FETCHING;
    [request fetchAllRequests:^(NSMutableArray<SORequest *> *collaborationRequests, NSMutableArray<SORequest *> *friendRequests, NSMutableArray<SORequest *> *responseRequests) {
        self.collaborationRequests = [NSMutableArray arrayWithArray:collaborationRequests];
        self.friendRequests = friendRequests;
        self.responseRequests = responseRequests;
        fetchingStatus = FETCHINGCOMPLETE;
        [self.tableView reloadData];
    }];
    self.navigationController.navigationBarHidden = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"NotificationsHeader" bundle:nil] forHeaderFooterViewReuseIdentifier:@"SOHeaderIdentifier"];
    self.tableView.estimatedRowHeight = 20.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonTapped:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (fetchingStatus == FETCHING) {
        return 0;
    }
    else{
        switch (section) {
            case 0:
            {
                return self.collaborationRequests.count;
                break;
            }
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
        
        SORequest *req = self.collaborationRequests[indexPath.row];
        
        cell.textLabel.text = req.projectTitle;
        cell.detailTextLabel.text = req.requestSentFrom;
        
        return cell;
        
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        self.currentRequest = self.collaborationRequests[indexPath.row];
        self.currentProjectId = self.currentRequest.projectId;
        [self setupCamera];
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    SONotificationsHeader *header = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"SOHeaderIdentifier"];
    switch (section) {
        case 0:
            header.headerTitle.text = @"Collaboration Requests";
            break;
        case 1:
            header.headerTitle.text = @"Collaboration Replies";
            break;
        case 2:
            header.headerTitle.text = @"Friend Requests";
            break;
        default:
            break;
    }
    
    return header;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 80.0f;
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
    [video saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"New Video Submitted");
        [self.collaborationRequests removeObject:self.currentRequest];
        [self.tableView reloadData];
    }];
    
    [self.currentRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"Saved current request");
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section ==0 || indexPath.section ==2) {
        return YES;
    }
    return NO;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:{
            
            SORequest *req = self.collaborationRequests[indexPath.row];
            req.isAccepted = NO;
            req.hasDecided = YES;
            [req saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                
                [self.collaborationRequests removeObject:req];
                [self.tableView reloadData];
                
            }];
            break;
        }

        case 2:{
            SORequest *req = self.friendRequests[indexPath.row];
            req.isAccepted = NO;
            req.hasDecided = YES;
            [req saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                
                [self.friendRequests removeObject:req];
                [self.tableView reloadData];
                
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



@end
