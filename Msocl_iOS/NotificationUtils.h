//
//  NotificationUtils.h
//  KidsLink
//
//  Created by Dale McIntyre on 12/28/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationUtils : NSObject

+(BOOL)isPhoneRegisteredForRemoteNotifications;
+(void)resetParseChannels;

@end
