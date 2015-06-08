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
#import "ModelManager.h"
#import "StringConstants.h"
#import "AppDelegate.h"

@implementation SettingsViewController
{
    UITableView *tableView;
    Webservices *webServices;

    NSDictionary *notifiResoonseDict;
}
@synthesize scrollView;
@synthesize changePasswordBtn;
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;

    
    
    self.title = @"SETTINGS";
    
    UIImage *background = [UIImage imageNamed:@"icon-back.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside]; //adding action
    [button setImage:background forState:UIControlStateNormal];
    button.frame = CGRectMake(0 ,0,13,17);
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    
    

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self getOptionsForExternalSignIn];
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
    notifiResoonseDict = recievedDict;
    
}
-(void)externalSigninOptionsFailed
{
    
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
-(IBAction)PushNotifiClicked:(id)sender
{
    if(notifiResoonseDict != nil)
    {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PushNotiSettingsViewController *login = [mainStoryboard instantiateViewControllerWithIdentifier:@"PushNotiSettingsViewController"];
        login.notifiResoonseDict = notifiResoonseDict;
    [[SlideNavigationController sharedInstance] pushViewController:login animated:YES];
    
    }
}
-(IBAction)emailNotifiClicked:(id)sender
{
    if(notifiResoonseDict != nil)
    {
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        EmailViewController *login = [mainStoryboard instantiateViewControllerWithIdentifier:@"EmailViewController"];
        login.notifiResoonseDict = notifiResoonseDict;
        [[SlideNavigationController sharedInstance] pushViewController:login animated:YES];
        
    }
}


@end

