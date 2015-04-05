//
//  MainStreamsViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "MainStreamsViewController.h"

@implementation MainStreamsViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
}
-(IBAction)addClicked:(id)sender
{
    [self performSegueWithIdentifier: @"AddPostsSegue" sender: self];
}
@end
