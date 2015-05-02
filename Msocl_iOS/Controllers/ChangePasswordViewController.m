//
//  ChangePasswordViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/22/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "ModelManager.h"
#import "StringConstants.h"
#import "AppDelegate.h"
@implementation ChangePasswordViewController
{
    Webservices *webservice;
    AppDelegate *appdelegate;
    ModelManager *sharedModel;
}
@synthesize txt_confirmPassword;
@synthesize txt_oldPassword;
@synthesize txt_Password;
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Reset Password";
    
    webservice = [[Webservices alloc] init];
    webservice.delegate = self;
    
    appdelegate = [[UIApplication sharedApplication] delegate];
    sharedModel = [ModelManager sharedModel];
    
    UIImage *background = [UIImage imageNamed:@"icon-back.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside]; //adding action
    [button setImage:background forState:UIControlStateNormal];
    button.frame = CGRectMake(0 ,0,13,17);
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;

    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [rightButton addTarget:self action:@selector(resetClicked) forControlEvents:UIControlEventTouchUpInside]; //adding action
    [rightButton setBackgroundColor:[UIColor colorWithRed:76/255.0 green:121/255.0 blue:251/255.0 alpha:1.0]];
    [rightButton setTitle:@"Reset" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont fontWithName:@"Ubuntu-Light" size:15]];
    rightButton.frame = CGRectMake(0 ,0,50,30);
    rightButton.layer.cornerRadius = 5; // this value vary as per your desire
    rightButton.clipsToBounds = YES;

    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;

    UIColor *color = [UIColor lightGrayColor];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:12.0];
    
    txt_oldPassword.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"Current password"
                                    attributes:@{
                                                 NSForegroundColorAttributeName: color,
                                                 NSFontAttributeName : font
                                                 }
     ];

    txt_Password.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"New password"
                                    attributes:@{
                                                 NSForegroundColorAttributeName: color,
                                                 NSFontAttributeName : font
                                                 }
     ];

    txt_confirmPassword.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"Confirm new password"
                                    attributes:@{
                                                 NSForegroundColorAttributeName: color,
                                                 NSFontAttributeName : font
                                                 }
     ];

    

}
-(void)resetClicked
{
    [self resignKeyBoards];
    if( txt_oldPassword.text.length == 0 || txt_confirmPassword.text.length == 0 || txt_Password.text.length == 0)
    {
        ShowAlert(PROJECT_NAME,@"All fields are required", @"OK");
        return;
    }
    else if(![txt_confirmPassword.text isEqualToString:txt_Password.text])
    {
        ShowAlert(PROJECT_NAME,@"Password and Confirm Password are not matching", @"OK");
        return;
    }
    else
    {
        [appdelegate showOrhideIndicator:YES];
        NSMutableDictionary *postDetails  = [NSMutableDictionary dictionary];
        [postDetails setObject:txt_Password.text forKey:@"password"];
        [postDetails setObject:txt_confirmPassword.text forKey:@"password_confirmation"];
        [postDetails setObject:txt_oldPassword.text forKey:@"current_password"];
        
        AccessToken* token = sharedModel.accessToken;
        
        NSDictionary* postData = @{@"access_token": token.access_token,
                                   @"command": @"change_password",
                                   @"body": postDetails};
        NSDictionary *userInfo = @{@"command": @"changePassword"};
        NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
        
        [webservice callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
    }

    

}
-(void)changePasswordSuccessFull:(NSDictionary *)recievedDict
{
        [appdelegate showOrhideIndicator:NO];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)changePasswordFailed
{
        [appdelegate showOrhideIndicator:NO];
}
-(void)backClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -
#pragma mark Textfield Delegate methods
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
