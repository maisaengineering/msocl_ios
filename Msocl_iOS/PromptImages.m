//
//  PromptImages.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "PromptImages.h"
#import "StringConstants.h"
#import "Webservices.h"
#import "ModelManager.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import "NotificationUtils.h"
#import "AppDelegate.h"
#import "SlideNavigationController.h"
#import "MainStreamsViewController.h"
//#import "Flurry.h"
#import "LoadingViewController.h"
@implementation PromptImages
static PromptImages *romptImagesObject = nil;

+ (id)sharedInstance
{
    /* Use this to make it a singleton class */
    if (romptImagesObject==Nil) {
        romptImagesObject=[[PromptImages alloc]init];
    }
    return romptImagesObject;
    /**/
    
}
-(id)init{
    if (romptImagesObject) {
        return romptImagesObject;
    }
    else{
        if (self=[super init]) {
            //initialize the variables
            webServices = [[Webservices alloc] init];
            webServices.delegate = self;
        }
        return self;
    }
}

#pragma mark -
#pragma mark Prompt Images Api
-(void)getPrompImages
{
    NSDictionary* postData = @{@"command": @"tour"};
    NSDictionary *userInfo = @{@"command": @"GetPromptImages"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}
-(void)didReceivePromptImages:(NSDictionary *)responseDict
{
    
    [[NSUserDefaults standardUserDefaults] setObject:[responseDict objectForKey:@"tour"] forKey:@"PromptImages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self getAllTourImagesFromList:[responseDict objectForKey:@"tour"]];

}
-(void)fetchingPromptImagesFailedWithError
{

}

-(void)getAllTourImagesFromList:(NSArray *)imageUrlsArray
{
    photoUtils = [ProfilePhotoUtils alloc];
    for(NSString *url in imageUrlsArray)
    {
        UIImage *thumb = [photoUtils getImageFromCache:url];
        if (thumb == nil)
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^(void)
                           {
                               NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                               UIImage* image = [[UIImage alloc] initWithData:imageData];
                               if (image) {
                                   [photoUtils saveImageToCache:url :image];
                               }
                           });
        }
    }
}

#pragma mark -
#pragma mark Groups
-(void)getAllGroups
{
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;

    NSDictionary* postData = @{@"command": @"favourites",@"access_token": token.access_token};
    NSDictionary *userInfo = @{@"command": @"GetAllGroups"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@groups",BASE_URL];
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}
-(void)didReceiveGroups:(NSDictionary *)responseDict
{
    [[NSUserDefaults standardUserDefaults] setObject:[responseDict objectForKey:@"groups"] forKey:@"Groups"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]
                                  initWithSuiteName:@"group.com.maisasolutions.msocl"];
    [myDefaults setObject:[responseDict objectForKey:@"groups"] forKey:@"Groups"];
    [myDefaults synchronize];
}
-(void)fetchingGroupsFailedWithError
{
    
}

#pragma mark -
#pragma mark 401 Error

-(void)ClearOnAuhorisationError
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO forKey:@"isLogedIn"];
    [userDefaults setBool:NO forKey:@"HAS_REGISTERED_KLID"];
    [userDefaults removeObjectForKey:@"notificationcount"];
    [userDefaults setBool:NO forKey:@"externalSignIn"];
    [userDefaults removeObjectForKey:@"favStreamArray"];
    
    [userDefaults synchronize];
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]
                                  initWithSuiteName:@"group.com.maisasolutions.msocl"];
    [myDefaults  removeObjectForKey:@"userprofile"];
    [myDefaults removeObjectForKey:@"access_token"];
    [myDefaults removeObjectForKey:@"tokens"];
    
    [myDefaults synchronize];
    
    [[ModelManager sharedModel] clear];
    
    SlideNavigationController *slide = [SlideNavigationController sharedInstance];

    [slide closeMenuWithCompletion:nil];
    
    
    AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    [appdelegate showOrhideIndicator:NO];
    
    [self callAccessTokenApi];
    
    
   
}

#pragma mark -
#pragma mark New Token
-(void)callAccessTokenApi
{
    AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    [appdelegate showOrhideIndicator:YES];
    //build an info object and convert to json
    NSDictionary* postData = @{@"grant_type": @"client_credentials",
                               @"client_id": CLIENT_ID,
                               @"client_secret": CLIENT_SECRET,
                               @"scope": @"imsocl"};
    
    NSDictionary *userInfo = @{@"command": @"GetAccessToken"};
    NSString *urlAsString = [NSString stringWithFormat:@"%@clients/token",BASE_URL];
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}
#pragma mark- AccessToken Api callback Methods
#pragma mark-
- (void)didReceiveTokens:(NSArray *)tokens
{
    //invalidate current facebook session
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession.activeSession close];
    [FBSession setActiveSession:nil];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"share"];
    
    AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    [appdelegate showOrhideIndicator:NO];
    ModelManager *sharedModel = [ModelManager sharedModel];
    sharedModel.accessToken = [tokens objectAtIndex:0];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    LoadingViewController *loadingViewController = (LoadingViewController*)[mainStoryboard
                                                                            instantiateViewControllerWithIdentifier: @"LoadingViewController"];
    MainStreamsViewController *mainStreamsViewController = (MainStreamsViewController*)[mainStoryboard
                                                                                        instantiateViewControllerWithIdentifier: @"MainStreamsViewController"];
    
    [[SlideNavigationController sharedInstance]
     setViewControllers:[NSArray arrayWithObjects:loadingViewController,mainStreamsViewController, nil]];

    if([[[SlideNavigationController sharedInstance] topViewController] isKindOfClass:[MainStreamsViewController class]])
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:RELOAD_ON_LOG_OUT object:nil];
    }
    
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.channels = [[NSArray alloc] init];
    [currentInstallation saveEventually];
    
   // [Flurry setUserID:DEVICE_UUID];
    
    [[PageGuidePopUps sharedInstance] getAppConfig];
    [NotificationUtils resetParseChannels];
    
}

- (void)fetchingTokensFailedWithError
{
    AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    [appdelegate showOrhideIndicator:NO];
}

@end
