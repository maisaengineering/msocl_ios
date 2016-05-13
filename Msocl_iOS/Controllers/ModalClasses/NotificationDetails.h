//
//  NotificationDetails.h
//  Msocl_iOS
//
//  Created by Maisa Pride on 5/13/16.
//  Copyright © 2016 Maisa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationDetails : NSObject

@property (nonatomic,strong) NSString *uid;
@property (nonatomic,strong) NSString *time;
@property (nonatomic,strong) NSString *url;
@property (nonatomic,strong) NSString *message;
@property (nonatomic, assign) BOOL isRead;

@end
