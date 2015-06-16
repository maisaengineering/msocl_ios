//
//  ShareSettingsViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 6/16/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "ShareSettingsViewController.h"

@interface ShareSettingsViewController ()

@end

@implementation ShareSettingsViewController
@synthesize slider;
@synthesize fbSwitchCntrl;
- (void)viewDidLoad {
    
    slider.continuous = NO;
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"share"];
    if(dict != nil)
    {
        slider.value = [[dict objectForKey:@"sliderValue"] intValue];
        fbSwitchCntrl.on = [[dict objectForKey:@"fb"] boolValue];
    }
    UIImage *background = [UIImage imageNamed:@"icon-back.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside]; //adding action
    [button setImage:background forState:UIControlStateNormal];
    button.frame = CGRectMake(0 ,0,13,17);
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;

    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    }
    
    NSMutableDictionary *dict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"share"] mutableCopy];
    if(dict != nil)
    {
        [dict setObject:[NSNumber numberWithInt:slider.value] forKey:@"sliderValue"];
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"share"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@{ @"sliderValue":[NSNumber numberWithInt:slider.value]} forKey:@"share"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)switchChanged:(id)sender
{

    if([sender tag] == 1)
    {
        if(fbSwitchCntrl.isOn)
        {
            NSArray *permissions = [NSArray arrayWithObjects:@"publish_actions", nil];
            
            [FBSession openActiveSessionWithPublishPermissions:permissions defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:YES
                                             completionHandler:
             ^(FBSession *session, FBSessionState state, NSError *error) {
             }];
        }
        
        NSMutableDictionary *dict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"share"] mutableCopy];
        if(dict != nil)
        {
            [dict setObject:[NSNumber numberWithBool:fbSwitchCntrl.isOn] forKey:@"fb"];
            [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"share"];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:@{@"fb":[NSNumber numberWithBool:fbSwitchCntrl.isOn], @"sliderValue":[NSNumber numberWithInt:slider.value]} forKey:@"share"];
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
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
