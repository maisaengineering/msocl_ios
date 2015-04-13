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
#import "PostDetailDescriptionViewController.h"
#import "PostDetails.h"
#import "SettingsMenuViewController.h"
@implementation MainStreamsViewController
{
    StreamDisplayView *streamDisplay;
    ModelManager *modelManager;
    NSString *selectedPostId;
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadOnLogOut)
                                                 name:RELOAD_ON_LOG_OUT
                                               object:nil];
    
    [streamDisplay resetData];
    [streamDisplay callStreamsApi:@""];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RELOAD_ON_LOG_OUT object:nil];
}
-(void)reloadOnLogOut
{
    [streamDisplay resetData];
    [streamDisplay callStreamsApi:@""];
}
#pragma mark -
#pragma mark Call backs from stream display
- (void)tableDidSelect:(int)index
{
    if(!streamDisplay.hidden)
    {
        PostDetails *postObject = [streamDisplay.storiesArray objectAtIndex:index];
        selectedPostId = postObject.uid;
        [self performSegueWithIdentifier: @"PostSeague" sender: self];
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PostSeague"])
    {
        PostDetailDescriptionViewController *destViewController = segue.destinationViewController;
        destViewController.postID = selectedPostId;
    }
}


-(IBAction)addClicked:(id)sender
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
        [self performSegueWithIdentifier: @"AddPostsSegue" sender: self];
    else
        [self performSegueWithIdentifier: @"LoginSeague" sender: self];
}

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}

@end
