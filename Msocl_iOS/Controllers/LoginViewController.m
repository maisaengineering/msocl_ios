//
//  LoginViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/7/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "LoginViewController.h"
#import "ModelManager.h"
#import "StringConstants.h"
#import "AppDelegate.h"
#import "PromptImages.h"
#import "WebViewController.h"
#import "SignUpViewController.h"
#import "NotificationUtils.h"
#import "FogotPasswordViewController.h"
#import "Flurry.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "PageGuidePopUps.h"

@implementation LoginViewController
{
    AppDelegate *appdelegate;
    Webservices *webServices;
}
@synthesize txt_username;
@synthesize txt_password;
@synthesize facebookButton;
@synthesize googleButton;
@synthesize twitterButton;
@synthesize loginWith;

-(void)viewDidLoad
{
    [super viewDidLoad];
    

    
    appdelegate = [[UIApplication sharedApplication] delegate];
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    UIColor *color = [UIColor lightGrayColor];
    UIFont *font = [UIFont fontWithName:@"SanFranciscoText-LightItalic" size:14];
    
    txt_password.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"password"
                                    attributes:@{
                                                 NSForegroundColorAttributeName: color,
                                                 NSFontAttributeName : font
                                                 }
     ];
    txt_username.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"email"
                                    attributes:@{
                                                 NSForegroundColorAttributeName: color,
                                                 NSFontAttributeName : font
                                                 }
     ];
    
    
    
    // To dismiss the keyboard when user taps on anywhere in the page.
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureUpdated:)];
    singleTap.delegate = self;
    singleTap.cancelsTouchesInView = NO;
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    NSMutableArray *externalSignInOptions = [[NSUserDefaults standardUserDefaults] objectForKey:@"externalSignInOptions"];
    if([externalSignInOptions count] == 3)
        loginWith.hidden = YES;
    else
        loginWith.hidden = NO;
   
        float x = 16+(288-(3 - [externalSignInOptions count])*92 - (3 - [externalSignInOptions count]-1)*6)/2 ;
        
        if([externalSignInOptions containsObject:@"facebook"])
        {
            [facebookButton setHidden:YES];
        }
    
        
        if([externalSignInOptions containsObject:@"twitter"])
        {
            [twitterButton setHidden:YES];
        }
        else
        {
            [twitterButton setHidden:NO];
            CGRect frame = twitterButton.frame;
            frame.origin.x = x;
            twitterButton.frame = frame;
            x+=98;
        }
        
        
        if([externalSignInOptions containsObject:@"google"])
        {
            [googleButton setHidden:YES];
        }
        else
        {
            [googleButton setHidden:NO];
            CGRect frame = googleButton.frame;
            frame.origin.x = x;
            googleButton.frame = frame;
            x+=98;
        }
    
    [Flurry logEvent:@"navigation_to_login"];

    
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)tapGestureUpdated:(UIGestureRecognizer *)recognizer
{
    [txt_username resignFirstResponder];
    [txt_password resignFirstResponder];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [super viewWillAppear:YES];

}
-(void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [super viewWillDisappear:YES];
}
-(IBAction)closeClicked:(id)sender
{
    [self resignKeyBoards];
    [self.navigationController popViewControllerAnimated:NO];
}
#pragma mark -
#pragma mark Login Methods
-(IBAction)loginClicked:(id)sender
{
    
    [self resignKeyBoards];
    if( txt_password.text.length == 0 || txt_username.text.length == 0)
    {
        if ([txt_password.text length] == 0)
        {
            ShowAlert(PROJECT_NAME,@"Please enter password", @"OK");
            return;
        }
        else if ([txt_username.text length] == 0)
        {
            ShowAlert(PROJECT_NAME,@"Please enter user name", @"OK");
            return;
        }
        else
        {
            ShowAlert(PROJECT_NAME,@"Please enter user name and password", @"OK");
            return;
        }
        
    }
    else
        if([self validateEmailWithString:txt_username.text])
        {
            [self doLogin];
        }
        else
        {
            ShowAlert(PROJECT_NAME,@"Please provide a valid email address", @"OK");
            return;
        }
}
- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
-(void)doLogin
{
    [appdelegate showOrhideIndicator:YES];
    
    NSMutableDictionary *postDetails  = [NSMutableDictionary dictionary];
    [postDetails setObject:txt_username.text forKey:@"email"];
    [postDetails setObject:txt_password.text forKey:@"password"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN_KEY] != nil)
        [postDetails setObject:[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN_KEY] forKey:@"device_token"];
    [postDetails setObject:@"iOS" forKey:@"platform"];
    
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": @"signIn",
                               @"body": postDetails};
    NSDictionary *userInfo = @{@"command": @"Login"};
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}
-(void)loginSccessfull:(NSDictionary *)recievedDict
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLogedIn"];
    
    [[NSUserDefaults standardUserDefaults] setObject:recievedDict forKey:@"userprofile"];
    
    NSMutableDictionary *tokenDict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"tokens"] mutableCopy];
    [tokenDict setObject:[recievedDict objectForKey:@"access_token"] forKey:@"access_token"];
    [[NSUserDefaults standardUserDefaults] setObject:tokenDict forKey:@"tokens"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"externalSignIn"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]
                                  initWithSuiteName:@"group.com.maisasolutions.msocl"];
    [myDefaults setObject:recievedDict forKey:@"userprofile"];
    [myDefaults setObject:[recievedDict objectForKey:@"access_token"] forKey:@"access_token"];
    [myDefaults setObject:tokenDict forKey:@"tokens"];
    [myDefaults synchronize];
    
    
    [[[ModelManager sharedModel] accessToken] setAccess_token:[recievedDict objectForKey:@"access_token"]];
    [[ModelManager sharedModel] setUserDetails:recievedDict];
    [[PromptImages sharedInstance] getAllGroups];
    
    
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    [self.navigationController popToViewController:viewControllers[viewControllers.count - 2] animated:YES];
    
    ModelManager *sharedModel = [ModelManager sharedModel];
    if (sharedModel.userProfile)
    {
        [Flurry setUserID:sharedModel.userProfile.uid];
    }
    else
    {
        [Flurry setUserID:DEVICE_UUID];
    }
    
        [[PageGuidePopUps sharedInstance] trackNewUserSession];
        [[PageGuidePopUps sharedInstance] getAppConfig];
    
    [NotificationUtils resetParseChannels];

}
-(void)loginFailed:(NSDictionary *)recievedDict
{
    [Flurry logEvent:@"login_failed"];
    [appdelegate showOrhideIndicator:NO];
    
    if([recievedDict objectForKey:@"message"])
    {
        ShowAlert(@"Error", [recievedDict objectForKey:@"message"], @"OK");
    }
    else
    {
        ShowAlert(@"Error",@"Failed to login to Facebook. Please try again", @"OK");
    }
    
}



#pragma mark -
#pragma mark Fogot Password Methods
-(IBAction)forgotPasswordClicked:(id)sender
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FogotPasswordViewController *forgetPassVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"FogotPasswordViewController"];
    [self.navigationController pushViewController:forgetPassVC animated:NO];
    
}

-(IBAction)registerClicked:(id)sender
{
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SignUpViewController *signUP = [mainStoryboard instantiateViewControllerWithIdentifier:@"SignUpViewController"];
    [self.navigationController pushViewController:signUP animated:YES];
    
}

- (IBAction)facebookButtonClikced:(id)sender
{
    
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login
         logInWithReadPermissions: @[@"public_profile",@"email"]
         handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
             if (error) {
                 NSLog(@"Process error");
                 ShowAlert(PROJECT_NAME,@"Failed to login. Please try again.", @"OK");
                 
             } else if (result.isCancelled) {
                 NSLog(@"Cancelled");
                 ShowAlert(PROJECT_NAME,@"Failed to login. Please try again.", @"OK");
             } else {
                 NSLog(@"Logged in");
                 NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
                 [parameters setValue:@"id,first_name,last_name,email,picture.width(600).height(600)" forKey:@"fields"];
                 [appdelegate showOrhideIndicator:YES];
                 
                 [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
                  startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                               id result, NSError *error) {
                      if(!error)
                      {
                          NSDictionary *response = (NSDictionary *)result;
                          if(response.count > 0)
                          {
                              
                              [self doFBLogin:result];
                          }
                          else
                          {
                              [appdelegate showOrhideIndicator:NO];
                              ShowAlert(PROJECT_NAME,@"Failed to login. Please try again,", @"OK");
                              
                          }
                      }
                      else
                      {
                          [appdelegate showOrhideIndicator:NO];
                          ShowAlert(PROJECT_NAME,@"Failed to login. Please try again.", @"OK");
                          ;
                      }
                      [[FBSDKLoginManager new] logOut];
                  }];
             }
         }];
        [login logOut];

}

-(void)doFBLogin:(NSDictionary *)userDetailsDict
{
    NSMutableDictionary *postDetails  = [NSMutableDictionary dictionary];
    [postDetails setObject:@"facebook" forKey:@"provider"];
    [postDetails setObject:[userDetailsDict objectForKey:@"id"] forKey:@"oauth_uid"];
    [postDetails setObject:[userDetailsDict objectForKey:@"first_name"] forKey:@"fname"];
    [postDetails setObject:[userDetailsDict objectForKey:@"last_name"] forKey:@"lname"];
    if([userDetailsDict objectForKey:@"email"])
    [postDetails setObject:[userDetailsDict objectForKey:@"email"] forKey:@"email"];
    [postDetails setObject:[[[userDetailsDict objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"] forKey:@"rphoto"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN_KEY] != nil)
        [postDetails setObject:[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN_KEY] forKey:@"device_token"];
    [postDetails setObject:@"iOS" forKey:@"platform"];
    
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": @"externalSignIn",
                               @"body": postDetails};
    NSDictionary *userInfo = @{@"command": @"Login"};
    NSString *urlAsString = [NSString stringWithFormat:@"%@v2/users",BASE_URL];
    
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}

#pragma mark -
#pragma mark Textfield methods
-(void)resignKeyBoards
{
    for (UIView *i in self.view.subviews)
    {
        if([i isKindOfClass:[UITextField class]]){
            UITextField *txtfield = (UITextField *)i;
            {
                [txtfield resignFirstResponder];
            }
        }
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
@end
