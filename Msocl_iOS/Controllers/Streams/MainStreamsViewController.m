//
//  MainStreamsViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "MainStreamsViewController.h"
#import "ModelManager.h"
#import "LoginViewController.h"
@implementation MainStreamsViewController
{
    StreamDisplayView *streamDisplay;
    ModelManager *modelManager;
    
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    streamDisplay = [[StreamDisplayView alloc] initWithFrame:CGRectMake(0, 100, 320, Deviceheight-100)];
    streamDisplay.delegate = self;
    [self.view addSubview:streamDisplay];
   
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setHidesBackButton:YES animated:YES];

    [streamDisplay callStreamsApi:@""];
}

#pragma mark - 
#pragma mark Call backs from stream display
- (void)tableDidSelect:(int)index
{

}

-(IBAction)addClicked:(id)sender
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    [self performSegueWithIdentifier: @"AddPostsSegue" sender: self];
    else
    [self performSegueWithIdentifier: @"LoginSeague" sender: self];
}
@end
