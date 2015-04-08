//
//  MainStreamsViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "MainStreamsViewController.h"

@implementation MainStreamsViewController
{
    StreamDisplayView *streamDisplay;
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    streamDisplay = [[StreamDisplayView alloc] initWithFrame:CGRectMake(0, 100, 320, Deviceheight-130)];
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

-(IBAction)addClicked:(id)sender
{
    [self performSegueWithIdentifier: @"AddPostsSegue" sender: self];
}
@end
