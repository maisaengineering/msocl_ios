//
//  LoginSecondViewController.m
//  Msocl_iOS
//
//  Created by Maisa Pride on 9/1/16.
//  Copyright © 2016 Maisa Solutions. All rights reserved.
//

#import "LoginSecondViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "StringConstants.h"
#import "ModelManager.h"
#import "AppDelegate.h"
#import "PromptImages.h"
#import "NotificationUtils.h"
#import "FogotPasswordViewController.h"
#import "Flurry.h"
#import "PageGuidePopUps.h"
#import "SlideNavigationController.h"
#import "AddPostViewController.h"



@interface LoginSecondViewController ()
{
    ModelManager *sharedModel;
    Webservices *webServices;
    AppDelegate *appDelegate;
    
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    NSString *latitude, *longitude, *state, *country;
}
@end

@implementation LoginSecondViewController
@synthesize  txt_password;
@synthesize txt_username;
@synthesize loginBtn;
@synthesize userName;
@synthesize backgroundView;
@synthesize topLabel;
@synthesize backBtn;
@synthesize resetPasswordBtn;
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
    
  /*  geocoder = [[CLGeocoder alloc] init];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate=self;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    [locationManager requestWhenInUseAuthorization];
    [locationManager startMonitoringSignificantLocationChanges];
    [locationManager startUpdatingLocation];
    */
    txt_username.text = userName;
    [self.navigationController setNavigationBarHidden:YES];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(closeClicked)];
    
    [self.view addGestureRecognizer:tap];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]
                                    initWithTarget:self
                                    action:@selector(dontClose)];
    
    [backgroundView addGestureRecognizer:tap1];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowBackButton" object:nil userInfo:nil];
    
}
-(void)closeClicked
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CallClose" object:nil userInfo:nil];
}
-(void)dontClose
{
    
}
-(IBAction)returnClicked:(id)sender
{
    [txt_password resignFirstResponder];
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error == nil&& [placemarks count] >0) {
            placemark = [placemarks lastObject];
            
            
            latitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
            longitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
            state = placemark.administrativeArea;
            country = placemark.country;
            
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    }];
    
    // Turn off the location manager to save power.
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Cannot find the location.");
}

-(IBAction)loginClicked:(id)sender
{
    if ([txt_password.text length] == 0)
    {
        ShowAlert(PROJECT_NAME,@"Please enter password", @"OK");
        return;
    }
    [self doLogin];

}
-(void)doLogin
{
    [txt_password resignFirstResponder];
    [appDelegate showOrhideIndicator:YES];
    
    NSMutableDictionary *postDetails  = [NSMutableDictionary dictionary];
    [postDetails setObject:userName forKey:@"auth_key"];
    [postDetails setObject:txt_password.text forKey:@"password"];

    AccessToken* token = sharedModel.accessToken;
    
    NSDictionary* postData;
    NSDictionary *userInfo;
    if(_isSignUp)
    {
        postData = @{@"access_token": token.access_token,
                     @"command": @"create",
                     @"body": postDetails};
        userInfo = @{@"command": @"create"};
        NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
        NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
        if(countryCode != nil)
        [postDetails setObject:countryCode forKey:@"country"];
        if(latitude)
            [postDetails setObject:latitude forKey:@"latitude"];
        if(longitude)
            [postDetails setObject:countryCode forKey:@"longitude"];
    }
    else
    {
    
        postData = @{@"access_token": token.access_token,
                               @"command": @"signIn",
                               @"body": postDetails};
        userInfo = @{@"command": @"signIn"};
    }
    
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@v2/users",BASE_URL];
    
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];

}
-(void) loginSccessfull:(NSDictionary *)recievedDict
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
    
    [appDelegate showOrhideIndicator:NO];

    
    if(![sharedModel.userProfile.verified boolValue] && sharedModel.userProfile.phno)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PushToVerifyPhoneNumber" object:nil userInfo:nil];
    }
    else if (self.addPostFromNotifications)
    {
       [[NSNotificationCenter defaultCenter] postNotificationName:@"PushToAddPost" object:nil userInfo:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CallClose" object:nil userInfo:nil];
        
    }
    
    
}
-(void) loginFailed:(NSDictionary *)recievedDict
{
    [appDelegate showOrhideIndicator:NO];
    
    if([recievedDict objectForKey:@"message"])
    {
        ShowAlert(@"Error", [recievedDict objectForKey:@"message"], @"OK");
    }
    else
    {
        ShowAlert(@"Error",@"Failed to sign in. Please try again", @"OK");
    }

}

-(void) signUpFailed:(NSDictionary *)recievedDict
{
    [appDelegate showOrhideIndicator:NO];
    
    if([recievedDict objectForKey:@"message"])
    {
        ShowAlert(@"Error", [recievedDict objectForKey:@"message"], @"OK");
    }
    else
    {
        ShowAlert(@"Error",@"Failed to sign up. Please try again", @"OK");
    }

}

-(IBAction)resetPasswordClicked:(id)sender
{
    [appDelegate showOrhideIndicator:YES];
    
    NSMutableDictionary *postDetails  = [NSMutableDictionary dictionary];
    [postDetails setObject:txt_username.text forKey:@"email"];
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    if(countryCode != nil)
        [postDetails setObject:countryCode forKey:@"country"];

    
    AccessToken* token = sharedModel.accessToken;
    
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": @"forgot_password",
                               @"body": postDetails};
    NSDictionary *userInfo = @{@"command": @"forgot_password"};
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];

}
-(void) resetPasswordSuccessFull:(NSDictionary *)recievedDict
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
-(void) resetPasswordFailed:(NSDictionary *)recievedDict
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
