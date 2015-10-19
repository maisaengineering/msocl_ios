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
    ModelManager *sharedModel = [ModelManager sharedModel];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    NSArray *currentChannels = currentInstallation.channels;
    BOOL foundCurrent = FALSE;
    NSString *channelName = sharedModel.userProfile.uid;
    
    if (currentChannels != nil)
    {
        for (id object in currentChannels)
        {
            if (![object isEqualToString:channelName])
            {
                [currentInstallation removeObject:object forKey:@"channels"];
                [currentInstallation saveEventually];
            }
            else
            {
                foundCurrent = TRUE;
            }
        }
    }
    else
    {
        currentInstallation.channels = [[NSArray alloc] init];
    }
    
    if (!foundCurrent)
    {
        [currentInstallation addUniqueObject:channelName forKey:@"channels"];
        [currentInstallation saveEventually];
    }
    
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HAS_REGISTERED_KLID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end