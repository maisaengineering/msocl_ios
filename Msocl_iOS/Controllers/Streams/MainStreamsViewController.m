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
    StreamDisplayView *mostRecent;
    StreamDisplayView *following;
    ModelManager *modelManager;
    NSString *selectedPostId;
    
}
@synthesize mostRecentButton;
@synthesize followingButton;
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    mostRecent = [[StreamDisplayView alloc] initWithFrame:CGRectMake(0, 102, 320, Deviceheight-102)];
    mostRecent.delegate = self;
    [self.view addSubview:mostRecent];

    following = [[StreamDisplayView alloc] initWithFrame:CGRectMake(0, 102, 320, Deviceheight-102)];
    following.delegate = self;
    [self.view addSubview:mostRecent];
    following.hidden = YES;
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadOnLogOut)
                                                 name:RELOAD_ON_LOG_OUT
                                               object:nil];
    
    [mostRecent resetData];
    [mostRecent callStreamsApi:@""];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RELOAD_ON_LOG_OUT object:nil];
}
-(void)reloadOnLogOut
{
    [mostRecent resetData];
    [mostRecent callStreamsApi:@""];
}
#pragma mark -
#pragma mark Call backs from stream display
- (void)tableDidSelect:(int)index
{
    if(!mostRecent.hidden)
    {
        PostDetails *postObject = [mostRecent.storiesArray objectAtIndex:index];
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

-(IBAction)RecentOrFollowignClicked:(id)sender
{
    if([sender tag] == 1)
    {
        
    }
    else if([sender tag] == 2)
    {
        
    }
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
