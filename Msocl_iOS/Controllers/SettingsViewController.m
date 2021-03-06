//
//  SettingsViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/22/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "SettingsViewController.h"
#import "ChangePasswordViewController.h"
#import "SlideNavigationController.h"
#import "ManageTagsViewController.h"
#import "UpdateUserDetailsViewController.h"
#import "PushNotiSettingsViewController.h"
#import "EmailViewController.h"
#import "ShareSettingsViewController.h"
#import "ModelManager.h"
#import "StringConstants.h"
#import "AppDelegate.h"
#import "WebViewController.h"

@implementation SettingsViewController
{
    UITableView *tableView;
    Webservices *webServices;
    
    NSDictionary *notifiResoonseDict;
    AppDelegate *appdelegate;
}
@synthesize scrollView;
@synthesize changePasswordBtn;
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    appdelegate = [[UIApplication sharedApplication] delegate];
    
    
    self.title = @"SETTINGS";
    
    UIImage *background = [UIImage imageNamed:@"icon-back.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside]; //adding action
    [button setImage:background forState:UIControlStateNormal];
    button.frame = CGRectMake(0 ,10,13,17);
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //[appdelegate showOrhideIndicator:YES];
    //[self getOptionsForExternalSignIn];
}

#pragma mark -
#pragma mark Call to Disable External Sign in
-(void)getOptionsForExternalSignIn
{
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    NSString *command = @"appConfig";
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": command};
    NSDictionary *userInfo = @{@"command": command};
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}
-(void)externalSigninOptionsSuccessFull:(NSDictionary *)recievedDict
{
    [appdelegate showOrhideIndicator:NO];
    notifiResoonseDict = recievedDict;
    
}
-(void)externalSigninOptionsFailed
{
    [appdelegate showOrhideIndicator:NO];
}



-(void)backClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(IBAction)profileClicked:(id)sender
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UpdateUserDetailsViewController *login = [mainStoryboard instantiateViewControllerWithIdentifier:@"UpdateUserDetailsViewController"];
    [[SlideNavigationController sharedInstance] pushViewController:login animated:YES];
    
}
-(IBAction)allOthersTapped:(id)sender
{
    ModelManager *sharedModel = [ModelManager sharedModel];

    UIStoryboard *sBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebViewController *webViewController = [sBoard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.loadUrl = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@%@/app_setting",kBASE_URL,sharedModel.userProfile.uid]];
    [self.navigationController pushViewController: webViewController animated:YES];
}
-(IBAction)PushNotifiClicked:(id)sender
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PushNotiSettingsViewController *login = [mainStoryboard instantiateViewControllerWithIdentifier:@"PushNotiSettingsViewController"];
    login.notifiResoonseDict = notifiResoonseDict;
    [[SlideNavigationController sharedInstance] pushViewController:login animated:YES];
    
    
}
-(IBAction)emailNotifiClicked:(id)sender
{
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EmailViewController *login = [mainStoryboard instantiateViewControllerWithIdentifier:@"EmailViewController"];
    login.notifiResoonseDict = notifiResoonseDict;
    [[SlideNavigationController sharedInstance] pushViewController:login animated:YES];
    
    
}
-(IBAction)thirdrdPartyClicked:(id)sender
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShareSettingsViewController *login = [mainStoryboard instantiateViewControllerWithIdentifier:@"ShareSettingsViewController"];
    [[SlideNavigationController sharedInstance] pushViewController:login animated:YES];

}

@end

