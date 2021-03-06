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
#import "NIDropDown.h"
#import "QuartzCore/QuartzCore.h"

@interface LoginFirstViewController ()
{
    ModelManager *sharedModel;
    Webservices *webServices;
    AppDelegate *appDelegate;
    NSArray *countriesList;
    NIDropDown *dropDown;
    int selectedIndex;
   
    UIView *backGroundControl;
}
@end

@implementation LoginFirstViewController
@synthesize txt_username;
@synthesize btn_next;
@synthesize backgroundView;
@synthesize topTextLabel;
@synthesize btn_selectCountry;
@synthesize selectedCountryCode;
@synthesize verifyphonebgView;
@synthesize btn_selectPhoneCode;
@synthesize txt_phoneNumber;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    selectedIndex = -1;
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    sharedModel   = [ModelManager sharedModel];
    appDelegate = [[UIApplication sharedApplication] delegate];
    
 
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"countries" ofType:@"json"]];
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    countriesList = (NSArray *)parsedObject;

    
    [self.navigationController setNavigationBarHidden:YES];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(closeClicked:)];
    
    [self.view addGestureRecognizer:tap];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dontClose)];
    
    [backgroundView addGestureRecognizer:tap1];
    [verifyphonebgView addGestureRecognizer:tap1];

    
    
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    NSString *countryName = [currentLocale displayNameForKey:NSLocaleCountryCode value:countryCode];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@(%@)",countryName,countryCode] attributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14],NSForegroundColorAttributeName:[UIColor colorWithRed:13/255.0 green:130/255.0 blue:232/255.0 alpha:1.0]}];
//    [attributedString addAttributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
//                                      NSBackgroundColorAttributeName: [UIColor clearColor]} range:NSMakeRange(0, [attributedString.string length])];
    [btn_selectCountry setAttributedTitle:attributedString forState:UIControlStateNormal];
    
    backGroundControl = [[UIView alloc] initWithFrame:self.view.bounds];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]
                                    initWithTarget:self
                                    action:@selector(backGroundButtonCLicked)];
    
    [backGroundControl addGestureRecognizer:tap2];
    [backGroundControl setBackgroundColor:[UIColor clearColor]];
    

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    if(_isFromPhonePrompt)
    {
        NSString *countryCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"country"];
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"code = %@", countryCode];
        NSArray *filteredContacts = [countriesList filteredArrayUsingPredicate:filter];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[[filteredContacts firstObject] objectForKey:@"dial_code"] attributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14],NSForegroundColorAttributeName:[UIColor colorWithRed:13/255.0 green:130/255.0 blue:232/255.0 alpha:1.0]}];
        [btn_selectPhoneCode setAttributedTitle:attributedString forState:UIControlStateNormal];
        
        selectedCountryCode = countryCode;
        
    }
    

}
-(IBAction)nextClicked:(id)sender
{
    
    if(self.isFromPhonePrompt)
    {
        if ([txt_phoneNumber.text length] == 0)
        {
            ShowAlert(PROJECT_NAME,@"Please enter phone number", @"OK");
            return;
        }
        if([self validatePhoneNumberWithString:txt_phoneNumber.text] )
        {
             [txt_phoneNumber resignFirstResponder];
            [self confirmPhoneNumber];
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
             [txt_username resignFirstResponder];
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
         [txt_username resignFirstResponder];
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
-(void)backGroundButtonCLicked
{
    if(dropDown != nil)
    {
        if(verifyphonebgView.hidden)
            [dropDown hideDropDown:btn_selectCountry];
        else
            [dropDown hideDropDown:btn_selectPhoneCode];
        dropDown = nil;
        [backGroundControl removeFromSuperview];
    }

}
-(IBAction)selectCountryClicked:(id)sender
{
    
    if(dropDown == nil) {
        [txt_username resignFirstResponder];
        [self.view addSubview:backGroundControl];
        [self.view bringSubviewToFront:backGroundControl];
        CGFloat f = 200;
        dropDown = [[NIDropDown alloc]showDropDown:sender :&f :countriesList :nil :@"up" :YES];
        dropDown.delegate = self;
        dropDown.isCountry = YES;
    }
    else {
        [backGroundControl removeFromSuperview];
        [dropDown hideDropDown:sender];
        dropDown = nil;
    }

}
-(IBAction)selectPhoneCodeClicked:(id)sender
{
    if(dropDown == nil) {
        [txt_phoneNumber resignFirstResponder];
        [self.view addSubview:backGroundControl];
        [self.view bringSubviewToFront:backGroundControl];
        CGFloat f = 200;
        dropDown = [[NIDropDown alloc]showDropDown:sender :&f :countriesList :nil :@"up" :NO];
        dropDown.delegate = self;
        dropDown.isCountry = NO;
    }
    else {
        [backGroundControl removeFromSuperview];
        [dropDown hideDropDown:sender];
        dropDown = nil;
    }
}
- (void) selectedIndex: (int) index
{
    dropDown = nil;
    selectedIndex = index;
    NSDictionary *dict = [countriesList objectAtIndex:index];
    selectedCountryCode = [dict objectForKey:@"code"];
    if(verifyphonebgView.hidden)
    {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@(%@)",[dict objectForKey:@"name"],[dict objectForKey:@"code"]] attributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14],NSForegroundColorAttributeName:[UIColor colorWithRed:13/255.0 green:130/255.0 blue:232/255.0 alpha:1.0]}];
    [btn_selectCountry setAttributedTitle:attributedString forState:UIControlStateNormal];
    }
    else
    {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[dict objectForKey:@"dial_code"] attributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14],NSForegroundColorAttributeName:[UIColor colorWithRed:13/255.0 green:130/255.0 blue:232/255.0 alpha:1.0]}];
        [btn_selectPhoneCode setAttributedTitle:attributedString forState:UIControlStateNormal];

    }
    [backGroundControl removeFromSuperview];
}
-(void)closeClicked:(UITapGestureRecognizer*)sender
{
    if(dropDown == nil)
    {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CallClose" object:nil userInfo:nil];
    }
    else
    {
        [backGroundControl removeFromSuperview];
        if(verifyphonebgView.hidden)
        [dropDown hideDropDown:btn_selectCountry];
        else
            [dropDown hideDropDown:btn_selectPhoneCode];
        dropDown = nil;

    }
}
-(void)dontClose
{
    
}
-(void)evaluateUser
{
    [appDelegate showOrhideIndicator:YES];
    
    NSMutableDictionary *postDetails  = [NSMutableDictionary dictionary];
    [postDetails setObject:txt_username.text forKey:@"auth_key"];
    if(selectedCountryCode.length > 0)
    {
        [postDetails setObject:selectedCountryCode forKey:@"country"];
    }
    else
    {
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    if(countryCode != nil)
        [postDetails setObject:countryCode forKey:@"country"];
    }
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
    [txt_phoneNumber resignFirstResponder];
}

-(void)confirmPhoneNumber
{
    [appDelegate showOrhideIndicator:YES];
    NSMutableDictionary *postDetails  = [NSMutableDictionary dictionary];
        [postDetails setObject:txt_phoneNumber.text forKey:@"phno"];
        [postDetails setObject:selectedCountryCode forKey:@"country"];
    
    
    AccessToken* token = sharedModel.accessToken;
    
    NSString *command = @"confirmPhno";
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": @"confirmPhno",
                               @"body": postDetails};
    NSDictionary *userInfo = @{@"command": command};
    NSString *urlAsString = [NSString stringWithFormat:@"%@v2/users",BASE_URL];
    
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}
-(void)confirmPhoneNumberSccessfull:(NSDictionary *)responseDict
{
    NSMutableDictionary *userDict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userprofile"] mutableCopy];
    [userDict setObject:txt_phoneNumber.text  forKey:@"phno"];
    [[NSUserDefaults standardUserDefaults] setObject:userDict forKey:@"userprofile"];
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]
                                  initWithSuiteName:@"group.com.maisasolutions.msocl"];
    [myDefaults setObject:userDict forKey:@"userprofile"];
    [myDefaults synchronize];
    
    [sharedModel setUserDetails:userDict];
    
    [appDelegate showOrhideIndicator:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"nextClicked" object:nil userInfo:nil];
}
-(void)confirmPhoneNumberFailed:(NSDictionary *)responseDict
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
