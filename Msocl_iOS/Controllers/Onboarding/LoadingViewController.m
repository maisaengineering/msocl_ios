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

    iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(136.5, 8, 47, 28)];
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

    
    // Get the PageGuidePopUpImages
    NSMutableArray *pageGuidePopUpData = [[NSUserDefaults standardUserDefaults] objectForKey:@"PageGuidePopUpImages"];
    if ([pageGuidePopUpData count] == 0)
    {
        [[PageGuidePopUps sharedInstance] getPageGuidePopUpData];
    }
    else
    {
        [[PageGuidePopUps sharedInstance] getAllTimedReminderImagesWithURLS:pageGuidePopUpData];
    }
    
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
