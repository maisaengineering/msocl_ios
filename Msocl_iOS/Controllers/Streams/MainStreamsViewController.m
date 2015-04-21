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
#import "LoginViewController.h"
#import "SlideNavigationController.h"
@implementation MainStreamsViewController
{
    StreamDisplayView *mostRecent;
    StreamDisplayView *following;
    ModelManager *modelManager;
    NSString *selectedPostId;
    BOOL isShowPostCalled;
    
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
    
    pageGuidePopUpsObj = [[PageGuidePopUps alloc] init];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadOnLogOut)
                                                 name:RELOAD_ON_LOG_OUT
                                               object:nil];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    {
        [self check];
        
    }
    else
        [self.navigationItem setHidesBackButton:YES];


    [self refreshWall];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    //Invalidate the timer
    if([[pageGuidePopUpsObj  timer] isValid])
        [[pageGuidePopUpsObj timer] invalidate];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RELOAD_ON_LOG_OUT object:nil];
}
-(void)reloadOnLogOut
{
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem.title = @"";

    [mostRecent resetData];
    [mostRecent callStreamsApi:@""];
}
-(void)refreshWall
{
    if(!isShowPostCalled)
    {
    if(!mostRecent.hidden)
    {
        [mostRecent resetData];
        [mostRecent callStreamsApi:@"next"];
    }
    else
    {
        [following resetData];
        [following callStreamsApi:@"next"];

    }
    }
    isShowPostCalled = NO;
}
#pragma mark -
#pragma mark Call backs from stream display
- (void)tableDidSelect:(int)index
{
    if(!mostRecent.hidden)
    {
        isShowPostCalled = YES;
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
    {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *login = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.navigationController pushViewController:login animated:NO];
    }
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
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    return YES;
    else
        return NO;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}


-(void)check
{
    NSMutableArray *timedReminderData = [[NSUserDefaults standardUserDefaults] objectForKey:@"PageGuidePopUpImages"];
    
    for(int index = 0; index < [timedReminderData count]; index++)
    {
        NSMutableDictionary *eachPage = [timedReminderData objectAtIndex:index];
        NSString *context_name = [eachPage objectForKey:@"context"];
        if ([context_name isEqualToString:@"Homepage"])
        {
            if (![[pageGuidePopUpsObj timer] isValid])
            {
                pageGuidePopUpsObj.dicVisitedPage = eachPage;
                [pageGuidePopUpsObj setUpTimerWithStartIn];
                break;
                
            }
            
        }
    }
}

@end
