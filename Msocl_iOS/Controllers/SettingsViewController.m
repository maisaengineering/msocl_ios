//
//  SettingsViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/22/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "SettingsViewController.h"
#import "ChangePasswordViewController.h"
#import "SlideNavigationController.h"
@implementation SettingsViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Settings";
    
    UIImage *background = [UIImage imageNamed:@"icon-back.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside]; //adding action
    [button setImage:background forState:UIControlStateNormal];
    button.frame = CGRectMake(0 ,0,13,17);
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;

    
}
-(void)backClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)changePassword:(id)sender
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ChangePasswordViewController"];
    
    [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];

}
@end

