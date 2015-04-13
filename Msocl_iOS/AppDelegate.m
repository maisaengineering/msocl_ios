//
//  AppDelegate.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/3/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "PromptImages.h"
#import "StringConstants.h"
#import "Flurry.h"
#import <Parse/Parse.h>
#import "SlideNavigationController.h"
#import "SettingsMenuViewController.h"
@interface AppDelegate ()<MBProgressHUDDelegate>

@end

@implementation AppDelegate
@synthesize indicator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [Parse setApplicationId:PARSE_APPLICATION_KEY
                  clientKey:PARSE_CLIENT_KEY];
    
    indicator = [[MBProgressHUD alloc] initWithView:self.window];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    SettingsMenuViewController *leftMenu = (SettingsMenuViewController*)[mainStoryboard
                                                                 instantiateViewControllerWithIdentifier: @"SettingsMenuViewController"];
    
    [SlideNavigationController sharedInstance].leftMenu = leftMenu;
    [SlideNavigationController sharedInstance].menuRevealAnimationDuration = .18;
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidClose object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Closed %@", menu);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidOpen object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Opened %@", menu);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidReveal object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Revealed %@", menu);
    }];
    

    return YES;
}

//If the registration is successful, the callback method is the below one
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

//When a push notification is received while the application is not in the foreground, it is displayed in the iOS Notification Center.
//However, if the notification is received while the app is active, it is up to the app to handle it. To do so, we can implement this method
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}

//Handles the fail callback when registering Parse for remote notifications
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    DebugLog(@"Failed to get token for Remote notifications, error: %@", error);
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    [Flurry startSession:FLURRY_KEY];
    [Flurry setCrashReportingEnabled:YES];
}

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
}

//Called from multiple controllers to make sure we only ask at a relevant time
-(void)askForNotificationPermission
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge
                                                                                             |UIUserNotificationTypeSound|UIUserNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
         UIRemoteNotificationTypeAlert|
         UIRemoteNotificationTypeSound];
    }
}


#pragma mark -
#pragma mark Methods To Show Activity Indicator
- (void)showOrhideIndicator:(BOOL)show
{
    
    if(show)
    {
        [self.window addSubview:indicator];
        [indicator show:YES];
    }
    else
    {
        [indicator hide:YES];
        [indicator setLabelText:@""];
        [indicator removeFromSuperview];
    }
    
}

- (void)showOrhideIndicator:(BOOL)show withMessage:(NSString *)message{
    
    if(show)
    {
        
        [self.window addSubview:indicator];
        [indicator show:YES];
        [indicator setLabelText:message];
        
    }
    else
    {
        [indicator removeFromSuperview];
        [indicator hide:YES];
        [indicator setLabelText:@""];
    }
}
@end
