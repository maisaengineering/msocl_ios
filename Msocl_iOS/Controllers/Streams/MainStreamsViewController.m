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
#import "PostDetails.h"
#import "MenuViewController.h"
#import "SlideNavigationController.h"
#import "UserProfileViewCotroller.h"
@implementation MainStreamsViewController
{
    StreamDisplayView *mostRecent;
    StreamDisplayView *following;
    ModelManager *modelManager;
    NSString *selectedPostId;
    BOOL isShowPostCalled;
    PostDetails *selectedPost;
    int selectedIndex;
    
}
@synthesize mostRecentButton;
@synthesize followingButton;
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    mostRecentButton.userInteractionEnabled = NO;
    
    mostRecent = [[StreamDisplayView alloc] initWithFrame:CGRectMake(0, 102, 320, Deviceheight-102)];
    mostRecent.delegate = self;
    [self.view addSubview:mostRecent];

    following = [[StreamDisplayView alloc] initWithFrame:CGRectMake(0, 102, 320, Deviceheight-102)];
    following.delegate = self;
    following.isFollowing = YES;
    [self.view addSubview:following];
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
        [mostRecent.streamTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        [mostRecent resetData];
        [mostRecent callStreamsApi:@"next"];
    }
    else
    {
        [following.streamTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        [following resetData];
        [following callStreamsApi:@"next"];

    }
    }
    else
    {
        if(!mostRecent.hidden)
        {
            [mostRecent.streamTableView reloadData];
        }
        else
            [following.streamTableView reloadData];

    }
    isShowPostCalled = NO;
}
#pragma mark -
#pragma mark Call backs from stream display
- (void)userProifleClicked:(int)index
{
    selectedIndex = index;
    [self performSegueWithIdentifier: @"UserProfile" sender: self];
}
- (void)recievedData:(BOOL)isFollowing
{
    
}
- (void)tableDidSelect:(int)index
{
    if(!mostRecent.hidden)
    {
        isShowPostCalled = YES;
        PostDetails *postObject = [mostRecent.storiesArray objectAtIndex:index];
        selectedPostId = postObject.uid;
        selectedPost = postObject;
        selectedIndex = index;
        [self performSegueWithIdentifier: @"PostSeague" sender: self];
    }
    else
    {
        isShowPostCalled = YES;
        PostDetails *postObject = [following.storiesArray objectAtIndex:index];
        selectedPostId = postObject.uid;
        selectedPost = postObject;
        selectedIndex = index;
        [self performSegueWithIdentifier: @"PostSeague" sender: self];
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PostSeague"])
    {
        PostDetailDescriptionViewController *destViewController = segue.destinationViewController;
        destViewController.postID = selectedPostId;
        destViewController.delegate = self;
        destViewController.postObjectFromWall = selectedPost;
    }
    else if ([segue.identifier isEqualToString:@"UserProfile"])
    {
        PostDetails *postObject;
        if(!mostRecent.hidden)
            postObject = [mostRecent.storiesArray objectAtIndex:selectedIndex];
        else
            postObject = [following.storiesArray objectAtIndex:selectedIndex];

        UserProfileViewCotroller *destViewController = segue.destinationViewController;
        destViewController.photo = postObject.profileImage;
        destViewController.name = [NSString stringWithFormat:@"%@ %@",[postObject.owner objectForKey:@"fname"],[postObject.owner objectForKey:@"lname"]];
        destViewController.profileId = [postObject.owner objectForKey:@"uid"];
    }
}
-(void) PostEditedFromPostDetails:(PostDetails *)postDetails
{
    if(!mostRecent.hidden)
    {
        [mostRecent.storiesArray replaceObjectAtIndex:selectedIndex withObject:postDetails];
    }
    else
        [following.storiesArray replaceObjectAtIndex:selectedIndex withObject:postDetails];
}
-(void)PostDeletedFromPostDetails
{
    if(!mostRecent.hidden)
    {
        [mostRecent.storiesArray removeObjectAtIndex:selectedIndex];
        [mostRecent.streamTableView reloadData];
    }
    else
    {
        [following.storiesArray removeObjectAtIndex:selectedIndex];
        [following.streamTableView reloadData];

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
        [mostRecent setHidden:NO];
        [following setHidden:YES];
        mostRecentButton.userInteractionEnabled = NO;
         followingButton.userInteractionEnabled = YES;
        mostRecentButton.backgroundColor = [UIColor clearColor];
        followingButton.backgroundColor = [UIColor colorWithRed:239/255.0 green:238/255.0 blue:239/255.0 alpha:1.0];

        [mostRecent.streamTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        [mostRecent resetData];
        [mostRecent callStreamsApi:@"next"];
        
    }
    else if([sender tag] == 2)
    {
        [mostRecent setHidden:YES];
        [following setHidden:NO];
        followingButton.userInteractionEnabled = NO;
        mostRecentButton.userInteractionEnabled = YES;
        followingButton.backgroundColor = [UIColor clearColor];
        mostRecentButton.backgroundColor = [UIColor colorWithRed:239/255.0 green:238/255.0 blue:239/255.0 alpha:1.0];
        
        [following.streamTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        [following resetData];
        [following callStreamsApi:@"next"];

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
