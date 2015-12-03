//
//  LoadingViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "LoadingViewController.h"
#import "MBProgressHUD.h"
#import "StringConstants.h"
#import "Webservices.h"
#import "AppDelegate.h"
#import "ModelManager.h"
#import "PageGuidePopUps.h"

@implementation LoadingViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;

    
    //add image with the frame set so the bottom stays the same
    UIImageView *background = [[UIImageView alloc] init];
    background.frame = CGRectMake(66, 100, 188, 50);
    background.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"cd-1.png"],[UIImage imageNamed:@"cd-2.png"],[UIImage imageNamed:@"cd-3.png"],[UIImage imageNamed:@"cd-4.png"], nil];
    background.animationDuration = 1;
    [background startAnimating] ;

    iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(149.5, 8, 21, 28)];
    [iconImage setImage:[UIImage imageNamed:@"header-icon-samepinch.png"]];
    
    [self.view addSubview:background]; //screenHeight - 1136
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    self.navigationItem.hidesBackButton = YES;

    [self.navigationController.navigationBar addSubview:iconImage];

    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    {
        
        NSDictionary *tokenDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"tokens"];
        NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"userprofile"];

        NSUserDefaults *myDefaults = [[NSUserDefaults alloc]
                                      initWithSuiteName:@"group.com.maisasolutions.msocl"];
        [myDefaults setObject:userDict forKey:@"userprofile"];
        [myDefaults setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"] forKey:@"access_token"];
        [myDefaults setObject:tokenDict forKey:@"tokens"];
        [myDefaults synchronize];
        
        [[ModelManager sharedModel] setDetailsFromUserDefaults];
        [self performSegueWithIdentifier: @"MainStreamsSegue" sender: self];
    }
    else
    {
        [self callAccessTokenApi];
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [iconImage removeFromSuperview];
    [super viewWillDisappear:YES];
    [self askForNotificationPermission];
    
}
-(void) askForNotificationPermission
{
    [appdelegate askForNotificationPermission];
}

///Api call to get Accesstoken
-(void)callAccessTokenApi
{
    
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

    [appdelegate showOrhideIndicator:NO];
    ModelManager *sharedModel = [ModelManager sharedModel];
    sharedModel.accessToken = [tokens objectAtIndex:0];
    
        [[PageGuidePopUps sharedInstance] getOptionsForExternalSignIn];

    
    NSMutableArray *visited_reminders = [[NSUserDefaults standardUserDefaults] objectForKey:@"time_reminder_visits"];
    
    if(visited_reminders != nil && visited_reminders.count  > 0)
    {
        [[PageGuidePopUps sharedInstance] sendVisitedPageGuides];
    }
    else
        [[PageGuidePopUps sharedInstance] getPageGuidePopUpData];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"onboarding"])
    [self performSegueWithIdentifier: @"MainStreamsSegue" sender: self];
    else
    [self performSegueWithIdentifier: @"OnBoarding" sender: self];
    
}

- (void)fetchingTokensFailedWithError
{

    [appdelegate showOrhideIndicator:NO];
}
@end
