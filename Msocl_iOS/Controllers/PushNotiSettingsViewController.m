//
//  PushNotiSettingsViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 6/8/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "PushNotiSettingsViewController.h"
#import "ModelManager.h"
#import "StringConstants.h"
#import "AppDelegate.h"

@interface PushNotiSettingsViewController ()
{
    Webservices *webServices;
}

@end

@implementation PushNotiSettingsViewController
@synthesize slider;
@synthesize notifiResoonseDict;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"SETTINGS";
    
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;

    
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
    
    [slider setValue:[[notifiResoonseDict objectForKey:@"apnNotify"] floatValue] animated:YES];
    [slider setNeedsDisplay];

}
-(void)backClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)sliderValueChanged:(id)sender
{
    CGFloat value = [slider value];
    
    CGFloat roundValue = roundf(value);
    
    if (value != roundValue) {
        // Almost 100% of the time - Adjust:
        
        [slider setValue:roundValue];
        [self callApi];
    }

}


-(void)callApi
{
    NSMutableDictionary *postDetails  = [NSMutableDictionary dictionary];
    [postDetails setObject:[NSNumber numberWithInt:slider.value + 1] forKey:@"apnNotify"];
    
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    
    NSString *command = @"apnNotify";
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": @"update",
                               @"body": postDetails};
    NSDictionary *userInfo = @{@"command": command};
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];

}
-(void)pushNotificationSuccessFull:(NSDictionary *)recievedDict
{
    
}
-(void)pushNotificationFailed
{
    
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
