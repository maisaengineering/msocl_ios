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
#import "FogotPasswordViewController.h"
@implementation LoginViewController
{
    AppDelegate *appdelegate;
    Webservices *webServices;
}
@synthesize txt_username;
@synthesize txt_password;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    appdelegate = [[UIApplication sharedApplication] delegate];
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    
    UIColor *color = [UIColor lightGrayColor];
    UIFont *font = [UIFont fontWithName:@"Ubuntu-LightItalic" size:12.0];
    
    txt_password.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"Enter password"
                                    attributes:@{
                                                 NSForegroundColorAttributeName: color,
                                                 NSFontAttributeName : font
                                                 }
     ];
    txt_username.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"Enter email id"
                                    attributes:@{
                                                 NSForegroundColorAttributeName: color,
                                                 NSFontAttributeName : font
                                                 }
     ];
 
    [self preferredStatusBarStyle];
    
    // To dismiss the keyboard when user taps on anywhere in the page.
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureUpdated:)];
    singleTap.delegate = self;
    singleTap.cancelsTouchesInView = NO;
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
}
- (void)tapGestureUpdated:(UIGestureRecognizer *)recognizer
{
    [txt_username resignFirstResponder];
    [txt_password resignFirstResponder];
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];

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
-(void)loginSccessfull:(NSDictionary *)responseDict
{
    
    [appdelegate showOrhideIndicator:NO];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLogedIn"];

    [[NSUserDefaults standardUserDefaults] setObject:responseDict forKey:@"userprofile"];
    
    NSMutableDictionary *tokenDict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"tokens"] mutableCopy];
    [tokenDict setObject:[responseDict objectForKey:@"access_token"] forKey:@"access_token"];
    [[NSUserDefaults standardUserDefaults] setObject:tokenDict forKey:@"tokens"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];

    
    [[[ModelManager sharedModel] accessToken] setAccess_token:[responseDict objectForKey:@"access_token"]];
    [[ModelManager sharedModel] setUserDetails:responseDict];
    [[PromptImages sharedInstance] getAllGroups];
    [self.navigationController popViewControllerAnimated:NO];
}
-(void)loginFailed
{
    [appdelegate showOrhideIndicator:NO];
    ShowAlert(@"Error", @"Login Failed", @"OK");
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
    UIStoryboard *sBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebViewController *webViewController = [sBoard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.tagValue = (int)[sender tag];
    [self.navigationController pushViewController: webViewController animated:YES];
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
