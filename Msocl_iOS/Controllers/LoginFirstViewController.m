//
//  LoginFirstViewController.m
//  Msocl_iOS
//
//  Created by Maisa Pride on 9/1/16.
//  Copyright © 2016 Maisa Solutions. All rights reserved.
//

#import "LoginFirstViewController.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "StringConstants.h"
#import "ModelManager.h"
#import "AppDelegate.h"
#import "LoginSecondViewController.h"
@interface LoginFirstViewController ()
{
    ModelManager *sharedModel;
    Webservices *webServices;
    AppDelegate *appDelegate;
}
@end

@implementation LoginFirstViewController
@synthesize txt_username;
@synthesize btn_next;
@synthesize backgroundView;
@synthesize topTextLabel;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    sharedModel   = [ModelManager sharedModel];
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    [backgroundView.layer setShadowColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.f].CGColor];
    [backgroundView.layer setShadowOpacity:1.0f];
    [backgroundView.layer setShadowOffset:CGSizeMake(1.f, 1.f)];
    [backgroundView.layer setShadowRadius:10.0f];
    
 
    [self.navigationController setNavigationBarHidden:YES];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(closeClicked:)];
    
    [self.view addGestureRecognizer:tap];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dontClose)];
    
    [backgroundView addGestureRecognizer:tap1];


}
-(IBAction)nextClicked:(id)sender
{
    [txt_username resignFirstResponder];
    
    
    if(self.isFromPhonePrompt)
    {
        if ([txt_username.text length] == 0)
        {
            ShowAlert(PROJECT_NAME,@"Please enter phone number", @"OK");
            return;
        }
        if([self validatePhoneNumberWithString:txt_username.text] )
        {
            [self doUpdate];
        }
        else
        {
            ShowAlert(PROJECT_NAME,@"Please provide a valid phone number", @"OK");
            return;
        }

    }
    else if(self.isFromEmailPrompt)
    {
        if ([txt_username.text length] == 0)
        {
            ShowAlert(PROJECT_NAME,@"Please enter email ", @"OK");
            return;
        }
        if([self validateEmailWithString:txt_username.text]  )
        {
            [self doUpdate];
        }
        else
        {
            ShowAlert(PROJECT_NAME,@"Please provide a valid email address", @"OK");
            return;
        }

    }
    else
    {
    if ([txt_username.text length] == 0)
    {
        ShowAlert(PROJECT_NAME,@"Please enter email or phone number", @"OK");
        return;
    }
    if([self validateEmailWithString:txt_username.text] ||[self validatePhoneNumberWithString:txt_username.text] )
    {
        [self evaluateUser];
    }
    else
    {
        ShowAlert(PROJECT_NAME,@"Please provide a valid email address or phone number", @"OK");
        return;
    }
    }
    
    
 //   [self performSegueWithIdentifier:@"LoginFirstToSecond" sender:self];
}
-(void)closeClicked:(UITapGestureRecognizer*)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CallClose" object:nil userInfo:nil];
}
-(void)dontClose
{
    
}
-(void)evaluateUser
{
    [appDelegate showOrhideIndicator:YES];
    
    NSMutableDictionary *postDetails  = [NSMutableDictionary dictionary];
    [postDetails setObject:txt_username.text forKey:@"auth_key"];
    
    AccessToken* token = sharedModel.accessToken;
    
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": @"evaluateUser",
                               @"body": postDetails};
    NSDictionary *userInfo = @{@"command": @"evaluateUser"};
    NSString *urlAsString = [NSString stringWithFormat:@"%@v2/users",BASE_URL];
    
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}
-(void) evaluateUserSuccessFull:(NSDictionary *)recievedDict
{
    [appDelegate showOrhideIndicator:NO];
    if([[recievedDict objectForKey:@"newUser"] boolValue])
    {
        self.isSignUp = YES;
    }
    else
    {
        self.isSignUp = NO;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"nextClicked" object:nil userInfo:nil];
  /*  UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginSecondViewController *login = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginSecondViewController"];
    login.userName = txt_username.text;
    if([[recievedDict objectForKey:@"newUser"] boolValue])
    {
        login.isSignUp = YES;
    }
    [self.navigationController pushViewController:login animated:YES];
    */
}
-(void) evaluateUserFailed:(NSDictionary *)recievedDict
{
    [appDelegate showOrhideIndicator:NO];
    
    if([recievedDict objectForKey:@"message"])
    {
        ShowAlert(@"Error", [recievedDict objectForKey:@"message"], @"OK");
    }
    else
    {
        ShowAlert(@"Error",@"User name is already taken. Please try another one", @"OK");
    }
    

}
- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (BOOL)validatePhoneNumberWithString:(NSString*)phoneNumber
{
    NSString *phoneRegex = @"^((\\+)|(00))[0-9]{6,14}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    
    NSString *filtered = [[phoneNumber componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    

    
    return [phoneTest evaluateWithObject:phoneNumber] ||[phoneNumber isEqualToString:filtered];
}

-(IBAction)returnClicked:(id)sender
{
    [txt_username resignFirstResponder];
}

-(void)doUpdate
{
    [appDelegate showOrhideIndicator:YES];
    NSMutableDictionary *postDetails  = [NSMutableDictionary dictionary];
    if(_isFromPhonePrompt)
    {
        [postDetails setObject:txt_username.text forKey:@"phno"];
        NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
        NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
        if(countryCode != nil)
            [postDetails setObject:countryCode forKey:@"country"];
    }
    if(_isFromEmailPrompt)
    [postDetails setObject:txt_username.text forKey:@"email"];
    
    
    AccessToken* token = sharedModel.accessToken;
    
    NSString *command = @"SignUp";
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": @"update",
                               @"body": postDetails};
    NSDictionary *userInfo = @{@"command": command};
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}

-(void)signUpSccessfull:(NSDictionary *)responseDict
{
    
    [[NSUserDefaults standardUserDefaults] setObject:responseDict forKey:@"userprofile"];
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]
                                  initWithSuiteName:@"group.com.maisasolutions.msocl"];
    [myDefaults setObject:responseDict forKey:@"userprofile"];
    [myDefaults synchronize];
    
    [sharedModel setUserDetails:responseDict];
    
    [appDelegate showOrhideIndicator:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"nextClicked" object:nil userInfo:nil];
}
-(void)signUpFailed:(NSDictionary *)responseDict
{
    [appDelegate showOrhideIndicator:NO];
    if([responseDict objectForKey:@"message"] != nil &&[[responseDict objectForKey:@"message"] length] > 0 )
    {
        NSString *str =  [responseDict objectForKey:@"message"];
        ShowAlert(@"Error",str , @"OK");
    }
    else
    {
        ShowAlert(@"Error", @"Updation Failed", @"OK");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
