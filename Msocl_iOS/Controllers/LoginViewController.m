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
    {
        [self doLogin];
    }
}
-(void)doLogin
{
    [appdelegate showOrhideIndicator:YES];
    
    NSMutableDictionary *postDetails  = [NSMutableDictionary dictionary];
    [postDetails setObject:txt_username.text forKey:@"username"];
    [postDetails setObject:txt_password.text forKey:@"password"];
    
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    
    NSString *command = @"Login";
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": command,
                               @"body": postDetails};
    NSDictionary *userInfo = @{@"command": command};
    NSString *urlAsString = [NSString stringWithFormat:@"%@v2/posts",BASE_URL];
    
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}
-(void)loginSccessfull:(NSDictionary *)responseDict
{
    [appdelegate showOrhideIndicator:NO];
    [self.navigationController popViewControllerAnimated:YES];
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
