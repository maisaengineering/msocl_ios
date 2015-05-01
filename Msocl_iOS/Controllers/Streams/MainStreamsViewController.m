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
#import "TagViewController.h"
#import "UpdateUserDetailsViewController.h"
@implementation MainStreamsViewController
{
    StreamDisplayView *mostRecent;
    StreamDisplayView *following;
    ModelManager *modelManager;
    NSString *selectedPostId;
    BOOL isShowPostCalled;
    PostDetails *selectedPost;
    int selectedIndex;
    NSString *selectedTag;
}
@synthesize mostRecentButton;
@synthesize timerHomepage;
@synthesize subContext;
@synthesize homeContext;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    modelManager =[ModelManager sharedModel];
    [mostRecentButton setImage:[UIImage imageNamed:@"icon-favorite.png"] forState:UIControlStateSelected];
    
    UILabel *line = [[UILabel alloc] initWithFrame: CGRectMake(0, 94.5, 320, 0.5)];
    line.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    [line setTextAlignment:NSTextAlignmentLeft];
    line.backgroundColor = [UIColor colorWithRed:(225/255.f) green:(225/255.f) blue:(225/255.f) alpha:1];
    [self.view addSubview:line];

    
    mostRecent = [[StreamDisplayView alloc] initWithFrame:CGRectMake(0, 65, 320, Deviceheight-65)];
    mostRecent.delegate = self;
    [self.view addSubview:mostRecent];

    following = [[StreamDisplayView alloc] initWithFrame:CGRectMake(0, 65, 320, Deviceheight-65)];
    following.delegate = self;
    following.isFollowing = YES;
    [self.view addSubview:following];
    following.hidden = YES;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, 320, 30)];
    [imageView setImage:[UIImage imageNamed:@"semi-transparent.png"]];
    [self.view addSubview:imageView];
    [self.view bringSubviewToFront:mostRecentButton];
    
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
    
   
        [self check];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] init]];
    else
    [self.navigationItem setHidesBackButton:YES];


    [self refreshWall];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    //Invalidate the timer
    if([[self  timerHomepage] isValid])
        [[self  timerHomepage] invalidate];
    
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
    PostDetails *postObject;
    if(!mostRecent.hidden)
        postObject = [mostRecent.storiesArray objectAtIndex:selectedIndex];
    else
        postObject = [following.storiesArray objectAtIndex:selectedIndex];
    if([[postObject.owner objectForKey:@"uid"] isEqualToString:modelManager.userProfile.uid])
    {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UpdateUserDetailsViewController *login = [mainStoryboard instantiateViewControllerWithIdentifier:@"UpdateUserDetailsViewController"];
        [[SlideNavigationController sharedInstance] pushViewController:login animated:NO];

    }
    else
        [self performSegueWithIdentifier: @"UserProfile" sender: self];
}
- (void)recievedData:(BOOL)isFollowing
{
    
}
- (void)tagCicked:(NSString *)tagName
{
    selectedTag = tagName;
    
    [self performSegueWithIdentifier: @"TagView" sender: self];
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
    else if ([segue.identifier isEqualToString:@"TagView"])
    {
        
        TagViewController *destViewController = segue.destinationViewController;
        destViewController.tagName = selectedTag;
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
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    {
    
    if(mostRecentButton.selected)
    {
        
        [mostRecent setHidden:NO];
        [following setHidden:YES];

        [mostRecent.streamTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        [mostRecent resetData];
        [mostRecent callStreamsApi:@"next"];
        
    }
    else
    {
        [mostRecent setHidden:YES];
        [following setHidden:NO];
        
        [following.streamTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        [following resetData];
        [following callStreamsApi:@"next"];

    }
    mostRecentButton.selected = !mostRecentButton.selected;
    }
    else
    {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *login = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.navigationController pushViewController:login animated:NO];

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
            homeContext = [[NSMutableDictionary alloc]init];
            homeContext = [timedReminderData objectAtIndex:index];
            
            NSMutableArray *graphicsArray = [eachPage objectForKey:@"graphics"];
            
            if (graphicsArray != (id)[NSNull null] && [graphicsArray count] > 0)
            {
                for (int j = 0; j < graphicsArray.count; j++)
                {
                    NSMutableDictionary *dic = [graphicsArray objectAtIndex:j];
                    
                    if ([[dic objectForKey:@"isViewed"] boolValue] == NO)
                    {
                        if (![[self timerHomepage] isValid])
                        {
                            subContext = [[NSMutableDictionary alloc]init];
                            subContext = dic;
                            [self setUpTimerWithStartInSubContext:dic];
                            break;
                        }
                    }
                    
                }
            }
        }
    }
}
-(void)setUpTimerWithStartInSubContext:(NSMutableDictionary *)subContext1
{
    NSTimeInterval timeInterval = [[subContext1 valueForKey:@"start"] doubleValue];
    
    if (!timerHomepage) {
        
        timerHomepage = [NSTimer scheduledTimerWithTimeInterval: timeInterval
                                                         target: self
                                                       selector: @selector(displayPromptForNewKidWhenStreamDataEmpty)
                                                       userInfo: nil
                                                        repeats: NO];
    }
    else
    {
        
        [timerHomepage invalidate];
        timerHomepage = nil;
        timerHomepage = [NSTimer scheduledTimerWithTimeInterval: timeInterval
                                                         target: self
                                                       selector: @selector(displayPromptForNewKidWhenStreamDataEmpty)
                                                       userInfo: nil
                                                        repeats: NO];
    }
}
/// Display the pop up
-(void)displayPromptForNewKidWhenStreamDataEmpty
{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    addPopUpView = [[UIView alloc] initWithFrame:CGRectMake(0,0,screenWidth,screenHeight)];
    [addPopUpView setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *myWhiteBack = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,screenWidth,screenHeight)];
    [myWhiteBack setBackgroundColor:[UIColor blackColor]];
    [addPopUpView addSubview:myWhiteBack];
    
    //MARK:POP Up image
    UIImageView *popUpContent = [[UIImageView alloc] init];
    [popUpContent setFrame:CGRectMake(19, screenHeight, 283, 377)];
    
    NSString *imageURL = [subContext objectForKey:@"asset"];
    UIImage *thumb;
    if (imageURL.length >0)
    {
        photoUtils = [ProfilePhotoUtils alloc];
        thumb = [photoUtils getImageFromCache:imageURL];
        
        if (thumb == nil)
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^(void)
                           {
                               NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
                               UIImage* image = [[UIImage alloc] initWithData:imageData];
                               if (image) {
                                   [photoUtils saveImageToCache:imageURL :image];
                                   
                               }
                           });
        }
        else
        {
            [popUpContent setImage:thumb];
        }
    }
    else
    {
        //[popUpContent setImage:[UIImage imageNamed:@"New_Child_Stream_Empty.png"]];
    }
    [popUpContent setImage:thumb];
    popUpContent.frame = CGRectMake(50, 50,
                                    thumb.size.width, thumb.size.height);
    
    [addPopUpView addSubview:popUpContent];
    
    // MARK:Got it button
    UIButton *gotItButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [gotItButton setTitle:@"Got it" forState:UIControlStateNormal];
    [gotItButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    if (Deviceheight <568)
    {
        gotItButton.frame = CGRectMake(180,417,100,50);
    }
    else
    {
        gotItButton.frame = CGRectMake(120,440,80,30);
    }
    [gotItButton setBackgroundColor:[UIColor redColor]];
    
    gotItButton.tag = 1;
    [addPopUpView addSubview:gotItButton];
    
    if (thumb)
    {
        [[[[UIApplication sharedApplication] delegate] window] addSubview:addPopUpView];
    }
    
    myWhiteBack.alpha = 0.0f;
    [UIView animateWithDuration:1.0f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         myWhiteBack.alpha = 0.65f;
                         if (Deviceheight <568)
                         {
                             gotItButton.frame = CGRectMake(180,417,100,50);
                             [popUpContent setFrame:CGRectMake(50, 50,
                                                               thumb.size.width, thumb.size.height)];
                         }
                         else
                         {
                             gotItButton.frame = CGRectMake(120,440,80,30);
                             [popUpContent setFrame:CGRectMake(100, Deviceheight-325,
                                                               thumb.size.width, thumb.size.height)];
                         }
                         
                     }
                     completion:nil];
    
}
- (void)buttonClicked:(UIButton *)sender
{
    //
    [addPopUpView removeFromSuperview];
    
    
    NSMutableArray *userDefaultsArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"PageGuidePopUpImages"];
    
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < [userDefaultsArray count]; i++)
    {
        NSMutableDictionary *userDefaultsDic = [[NSMutableDictionary alloc]init];
        userDefaultsDic = [userDefaultsArray objectAtIndex:i];
        
        NSMutableDictionary *newDic = [[NSMutableDictionary alloc]init];
        
        if ([[userDefaultsDic objectForKey:@"context"] isEqualToString:@"Homepage"])
        {
            [newDic setObject:[userDefaultsDic objectForKey:@"context"] forKey:@"context"];
            [newDic setObject:[userDefaultsDic objectForKey:@"uid"] forKey:@"uid"];
            
            NSMutableArray *userDefaultGraphicsArray = [userDefaultsDic objectForKey:@"graphics"];
            NSMutableArray *newGraphicsArray = [[NSMutableArray alloc]init];
            
            for(int i=0;i<[userDefaultGraphicsArray count];i++)
            {
                NSMutableDictionary *userDefaultsSubContext = [userDefaultGraphicsArray objectAtIndex:i];
                
                if ([[userDefaultsSubContext objectForKey:@"uid"] isEqualToString:[subContext objectForKey:@"uid"]])
                {
                    NSMutableDictionary *updatedDic = [[NSMutableDictionary alloc]init];
                    [updatedDic setObject:[NSNumber numberWithBool:YES] forKey:@"isViewed"];
                    [updatedDic setObject:[subContext objectForKey:@"asset"] forKey:@"asset"];
                    [updatedDic setObject:[subContext objectForKey:@"start"] forKey:@"start"];
                    [updatedDic setObject:[subContext objectForKey:@"uid"] forKey:@"uid"];
                    
                    [newGraphicsArray addObject:updatedDic];
                }
                else
                {
                    [newGraphicsArray addObject:userDefaultsSubContext];
                }
            }
            
            
            [newDic setObject:newGraphicsArray forKey:@"graphics"];
            [newArray addObject:newDic];
        }
        else
        {
            [newArray addObject:userDefaultsDic];
        }
    }
    DebugLog(@"%@",newArray);
    [[NSUserDefaults standardUserDefaults] setObject:newArray forKey:@"PageGuidePopUpImages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    ////////////////////////////////////////
    
    
    NSMutableArray *userDefaultsArray1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"PageGuidePopUpImages"];
    
    for (int j = 0; j < [userDefaultsArray1 count]; j++)
    {
        NSMutableDictionary *userDefaultsDic1 = [[NSMutableDictionary alloc]init];
        userDefaultsDic1 = [userDefaultsArray1 objectAtIndex:j];
        
        NSMutableDictionary *newDic1 = [[NSMutableDictionary alloc]init];
        
        if ([[userDefaultsDic1 objectForKey:@"context"] isEqualToString:@"Homepage"])
        {
            [newDic1 setObject:[userDefaultsDic1 objectForKey:@"context"] forKey:@"context"];
            [newDic1 setObject:[userDefaultsDic1 objectForKey:@"uid"] forKey:@"uid"];
            
            NSMutableArray *userDefaultGraphicsArray1 = [userDefaultsDic1 objectForKey:@"graphics"];
            
            for(int i=0;i<[userDefaultGraphicsArray1 count];i++)
            {
                NSMutableDictionary *userDefaultsSubContext1 = [userDefaultGraphicsArray1 objectAtIndex:i];
                
                if ([[userDefaultsSubContext1 objectForKey:@"isViewed"] boolValue] == NO)
                {
                    if (![[self timerHomepage] isValid])
                    {
                        subContext = [[NSMutableDictionary alloc]init];
                        subContext = userDefaultsSubContext1;
                        [self setUpTimerWithStartInSubContext:userDefaultsSubContext1];
                        break;
                    }
                }
            }
        }
        else
        {
            
        }
    }
}
@end
