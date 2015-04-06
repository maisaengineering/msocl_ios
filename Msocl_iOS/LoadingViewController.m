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
@implementation LoadingViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.navigationItem.hidesBackButton = YES;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    //CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    //add image with the frame set so the bottom stays the same
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Loading@2x.jpg"]];
    background.frame = CGRectMake(0, screenHeight - 568, 320, 568);
    [self.view addSubview:background]; //screenHeight - 1136
    
    UILabel *lblLoading = [[UILabel alloc] initWithFrame:CGRectMake(0,100,320, 41)];
    [lblLoading setText:LOADING];
    [lblLoading setBackgroundColor:[UIColor clearColor]];
    [lblLoading setTextAlignment:NSTextAlignmentCenter];
    [lblLoading setTextColor:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]];
    [lblLoading setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20]];
    [self.view addSubview:lblLoading];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self performSegueWithIdentifier: @"OnBoarding" sender: self];
    //[self callAccessTokenApi];
}

///Api call to get Accesstoken
-(void)callAccessTokenApi
{
    [appdelegate showOrhideIndicator:YES];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveTokens:) name:API_SUCCESS_GET_ACCESS_TOKEN object:Nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fetchingTokensFailedWithError) name:API_FAILED__GET_ACCESS_TOKEN object:Nil];
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"grant_type": @"client_credentials",
                           @"client_id": CLIENT_ID,
                           @"client_secret": CLIENT_SECRET,
                           @"scope": @"ikidslink"};
    
    NSDictionary *userInfo = @{@"command": @"GetAccessToken"};
    NSString *urlAsString = [NSString stringWithFormat:@"%@clients/token",BASE_URL];
    [[Webservices sharedInstance] getAccessToken:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}
#pragma mark- AccessToken Api callback Methods
#pragma mark-
- (void)didReceiveTokens:(NSNotification *)notificationObject
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:API_SUCCESS_GET_PROMPT_IMAGES object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:API_FAILED__GET_PROMPT_IMAGES object:nil];

    NSArray *tokens = [notificationObject object];
    [appdelegate showOrhideIndicator:NO];
    ModelManager *sharedModel = [ModelManager sharedModel];
    sharedModel.accessToken = [tokens objectAtIndex:0];
    
    [self performSegueWithIdentifier: @"OnBoarding" sender: self];
}

- (void)fetchingTokensFailedWithError
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:API_SUCCESS_GET_PROMPT_IMAGES object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:API_FAILED__GET_PROMPT_IMAGES object:nil];

    [appdelegate showOrhideIndicator:NO];
}
@end
