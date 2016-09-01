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
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    sharedModel   = [ModelManager sharedModel];
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    
    [txt_username.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [txt_username.layer setBorderWidth:1];
    
    [btn_next.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [btn_next.layer setBorderWidth:1];
    
    // drop shadow
    [txt_username.layer setShadowColor:[UIColor whiteColor].CGColor];
    [txt_username.layer setShadowOpacity:0.8];
    [txt_username.layer setShadowRadius:1.0];
    
    
    [self.navigationController setNavigationBarHidden:YES];

}
-(IBAction)nextClicked:(id)sender
{
    [txt_username resignFirstResponder];
    
    
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
    
    
 //   [self performSegueWithIdentifier:@"LoginFirstToSecond" sender:self];
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
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginSecondViewController *login = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginSecondViewController"];
    login.userName = txt_username.text;
    if([[recievedDict objectForKey:@"newUser"] boolValue])
    {
        login.isSignUp = YES;
    }
    [self.navigationController pushViewController:login animated:YES];
    
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
