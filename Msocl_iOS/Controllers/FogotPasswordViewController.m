//
//  FogotPasswordViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/26/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "FogotPasswordViewController.h"
#import "ModelManager.h"
#import "StringConstants.h"
#import "AppDelegate.h"


@implementation FogotPasswordViewController
{
    AppDelegate *appdelegate;
    Webservices *webServices;
}
@synthesize emialField;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    appdelegate = [[UIApplication sharedApplication] delegate];
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    
    self.title = @"Forgot password";
    
    UIColor *color = [UIColor lightGrayColor];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:12.0];
    
    emialField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"Enter email"
                                    attributes:@{
                                                 NSForegroundColorAttributeName: color,
                                                 NSFontAttributeName : font
                                                 }
     ];

    UIImage *background = [UIImage imageNamed:@"icon-back.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside]; //adding action
    [button setImage:background forState:UIControlStateNormal];
    button.frame = CGRectMake(0 ,0,13,17);
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [rightButton addTarget:self action:@selector(resetClick:) forControlEvents:UIControlEventTouchUpInside]; //adding action
    [rightButton setBackgroundColor:[UIColor colorWithRed:76/255.0 green:121/255.0 blue:251/255.0 alpha:1.0]];
    [rightButton setTitle:@"Reset" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
    rightButton.frame = CGRectMake(0 ,0,50,30);
    rightButton.layer.cornerRadius = 5; // this value vary as per your desire
    rightButton.clipsToBounds = YES;
    
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    [super viewWillAppear:YES];
}
-(void)backClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)resetClick:(id)sender
{
    [emialField resignFirstResponder];
   if(emialField.text.length > 0)
   {
        [appdelegate showOrhideIndicator:YES];
        
        NSMutableDictionary *postDetails  = [NSMutableDictionary dictionary];
        [postDetails setObject:emialField.text forKey:@"email"];
       
        ModelManager *sharedModel = [ModelManager sharedModel];
        AccessToken* token = sharedModel.accessToken;
        
        NSDictionary* postData = @{@"access_token": token.access_token,
                                   @"command": @"forgot_password",
                                   @"body": postDetails};
        NSDictionary *userInfo = @{@"command": @"resetPassword"};
        NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
        
        [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
   }
    else
    {
        ShowAlert(PROJECT_NAME,@"Please enter email", @"OK");
        return;
    }
}
-(void) resetPasswordSuccessFull:(NSDictionary *)recievedDict
{
    ShowAlert(PROJECT_NAME,[recievedDict objectForKey:@"message"], @"OK");
    [appdelegate showOrhideIndicator:NO];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void) resetPasswordFailed
{
    [appdelegate showOrhideIndicator:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
@end
