//
//  NotificationUtils.m
//  KidsLink
//
//  Created by Dale McIntyre on 12/28/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import "NotificationUtils.h"
#import <Parse/Parse.h>
#import "ModelManager.h"
#import "AppDelegate.h"

@implementation NotificationUtils

+(BOOL)isPhoneRegisteredForRemoteNotifications
{
    UIApplication *application = [UIApplication sharedApplication];
    
    BOOL enabled = FALSE;
    
    // Try to use the newer isRegisteredForRemoteNotifications otherwise use the enabledRemoteNotificationTypes.
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        enabled = [application isRegisteredForRemoteNotifications];
    }
    else
    {
        UIRemoteNotificationType types = [application enabledRemoteNotificationTypes];
        enabled = types & UIRemoteNotificationTypeAlert;
    }
    
    return enabled;
}

+(void)resetParseChannels
{
    AppDelegate *appDele = [[UIApplication sharedApplication] delegate];

    if(appDele.parseToken != nil && ![[NSUserDefaults standardUserDefaults] boolForKey:@"HAS_REGISTERED_KLID"])
    {
    ModelManager *sharedModel = [ModelManager sharedModel];
   
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:appDele.parseToken];
    NSString *channelName = [@"sp_" stringByAppendingString:sharedModel.userProfile.uid];
    currentInstallation.channels = @[channelName];
    // [currentInstallation saveInBackground];
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
    }];

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HAS_REGISTERED_KLID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
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
}

@end