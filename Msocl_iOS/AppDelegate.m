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

@interface AppDelegate ()<MBProgressHUDDelegate>

@end

@implementation AppDelegate
@synthesize indicator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    indicator = [[MBProgressHUD alloc] initWithView:self.window];

    [[PromptImages sharedInstance] getPrompImages];
    return YES;
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
