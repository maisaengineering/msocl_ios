//
//  AppDelegate.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/3/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;
@interface AppDelegate : UIResponder <UIApplicationDelegate>


@property (strong, nonatomic) UIWindow *window;

/////Property & Method To show/hide acitivityindicator
@property (nonatomic,retain) MBProgressHUD *indicator;
@property (nonatomic) BOOL isAppFromBackground;
@property (nonatomic) BOOL isAppFromPushNotifi;
@property (nonatomic) BOOL isPushCalled;
@property (nonatomic, strong) NSData *parseToken;

- (void)showOrhideIndicator:(BOOL)show;
- (void)showOrhideIndicator:(BOOL)show withMessage:(NSString *)message;
-(void)askForNotificationPermission;
-(void)pushNotificationClicked;
@end

