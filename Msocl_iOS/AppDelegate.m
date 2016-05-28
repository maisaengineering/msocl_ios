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
//#import <Parse/Parse.h>
#import "SlideNavigationController.h"
#import "MenuViewController.h"
#import "PageGuidePopUps.h"
#import "ModelManager.h"
#import "PostDetailDescriptionViewController.h"
#import "UserProfileViewCotroller.h"
#import "UIImage+GIF.h"
#import "Base64.h"
#import "CustomCipher.h"
#import <Parse/Parse.h>
#import "Reachability.h"
#import "AddPostViewController.h"
#import "TagViewController.h"
#import "LoginViewController.h"
#import "NotificationUtils.h"
#import "PromptViewController.h"
#import <Fabric/Fabric.h>
#import "CustomCipher.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Crashlytics/Crashlytics.h>
#import "Branch.h"

@interface AppDelegate ()<MBProgressHUDDelegate,PromptDelegate>
{
    
    NSString *notifiUID;
    NSDictionary *userDict;
    UIAlertView *updateAlert;
    
}
@end

@implementation AppDelegate
@synthesize indicator;
@synthesize isAppFromBackground;
@synthesize isAppFromPushNotifi;
@synthesize isPushCalled;
@synthesize parseToken;
@synthesize promptView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    /*
    [Parse setApplicationId:PARSE_APPLICATION_KEY
                  clientKey:PARSE_CLIENT_KEY];
     */
    
    [self setUserDatails];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentAppVersion = APP_VERSION;
    NSString *previousVersion = [defaults objectForKey:@"appVersion"];
    if(!previousVersion)
    {
        [defaults setObject:previousVersion forKey:@"appversion"];
    
    }
    else if (![previousVersion isEqualToString:currentAppVersion])
    {
        
        [defaults removeObjectForKey:@"FORCED_UPDATE"];
        [defaults setObject:currentAppVersion forKey:@"appversion"];
        
        //////Cleaning Rating info
        [defaults removeObjectForKey:@"ratedapp"];
        [defaults removeObjectForKey:@"last_shown_date"];
        [defaults removeObjectForKey:@"shownOneTime"];
    }
   
    [defaults removeObjectForKey:@"PageGuidePopUpImages"];
    [defaults synchronize];
    

    //note: iOS only allows one crash reporting tool per app; if using another, set to: NO
   // [Flurry setCrashReportingEnabled:YES];
    [Fabric with:@[CrashlyticsKit]];

    [Flurry startSession:FLURRY_KEY];

    [Parse setApplicationId:PARSE_APPLICATION_KEY
                  clientKey:PARSE_CLIENT_KEY];
    
    
    indicator = [[MBProgressHUD alloc] initWithView:self.window];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [imageView setImage:[UIImage sd_animatedGIFNamed:@"Preloader_2"]];
    indicator.customView = imageView;
    indicator.mode = MBProgressHUDModeCustomView;
    
    //set the nav bar appearance for the entire application
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor whiteColor], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"SanFranciscoDisplay-Regular" size:18], NSFontAttributeName, nil]];

    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:197/255.0 green:33/255.0 blue:40/255.0 alpha:1.0]];

    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    MenuViewController *leftMenu = (MenuViewController*)[mainStoryboard
                                                                 instantiateViewControllerWithIdentifier: @"MenuViewController"];
    
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
    
     isAppFromBackground = NO;
    
    if (launchOptions != nil)
    {

        NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil)
        {
            if(!isPushCalled)
            {
                isPushCalled = YES;
                notifiUID = [dictionary objectForKey:@"uid"];
                userDict = dictionary;

            }
        }
    }

    Branch *branch = [Branch getInstance];
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        // route the user based on what's in params
    }];


    return YES;
//    return [[FBSDKApplicationDelegate sharedInstance] application:application
//                                    didFinishLaunchingWithOptions:launchOptions];
}
-(void)setUserDatails
{
if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
{
    
    NSDictionary *tokenDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"tokens"];
    NSDictionary *userDetailsDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"userprofile"];
    
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]
                                  initWithSuiteName:@"group.com.maisasolutions.msocl"];
    [myDefaults setObject:userDetailsDict forKey:@"userprofile"];
    [myDefaults setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"] forKey:@"access_token"];
    [myDefaults setObject:tokenDict forKey:@"tokens"];
    [myDefaults synchronize];
    
    [[ModelManager sharedModel] setDetailsFromUserDefaults];
    
}
}
//If the registration is successful, the callback method is the below one
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    /*
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
     */


    
        // Store the deviceToken in the current installation and save it to Parse.
    
    parseToken = deviceToken;
    
    NSString *strDeviceToken = [deviceToken description];
    strDeviceToken = [strDeviceToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    strDeviceToken = [strDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];

    // Store the Device token in UserDefaulst for future purpose
    [[NSUserDefaults standardUserDefaults] setObject:strDeviceToken forKey:DEVICE_TOKEN_KEY];
    
   
        [NotificationUtils resetParseChannels];
    
}

//When a push notification is received while the application is not in the foreground, it is displayed in the iOS Notification Center.
//However, if the notification is received while the app is active, it is up to the app to handle it. To do so, we can implement this method
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    NSDictionary *context = [userInfo valueForKey:@"context"];
    if(context != nil)
    {
        NSString *type = [[context valueForKey:@"type"] lowercaseString];
        if(![type isEqualToString:@"admin"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"notificationcount"] intValue]+1] forKey:@"notificationcount"];
        }
    }

    

    if ( (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) && ![[userInfo objectForKey:@"uid"] isEqualToString:notifiUID] )
    {
        [self addMessageFromRemoteNotification:userInfo];
    }
    else if(application.applicationState == UIApplicationStateActive)
    {
        NSDictionary *context = [userInfo valueForKey:@"context"];
        if(context != nil)
        {
            NSString *type = [[context valueForKey:@"type"] lowercaseString];
            NSString *uid = [context valueForKey:@"uid"];

        if([type isEqualToString:@"admin"])
        {
            if([[uid uppercaseString] isEqualToString:@"FORCED_UPDATE"])
            {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FORCED_UPDATE"];
                
                UIApplicationState state = [[UIApplication sharedApplication] applicationState];
                if(state == UIApplicationStateActive && [[[NSUserDefaults standardUserDefaults] objectForKey:@"appversion"] isEqualToString:APP_VERSION])
                {
                    [self updateApp:YES];
                }
                
            }
            else if([[uid uppercaseString] isEqualToString:@"UPDATE"])
            {
                UIApplicationState state = [[UIApplication sharedApplication] applicationState];
                if(state == UIApplicationStateActive && [[[NSUserDefaults standardUserDefaults] objectForKey:@"appversion"] isEqualToString:APP_VERSION])
                {
                    [self updateApp:NO];
                }
            }
        }
        }
    }
    NSLog(@"notifiUID is:%@", notifiUID);

    NSLog(@"RECIEVE :%@", [userInfo objectForKey:@"uid"]);


    [PFPush handlePush:userInfo];
    
}
-(void)pushNotificationClicked
{
    [self addMessageFromRemoteNotification:userDict];
}
- (void)addMessageFromRemoteNotification:(NSDictionary*)userInfo
{
 
    DebugLog(@"in  has notifications %s",__func__);
    
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"killed"];
    
    NSDictionary *context = [userInfo valueForKey:@"context"];
    
    NSLog(@"My Device token is:%@", context);

    if(context != nil)
    {
    NSString *type = [[context valueForKey:@"type"] lowercaseString];
    NSString *uid = [context valueForKey:@"uid"];
    
        
    if([type isEqualToString:@"post"] || [type isEqualToString:@"comment"] || [type isEqualToString:@"vote"])
    {
        
        if(uid != nil && uid.length > 0)
        {
        [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    PostDetailDescriptionViewController *postDetailDescriptionViewController = (PostDetailDescriptionViewController*)[mainStoryboard
                                                                                                                      instantiateViewControllerWithIdentifier: @"PostDetailDescriptionViewController"];
    postDetailDescriptionViewController.postID = uid;
    SlideNavigationController *slide = [SlideNavigationController sharedInstance];
        dispatch_async(dispatch_get_main_queue(), ^{
            [slide pushViewController:postDetailDescriptionViewController animated:YES];
        });
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"notificationcount"] intValue]-1] forKey:@"notificationcount"];

    }
    else if([type isEqualToString:@"follower"])
    {

        if(uid != nil && uid.length > 0)
        {
        [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        UserProfileViewCotroller *postDetailDescriptionViewController = (UserProfileViewCotroller*)[mainStoryboard
                                                                                                                          instantiateViewControllerWithIdentifier: @"UserProfileViewCotroller"];
        postDetailDescriptionViewController.profileId = uid;
        SlideNavigationController *slide = [SlideNavigationController sharedInstance];
        dispatch_async(dispatch_get_main_queue(), ^{
            [slide pushViewController:postDetailDescriptionViewController animated:YES];
        });
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"notificationcount"] intValue]-1] forKey:@"notificationcount"];

    }
    else if([type isEqualToString:@"group"])
    {
        if(uid != nil && uid.length > 0)
        {
        
        [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        
        TagViewController *postDetailDescriptionViewController = (TagViewController*)[mainStoryboard
                                                                                                    instantiateViewControllerWithIdentifier: @"TagViewController"];
        postDetailDescriptionViewController.tagId = uid;
        SlideNavigationController *slide = [SlideNavigationController sharedInstance];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [slide pushViewController:postDetailDescriptionViewController animated:YES];
        });
        }

        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"notificationcount"] intValue]-1] forKey:@"notificationcount"];

    }
    else if([type isEqualToString:@"addpost"])
    {
        
        
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
        {
            [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
            
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];
            
            AddPostViewController *postDetailDescriptionViewController = (AddPostViewController*)[mainStoryboard
                                                                                                  instantiateViewControllerWithIdentifier: @"AddPostViewController"];
            SlideNavigationController *slide = [SlideNavigationController sharedInstance];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [slide pushViewController:postDetailDescriptionViewController animated:YES];
            });

        }
        else
        {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *login = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            CGFloat screenWidth = screenRect.size.width;
            CGFloat screenHeight = screenRect.size.height;
            
            login.view.frame = CGRectMake(0,-screenHeight,screenWidth,screenHeight);
            
            [[[[UIApplication sharedApplication] delegate] window] addSubview:login.view];
            
            SlideNavigationController *slide = [SlideNavigationController sharedInstance];

            
            dispatch_async(dispatch_get_main_queue(), ^{

                [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    login.view.frame = CGRectMake(0,0,screenWidth,screenHeight);
                    
                }
                                 completion:^(BOOL finished){
                                     [login.view removeFromSuperview];
                                     
                                     [slide pushViewController:login animated:NO];
                                 }
                 ];
                

                
            });

            


        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"notificationcount"] intValue]-1] forKey:@"notificationcount"];

        
    }
    else if([type isEqualToString:@"share"])
    {
        if(uid != nil && uid.length > 0)
        {
        
        [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        PostDetailDescriptionViewController *postDetailDescriptionViewController = (PostDetailDescriptionViewController*)[mainStoryboard
                                                                                                                          instantiateViewControllerWithIdentifier: @"PostDetailDescriptionViewController"];
        postDetailDescriptionViewController.postID = uid;
        postDetailDescriptionViewController.showShareDialog = YES;
        SlideNavigationController *slide = [SlideNavigationController sharedInstance];
        dispatch_async(dispatch_get_main_queue(), ^{
            [slide pushViewController:postDetailDescriptionViewController animated:YES];
        });
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"notificationcount"] intValue]-1] forKey:@"notificationcount"];

    }
    else if([type isEqualToString:@"admin"])
    {
        if([[uid uppercaseString] isEqualToString:@"FORCED_UPDATE"])
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FORCED_UPDATE"];
            
            UIApplicationState state = [[UIApplication sharedApplication] applicationState];
            if(state == UIApplicationStateActive && [[[NSUserDefaults standardUserDefaults] objectForKey:@"appversion"] isEqualToString:APP_VERSION])
            {
                [self updateApp:YES];
            }
            
        }
        else if([[uid uppercaseString] isEqualToString:@"UPDATE"])
        {
            UIApplicationState state = [[UIApplication sharedApplication] applicationState];
            if(state == UIApplicationStateActive && [[[NSUserDefaults standardUserDefaults] objectForKey:@"appversion"] isEqualToString:APP_VERSION])
            {
                [self updateApp:NO];
            }
        }
    }
    }
}
//Handles the fail callback when registering Parse for remote notifications
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    DebugLog(@"Failed to get token for Remote notifications, error: %@", error);
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    
    //[Flurry setCrashReportingEnabled:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    if([[[PageGuidePopUps sharedInstance] timer]isValid])
        [[[PageGuidePopUps sharedInstance] timer] invalidate];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [Flurry endTimedEvent:@"app_open_time" withParameters:nil];
    
    [[PageGuidePopUps sharedInstance] sendVisitedPageGuides];
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateInactive)
    {
        DebugLog(@"Sent to background by locking screen");
    }
    else if (state == UIApplicationStateBackground)
    {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"kDisplayStatusLocked"])
        {
            DebugLog(@"Sent to background by home button/switching to other app");
        }
        else
        {
            DebugLog(@"Sent to background by locking screen");
            
            // Save the Lock button pressed status in UserDefaults
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kUserClickedLockButton"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }


}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDisplayStatusLocked"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // checking the Lock button pressed status with UserDefaults
    
    BOOL isLockBtnPressed = [[NSUserDefaults standardUserDefaults] boolForKey:@"kUserClickedLockButton"];
    if (isLockBtnPressed )
    {
        isAppFromBackground = YES;
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kUserClickedLockButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    ModelManager *sharedModel = [ModelManager sharedModel];
    if (sharedModel.userProfile)
    {
        [Flurry setUserID:sharedModel.userProfile.uid];
    }
    else
    {
        [Flurry setUserID:DEVICE_UUID];
    }
    
    [Flurry logEvent:@"app_open_time" timed:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    
    
    application.applicationIconBadgeNumber = 0;

    if(token.access_token.length>0)
    {
        [[PageGuidePopUps sharedInstance] getAppConfig];

      /*  NSMutableArray *visited_reminders = [[NSUserDefaults standardUserDefaults] objectForKey:@"time_reminder_visits"];

        if(visited_reminders != nil && visited_reminders.count  > 0)
        {
            [[PageGuidePopUps sharedInstance] sendVisitedPageGuides];
        }
        else
       [[PageGuidePopUps sharedInstance] getPageGuidePopUpData];
       */
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"AppFromPassiveState" object:nil];

    if([[NSUserDefaults standardUserDefaults] boolForKey:@"FORCED_UPDATE"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"appversion"] isEqualToString:APP_VERSION])
    {
        [self updateApp:YES];
    }
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
       {
           [[PageGuidePopUps sharedInstance] trackNewUserSession];
           
       }
    
    //[NotificationUtils resetParseChannels];
    [[PageGuidePopUps sharedInstance] askForRateApp];

    [FBSDKAppEvents activateApp];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"killed"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//Called from multiple controllers to make sure we only ask at a relevant time
-(void)askForNotificationPermission
{
    if([[PageGuidePopUps sharedInstance] rateView] && [[[PageGuidePopUps sharedInstance] rateView] view].superview != nil)
    {
        self.deferNotificationPrompt = YES;
        return;
    }
    
    self.deferNotificationPrompt = NO;
    UIApplication *application = [UIApplication sharedApplication];
    
    BOOL enabled;
    
    // Try to use the newer isRegisteredForRemoteNotifications otherwise use the enabledRemoteNotificationTypes.
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        UIUserNotificationSettings *types = [application currentUserNotificationSettings];
        
        enabled = types.types & UIUserNotificationTypeAlert;;
    }
    else
    {
        UIRemoteNotificationType types = [application enabledRemoteNotificationTypes];
        enabled = types & UIRemoteNotificationTypeAlert;
    }
    
    if(!enabled)
    {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        promptView = (PromptViewController*)[mainStoryboard
                                             instantiateViewControllerWithIdentifier: @"PromptViewController"];
        promptView.delegate = self;
        [self.window addSubview:promptView.view];
    }
   else
   {
       [self responseFromPrompt:2];
   }
    
 //   SlideNavigationController *slide = [SlideNavigationController sharedInstance];
   // [slide presentViewController:promptView animated:NO completion:nil];

}
-(void)responseFromPrompt:(int)index
{
    if(index == 2)
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

//currently used for facebook callbacks
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    NSLog(@"query string: %@", [url query]);

    if([[url absoluteString] containsString:@"samepinchapp://"])
    {
        
        NSLog(@"query string: %@", [url query]);
        NSArray *array = [[url query] componentsSeparatedByString:@"&"];
        
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
        for(NSString *string in array)
        {
            NSArray *valueAndKey = [string componentsSeparatedByString:@"="];
            [tempDict setObject:[valueAndKey lastObject] forKey:[valueAndKey firstObject]];
            
        }
        
       NSDictionary *valuesDict = [NSDictionary dictionaryWithObject:tempDict forKey:@"context"];
        
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"killed"])
        {
            isPushCalled = YES;
            userDict = valuesDict;

        }
        else
        [self addMessageFromRemoteNotification:valuesDict];
        
        return YES;
    }
    [[Branch getInstance] handleDeepLink:url];

    
    if ([[url scheme] isEqualToString:FACEBOOK_SCHEME])
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];

    
    BOOL urlWasHandled = [FBAppCall handleOpenURL:url
                                sourceApplication:sourceApplication
                                  fallbackHandler:^(FBAppCall *call) {
                                      NSLog(@"Unhandled deep link: %@", url);
                                      // Here goes the code to handle the links
                                      // Use the links to show a relevant view of your app to the user
                                  }];

    
    return urlWasHandled;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    
    NSLog(@"user activity: %@", userActivity.userInfo);

    BOOL handledByBranch = [[Branch getInstance] continueUserActivity:userActivity];
    
    return handledByBranch;
}


#pragma mark -
#pragma mark Upadte 
-(void)updateApp:(BOOL)isForced
{
    if(!updateAlert.visible)
    {
    if(isForced)
    {
        updateAlert = [[UIAlertView alloc]initWithTitle:@"Update required!"
                                                       message:@"There's a new version of KidsLink. You must update to continue using the app."
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:@"Update", nil];
        updateAlert.tag = 2;
        [updateAlert show];
        
    }
    
    else
    {
        updateAlert = [[UIAlertView alloc]initWithTitle:@"Update available!"
                                                       message:@"Don't miss out on the latest KidsLink features and fixes."
                                                      delegate:self
                                             cancelButtonTitle:@"Skip"
                                             otherButtonTitles:@"Update", nil];
        updateAlert.tag = 1;
        [updateAlert show];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UPDATE"];
        
    }
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1)
    {
        switch (buttonIndex)
        {
            case 0:
            {
                
                break;
            }
            case 1:
            {
                NSString *iTunesLink = @"itms-apps://itunes.apple.com/us/app/id998823966?mt=8";
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
                
                break;
            }
            default:
            {
                
                break;
            }
        }
    }
    else
    {
        NSString *iTunesLink = @"itms-apps://itunes.apple.com/us/app/id998823966?mt=8";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
        
    }
    
}
@end
