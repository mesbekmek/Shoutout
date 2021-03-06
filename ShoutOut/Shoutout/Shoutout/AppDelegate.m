//
//  AppDelegate.m
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 11/8/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "AppDelegate.h"

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "User.h"
#import "SOVideo.h"
#import "SOProject.h"
#import "SOProjectsViewController.h"
#import "SOLoginViewController.h"
#import "SORequest.h"
#import "User.h"
#import "SOContacts.h"
#import "SOShoutout.h"
#import "Reachability.h"
#import "SOCachedProjects.h"
#import <SSKeychain/SSKeychain.h>
#import <SSKeychain/SSKeychainQuery.h>
 #import <ChameleonFramework/Chameleon.h>

@interface AppDelegate ()

@end
NSString * const parseApplicationId = @"ED7PsBQFjJ5e5P8qDW7lw2fTvJlqZ9qecwLrXpGC";
NSString * const parseClientKey = @"SIHgxMqG6dEFfIiEcJOied8zI1WEn2GuCLarvP1l";
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 
    
  //  [Chameleon setGlobalThemeUsingPrimaryColor:[UIColor flatWatermelonColorDark] withContentStyle:UIContentStyleLight];
    

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [Parse setApplicationId:parseApplicationId clientKey:parseClientKey];
    [User registerSubclass];
    [SOVideo registerSubclass];
    [SOProject registerSubclass];
    [SORequest registerSubclass];
    [SOContacts registerSubclass];
    [SOShoutout registerSubclass];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    [self reachability];

    //Uncomment when we decide to implement Push Notifs
    //[self setupPushNotifications:application];
    
   
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    UITabBarController *tabBC = [storyboard instantiateViewControllerWithIdentifier:@"SOTabBarController"];
    self.window.rootViewController = tabBC;

    if([PFUser currentUser])
    {

        //Uncomment when we decide to implement Push Notifs
        //[[PFInstallation currentInstallation] setObject:user forKey:@"user"];
        //[[PFInstallation currentInstallation] saveInBackground];

    }
    else
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        UITabBarController *tabBC = [storyboard instantiateViewControllerWithIdentifier:@"SOTabBarController"];
        self.window.rootViewController = tabBC;
        [self setupSSKeyChain];
    }
    
    return YES;
}

#pragma mark _ Reachability

-(void)reachability{
    // Allocate a reachability object
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Set the blocks
    reach.reachableBlock = ^(Reachability*reach)
    {
        // keep in mind this is called on a background thread
        // and if you are updating the UI it needs to happen
        // on the main thread, like this:
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"REACHABLE!");
        });
    };
    
    reach.unreachableBlock = ^(Reachability*reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
       //     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            //
//            UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"SOMainNavigationControllerIdentifier"];



//            SOProjectsViewController *vc = (SOProjectsViewController *)nc.topViewController;
//            self.window.rootViewController = nc;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Network Error" message:@"Network currently unreachable" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [alert addAction:okAction];
            //[tabBC.visibleViewController presentViewController:alert animated:YES completion:nil];
            
        });
        NSLog(@"UNREACHABLE!");
    };
    
    // Start the notifier, which will cause the reachability object to retain itself!
    [reach startNotifier];
}

#pragma mark - SSKeychain Login and Sign up Methods
-(void)setupSSKeyChain
{
    // Specify how the keychain items can be accessed
    [SSKeychain setAccessibilityType:kSecAttrAccessibleWhenUnlocked];
    
    // Set an access token for later use
    NSString *username = [[NSUUID UUID] UUIDString];
    NSString *password = [[NSUUID UUID] UUIDString];
    [SSKeychain setPassword:username forService:@"ShoutoutUsernameService" account:@"com.Shoutout.keychain"];
    
    [SSKeychain setPassword:password forService:@"ShoutoutPasswordService" account:@"com.Shoutout.keychain"];
    
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"password"];
    
    [self signUpUserWithSSKeyChain:username :password];
    
    [[SOCachedProjects sharedManager].cachedProjects setObject:username forKey:@"UUID"];
}

-(void)signUpUserWithSSKeyChain:(NSString *)username :(NSString *)password
{
    User *user = [User user];
    user.username = username;
    user.password = password;
    user.contacts = [SOContacts new];
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(!error)
        {
            NSLog(@"Successfully signedup user in background with uuid");
        }
        else
        {
//            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            //
//            UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"SOMainNavigationControllerIdentifier"];
//            
//            SOProjectsViewController *vc = (SOProjectsViewController *)nc.topViewController;
//            self.window.rootViewController = nc;
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            UITabBarController *tabBC = [storyboard instantiateViewControllerWithIdentifier:@"SOTabBarController"];
            self.window.rootViewController = tabBC;
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Signup Error" message:@"Couldn't signup automatic user, Please re-run the app!" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [alert addAction:okAction];
            [tabBC presentViewController:alert animated:YES completion:nil];
        }
    }];
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"SOMainNavigationControllerIdentifier"];
//    
//    SOProjectsViewController *vc = (SOProjectsViewController *)nc.topViewController;
//    self.window.rootViewController = nc;
}

#pragma mark -  Push Notifications

-(void)setupPushNotifications:(UIApplication *)application{
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
}


//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
//    // Store the deviceToken in the current installation and save it to Parse.
//    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//    [currentInstallation setDeviceTokenFromData:deviceToken];
//    currentInstallation.channels = @[ @"global" ];
//    [currentInstallation saveInBackground];
//}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    [PFPush handlePush:userInfo];
//}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "nyc.c4q.mesbekmek.Shoutout" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Shoutout" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Shoutout.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
