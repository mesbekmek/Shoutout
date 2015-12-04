//
//  SOShoutoutsViewController.m
//  Shoutout
//
//  Created by Varindra Hart on 12/4/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOShoutoutsViewController.h"
#import <ChameleonFramework/Chameleon.h>

@interface SOShoutoutsViewController ()

@end

@implementation SOShoutoutsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"34A6FF"];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"futura-medium" size:25]}];
    self.navigationItem.title = @"Shoutouts";

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
