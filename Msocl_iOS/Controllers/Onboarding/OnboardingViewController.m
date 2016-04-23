//
//  OnboardingViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "OnboardingViewController.h"
#import "StringConstants.h"
#import "ModelManager.h"
#import "AppDelegate.h"
#import "ProfilePhotoUtils.h"
#import "UIImageView+AFNetworking.h"


@interface OnboardingViewController ()
{
    int imageID;
    ModelManager *sharedModel;
    ProfilePhotoUtils *photoUtils;
    MBProgressHUD *HUD;
    int downloadingImagesCount;
    int downloadedImagesCount;
    NSTimer *timer;
    AppDelegate *appDelegate;
    
    UIButton *hyperLinkButton;
}
@end

@implementation OnboardingViewController
@synthesize scrollView;
@synthesize imageArray;
@synthesize continueButton;
@synthesize addKidButton;
@synthesize inviteFriendsButton;
@synthesize justExploreButton;
@synthesize isFromMoreTab;
@synthesize backButton;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    photoUtils = [ProfilePhotoUtils alloc];
    imageID = 0;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    sharedModel = [ModelManager sharedModel];
    
   /*
    [[NSNotificationCenter defaultCenter]
 
     addObserver:self
     selector:@selector(downloadImages)
     name:@"TourImages_API"
     object:nil ];
    
    imageArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"PromptImages"];
    
    
    if([imageArray count] >= 1)
    {
        
        [self downloadImages];
    }
    else
    {
        [self loadLocalImages];
        [self addScrollviewWithLocalImages];
    }
    
    
    
    */
    
    
    UIImageView *tour_ImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:tour_ImageView];
    
    
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
    [left setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:left];
    
    hyperLinkButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    [hyperLinkButton addTarget:self action:@selector(linkClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hyperLinkButton];
    
    
    
    UIButton * iAmInBtn = [UIButton  buttonWithType:UIButtonTypeCustom];
    [iAmInBtn addTarget:self action:@selector(iAmInBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:iAmInBtn];
    
    
    
    if(Deviceheight == 480)
    {
        hyperLinkButton.frame = CGRectMake(0, 324, 320, 40);
        tour_ImageView.image = [UIImage imageNamed:@"tour0-4.png"];
        
        iAmInBtn.frame = CGRectMake(115, 370, 80, 40);
        
        UIImageView *logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(40, 21, 240, 56)];
        [logoImage setImage:[UIImage imageNamed:@"icon-login.png"]];
        [tour_ImageView addSubview:logoImage];

    }
    else
    {
        tour_ImageView.image = [UIImage imageNamed:@"tour_0.png"];
        hyperLinkButton.frame = CGRectMake(0, 380, 320, 40);
        iAmInBtn.frame = CGRectMake(115, 429, 80, 40);
        
        UIImageView *logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(40, 54, 240, 56)];
        [logoImage setImage:[UIImage imageNamed:@"icon-login.png"]];
        [tour_ImageView addSubview:logoImage];


    }
    
    [self.navigationController setNavigationBarHidden:YES];
    

}
- (void)iAmInBtnClicked
{
    [self askForNotificationPermission];
    [self goToMainStreams];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)downloadImages
{
    downloadedImagesCount = 0;
    downloadingImagesCount = 0;
    for ( int i=0; i<[imageArray count]; i++)
    {
        NSString *urlstriing = [imageArray objectAtIndex:i];
        
        UIImage *thumb = [photoUtils getImageFromCache:urlstriing];
        
        if (thumb == nil)
        {
            downloadingImagesCount ++;
            
        }
        else
        {
            downloadedImagesCount++;
        }
    }
    if(downloadedImagesCount == imageArray.count)
    {
        [[NSUserDefaults standardUserDefaults] setObject:imageArray forKey:@"lastTour"];
        [self addScrollView];
    }
    else if([[NSUserDefaults standardUserDefaults] objectForKey:@"lastTour"])
    {
        imageArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastTour"];
        [self addScrollView];
        
    }
    else if(!isFromMoreTab)
    {
        ///load local images when api images are not downloaded
        [self loadLocalImages];
        [self addScrollviewWithLocalImages];
    }
    
}
-(void)loadLocalImages
{
    
    if(Deviceheight == 480)
    {
        imageArray = @[[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"continue", nil],@"actions",@"tour0-4.png",@"name",nil]];

    }
    else
        imageArray = @[[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"continue", nil],@"actions",@"tour_0.png",@"name",nil]];

}
-(void)addScrollviewWithLocalImages
{
    for (int i = 0; i < [imageArray count]; i++)
    {
        //We'll create an imageView object in every 'page' of our scrollView.
        CGRect frame;
        frame.origin.x = self.scrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.scrollView.frame.size;
        
        UIImageView *tour_ImageView = [[UIImageView alloc] initWithFrame:frame];
        tour_ImageView.image = [UIImage imageNamed:[[imageArray objectAtIndex:i] objectForKey:@"name"]];
        [self.scrollView addSubview:tour_ImageView];
    }

    
    //Set the content size of our scrollview according to the total width of our imageView objects.
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * [imageArray count], 300);
    
    // Continue
    continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    continueButton.frame = CGRectMake(190, Deviceheight-53, 110, 40);
    continueButton.tag = 1;
    [continueButton addTarget:self action:@selector(continueButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueButton];
    
    // Back
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(20, Deviceheight-53, 110, 40);
    backButton.tag = 2;
    [backButton addTarget:self action:@selector(continueButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    // Add Kid + Spouse
    addKidButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addKidButton addTarget:self action:@selector(addKidButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [addKidButton setTag:234];
    [self.view addSubview:addKidButton];
    
    // Invite  Friends
    inviteFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteFriendsButton addTarget:self action:@selector(addKidButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [inviteFriendsButton setTag:235];
    [self.view addSubview:inviteFriendsButton];
    
    // Just Explore
    justExploreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [justExploreButton addTarget:self action:@selector(addKidButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [justExploreButton setTag:236];
    [self.view addSubview:justExploreButton];
    
    if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] containsObject:@"back"])
        [self.view addSubview:backButton];
    else
        [backButton removeFromSuperview];
    
    if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] count] > 0 && ![[[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] firstObject] isEqualToString:@"continue"])
    {
        [continueButton removeFromSuperview];
        
        [addKidButton setFrame:CGRectMake(105, Deviceheight-215, 175, 46)];
        [inviteFriendsButton setFrame:CGRectMake(105, Deviceheight-145, 140, 46)];
        if (Deviceheight<568)
            [justExploreButton setFrame:CGRectMake(105, Deviceheight-82, 120, 46)];
        else
            [justExploreButton setFrame:CGRectMake(105, 485, 120, 46)];
        
        if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] containsObject:@"add_kid"])
            [self.view addSubview:addKidButton];
        if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] containsObject:@"invite_friends"])
            [self.view addSubview:inviteFriendsButton];
        if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] containsObject:@"just_explore"])
            [self.view addSubview:justExploreButton];
    }
    else
    {
        [self.view addSubview:continueButton];
        
        [addKidButton removeFromSuperview];
        [inviteFriendsButton removeFromSuperview];
        [justExploreButton removeFromSuperview];
    }
    
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
    [left setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.scrollView addGestureRecognizer:left];
    
    hyperLinkButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    [hyperLinkButton addTarget:self action:@selector(linkClicked) forControlEvents:UIControlEventTouchUpInside];
    hyperLinkButton.frame = CGRectMake(0, 380, 320, 100);
    [scrollView addSubview:hyperLinkButton];
    
}
-(void)leftSwipe:(UISwipeGestureRecognizer *)gesture
{
    [timer invalidate];
    [self askForNotificationPermission];
    [self goToMainStreams];

}
-(void)addScrollView
{
    downloadedImagesCount = 0;
    downloadingImagesCount = 0;
    
    
    for (int i = 0; i < [imageArray count]; i++)
    {
        //We'll create an imageView object in every 'page' of our scrollView.
        CGRect frame;
        frame.origin.x = self.scrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.scrollView.frame.size;
        
        UIImageView *tour_ImageView = [[UIImageView alloc] initWithFrame:frame];
        
        NSString *url =[imageArray objectAtIndex:i];
        
        UIImage *thumb = [photoUtils getImageFromCache:url];
        
        if (thumb == nil)
        {
            downloadingImagesCount ++;
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^(void)
                           {
                               NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                               
                               UIImage* image = [[UIImage alloc] initWithData:imageData];
                               if (image) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       
                                       downloadingImagesCount--;
                                       tour_ImageView.image = image;
                                       //save it to cache
                                       [photoUtils saveImageToCache:url :tour_ImageView.image];                                              [tour_ImageView setNeedsLayout];
                                      
                                   });
                               }
                           });
        }
        else
        {
            downloadedImagesCount++;
            tour_ImageView.image = thumb;
        }
        
        [self.scrollView addSubview:tour_ImageView];
    }
    

    //Set the content size of our scrollview according to the total width of our imageView objects.
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * [imageArray count], 300);
    
    // Continue
    continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    continueButton.frame = CGRectMake(190, Deviceheight-53, 110, 40);
    continueButton.tag = 1;
    [continueButton addTarget:self action:@selector(continueButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueButton];
    
    // Back
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(20, Deviceheight-53, 110, 40);
    backButton.tag = 2;
    [backButton addTarget:self action:@selector(continueButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    // Add Kid + Spouse
    addKidButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addKidButton addTarget:self action:@selector(addKidButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [addKidButton setTag:234];
    [self.view addSubview:addKidButton];
    
    // Invite  Friends
    inviteFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteFriendsButton addTarget:self action:@selector(addKidButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [inviteFriendsButton setTag:235];
    [self.view addSubview:inviteFriendsButton];
    
    // Just Explore
    justExploreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [justExploreButton addTarget:self action:@selector(addKidButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [justExploreButton setTag:236];
    [self.view addSubview:justExploreButton];
    
    if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] containsObject:@"back"])
        [self.view addSubview:backButton];
    else
        [backButton removeFromSuperview];
    
    if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] count] > 0 && ![[[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] firstObject] isEqualToString:@"continue"])
    {
        [continueButton removeFromSuperview];
        
        [addKidButton setFrame:CGRectMake(105, Deviceheight-215, 175, 46)];
        [inviteFriendsButton setFrame:CGRectMake(105, Deviceheight-145, 140, 46)];
        if (Deviceheight<568)
            [justExploreButton setFrame:CGRectMake(105, Deviceheight-82, 120, 46)];
        else
            [justExploreButton setFrame:CGRectMake(105, 485, 120, 46)];
        
        if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] containsObject:@"add_kid"])
            [self.view addSubview:addKidButton];
        if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] containsObject:@"invite_friends"])
            [self.view addSubview:inviteFriendsButton];
        if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] containsObject:@"just_explore"])
            [self.view addSubview:justExploreButton];
    }
    else
    {
        [self.view addSubview:continueButton];
        
        [addKidButton removeFromSuperview];
        [inviteFriendsButton removeFromSuperview];
        [justExploreButton removeFromSuperview];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark- UIScrollView Delegate
#pragma mark-
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView1;
{
    
    int index = scrollView1.contentOffset.x / scrollView1.frame.size.width;
    
    if(index <= 0)
    {
        index = 0;
    }
    if(index > imageID)
    {
        if ([[[imageArray objectAtIndex:imageID] objectForKey:@"perm_notification"] boolValue])
        {
            [self askForNotificationPermission];
        }
    }
    imageID = index;
    
    
    if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] containsObject:@"back"])
        [self.view addSubview:backButton];
    else
        [backButton removeFromSuperview];
    
    if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] count] > 0 && ![[[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] firstObject] isEqualToString:@"continue"])
    {
        [continueButton removeFromSuperview];
        
        [addKidButton setFrame:CGRectMake(105, Deviceheight-215, 175, 46)];
        [inviteFriendsButton setFrame:CGRectMake(105, Deviceheight-145, 140, 46)];
        if (Deviceheight<568)
            [justExploreButton setFrame:CGRectMake(105, Deviceheight-82, 120, 46)];
        else
            [justExploreButton setFrame:CGRectMake(105, 485, 120, 46)];
        
        if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] containsObject:@"add_kid"])
            [self.view addSubview:addKidButton];
        if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] containsObject:@"invite_friends"])
            [self.view addSubview:inviteFriendsButton];
        if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] containsObject:@"just_explore"])
            [self.view addSubview:justExploreButton];
    }
    else
    {
        [self.view addSubview:continueButton];
        
        [addKidButton removeFromSuperview];
        [inviteFriendsButton removeFromSuperview];
        [justExploreButton removeFromSuperview];
    }
}

- (void)continueButtonTapped:(UIButton *)sender
{
    if([sender tag] == 1)
    {
        NSLog(@"%d",[[[imageArray objectAtIndex:imageID] objectForKey:@"perm_notification"] boolValue]);
        if ([[[imageArray objectAtIndex:imageID] objectForKey:@"perm_notification"] boolValue])
        {
            [self askForNotificationPermission];
        }
        
        imageID++;
        if(imageID == imageArray.count)
        {
            [self goToMainStreams];
            return;
        }
        
        [scrollView setContentOffset:CGPointMake(imageID*320, 0) animated:YES];
        if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] containsObject:@"back"])
            [self.view addSubview:backButton];
        else
            [backButton removeFromSuperview];
        if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] count] > 0 && ![[[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] firstObject] isEqualToString:@"continue"])
        {
            [continueButton removeFromSuperview];
            
            
            [addKidButton setFrame:CGRectMake(105, Deviceheight-215, 175, 46)];
            [inviteFriendsButton setFrame:CGRectMake(105, Deviceheight-145, 140, 46)];
            if (Deviceheight<568)
                [justExploreButton setFrame:CGRectMake(105, Deviceheight-82, 120, 46)];
            else
                [justExploreButton setFrame:CGRectMake(105, 485, 120, 46)];
            
            if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] containsObject:@"add_kid"])
                [self.view addSubview:addKidButton];
            if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] containsObject:@"invite_friends"])
                [self.view addSubview:inviteFriendsButton];
            if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] containsObject:@"just_explore"])
                [self.view addSubview:justExploreButton];
        }
        else
        {
            [self.view addSubview:continueButton];
            
            [addKidButton removeFromSuperview];
            [inviteFriendsButton removeFromSuperview];
            [justExploreButton removeFromSuperview];
        }
    }
    else
    {
        imageID--;
        
        if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] containsObject:@"back"])
            [self.view addSubview:backButton];
        else
            [backButton removeFromSuperview];
        [scrollView setContentOffset:CGPointMake(imageID*320, 0) animated:YES];
        if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] count] > 0 && ![[[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] firstObject] isEqualToString:@"continue"])
        {
            [continueButton removeFromSuperview];
            
            
            [addKidButton setFrame:CGRectMake(105, Deviceheight-215, 175, 46)];
            [inviteFriendsButton setFrame:CGRectMake(105, Deviceheight-145, 140, 46)];
            if (Deviceheight<568)
                [justExploreButton setFrame:CGRectMake(105, Deviceheight-82, 120, 46)];
            else
                [justExploreButton setFrame:CGRectMake(105, 485, 120, 46)];
            
            if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] containsObject:@"add_kid"])
                [self.view addSubview:addKidButton];
            if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] containsObject:@"invite_friends"])
                [self.view addSubview:inviteFriendsButton];
            if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] containsObject:@"just_explore"])
                [self.view addSubview:justExploreButton];
        }
        else
        {
            [self.view addSubview:continueButton];
            
            [addKidButton removeFromSuperview];
            [inviteFriendsButton removeFromSuperview];
            [justExploreButton removeFromSuperview];
        }
        
    }
    
}

-(void) askForNotificationPermission
{
  //  [appDelegate askForNotificationPermission];
}

-(void)addKidButtonTapped:(UIButton *)sender
{
    if ([[[imageArray objectAtIndex:imageID] objectForKey:@"perm_notification"] boolValue])
    {
        [self askForNotificationPermission];
    }
    [self goToMainStreams];
    
}
-(void)linkClicked
{
    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@rules",APP_BASE_URL]];
    [[UIApplication sharedApplication] openURL:url];
}
-(void)goToMainStreams
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"onboarding"] ;
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self performSegueWithIdentifier: @"MainStreamsSegue" sender: self];
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
