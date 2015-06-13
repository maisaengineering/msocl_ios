//
//  UserProfileViewCotroller.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/23/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "UserProfileViewCotroller.h"
#import "ModelManager.h"
#import "LoginViewController.h"
#import "PostDetails.h"
#import "UIImageView+AFNetworking.h"
#import "ProfilePhotoUtils.h"
#import "AppDelegate.h"
#import "UpdateUserDetailsViewController.h"
#import "TagViewController.h"
#import "LoginViewController.h"
@implementation UserProfileViewCotroller
{
    StreamDisplayView *streamDisplay;
    ModelManager *modelManager;
    NSString *selectedPostId;
    BOOL isShowPostCalled;
    PostDetails *selectedPost;
    ProfilePhotoUtils *photoUtils;
    int selectedIndex;
    Webservices *webServices;
    AppDelegate *appdelegate;
    NSString *selectedTag;
    BOOL animated;
    float currentIndex;
    float upstart;
    float downstart;
    CGRect originalPosition;

}
@synthesize name;
@synthesize profileId;
@synthesize photo;
@synthesize followOrEditBtn;
@synthesize nameLabel;
@synthesize profileImageVw;
@synthesize aboutLabel;
@synthesize animatedTopView;
@synthesize postsCount;
@synthesize followingCount;
@synthesize lineImageVw;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupanimateView];
    
    aboutLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 146, 320, 30)];
    aboutLabel.font =[UIFont fontWithName:@"SanFranciscoText-Light" size:12];
    [aboutLabel setTextAlignment:NSTextAlignmentCenter];
    [aboutLabel setBackgroundColor:[UIColor clearColor]];
    aboutLabel.textColor = [UIColor colorWithRed:(68/255.f) green:(68/255.f) blue:(68/255.f) alpha:1];

    
    streamDisplay = [[StreamDisplayView alloc] initWithFrame:CGRectMake(0, 198, 320, Deviceheight-198-64)];
    streamDisplay.delegate = self;
    streamDisplay.isUserProfilePosts = YES;
    streamDisplay.userProfileId = profileId;
    [self.view addSubview:streamDisplay];
    

    
    originalPosition = CGRectMake(0, 198, 320, Deviceheight-198-64);

    
    UIImage *background = [UIImage imageNamed:@"icon-back.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside]; //adding action
    [button setImage:background forState:UIControlStateNormal];
    button.frame = CGRectMake(0 ,0,13,17);
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;

    appdelegate = [[UIApplication sharedApplication] delegate];
    
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;

    modelManager = [ModelManager sharedModel];
    photoUtils = [ProfilePhotoUtils alloc];
    
    nameLabel.text = name;

    NSArray *nameArray = [name componentsSeparatedByString:@" "];
        __weak UIImageView *weakSelf = profileImageVw;
    __weak ProfilePhotoUtils *weakphotoUtils = photoUtils;
    
    NSMutableString *parentFnameInitial = [[NSMutableString alloc] init];
    if( [[nameArray firstObject] length] >0)
        [parentFnameInitial appendString:[[[nameArray firstObject] substringToIndex:1] uppercaseString]];
    if( [[nameArray lastObject] length] >0)
        [parentFnameInitial appendString:[[[nameArray lastObject] substringToIndex:1] uppercaseString]];
    
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:parentFnameInitial
                                           attributes:nil];
    NSRange range;
    if(parentFnameInitial.length > 0)
    {
        range.location = 0;
        range.length = 1;
        [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:32]}
                                range:range];
    }
    if(parentFnameInitial.length > 1)
    {
        range.location = 1;
        range.length = 1;
        [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:32]}
                                range:range];
    }
    
    
    //add initials
    
    UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 93, 93)];
    initial.attributedText = attributedText;
    [initial setBackgroundColor:[UIColor clearColor]];
    initial.textAlignment = NSTextAlignmentCenter;
    [profileImageVw addSubview:initial];

    
        [profileImageVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:photo]] placeholderImage:[UIImage imageNamed:@"circle-186.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             weakSelf.image = [weakphotoUtils makeRoundWithBoarder:[weakphotoUtils squareImageWithImage:image scaledToSize:CGSizeMake(93, 93)] withRadious:0];
             [initial removeFromSuperview];
             
         }failure:nil];
    
    if([modelManager.userProfile.uid isEqualToString:profileId])
    {
        followOrEditBtn.hidden = YES;
    }
    [self callUserProfile];
    //followOrEditBtn.hidden = YES;

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO];
   
    if([modelManager.userProfile.uid isEqualToString:profileId])
    {
        
        followOrEditBtn.hidden = YES;

        nameLabel.text = [NSString stringWithFormat:@"%@ %@",modelManager.userProfile.fname,modelManager.userProfile.lname];
        __weak UIImageView *weakSelf = profileImageVw;
        __weak ProfilePhotoUtils *weakphotoUtils = photoUtils;

        [profileImageVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:modelManager.userProfile.image]] placeholderImage:[UIImage imageNamed:@"circle-186.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             weakSelf.image = [weakphotoUtils makeRoundWithBoarder:[weakphotoUtils squareImageWithImage:image scaledToSize:CGSizeMake(93, 93)] withRadious:0];
             for(UIView *viw in [weakSelf subviews])
             {
                 [viw removeFromSuperview];
             }

             
         }failure:nil];
        

    }
    [self refreshWall];
}
-(void)setupanimateView
{
    animatedTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 198)];
    animatedTopView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:animatedTopView];

    profileImageVw = [[UIImageView alloc] initWithFrame:CGRectMake(114, 21, 93, 93)];
    [animatedTopView addSubview:profileImageVw];
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 117, 320, 30)];
    [nameLabel setTextColor:[UIColor darkGrayColor]];
    [nameLabel setFont:[UIFont fontWithName:@"SanFranciscoText-Regular" size:17]];
    [nameLabel setTextAlignment:NSTextAlignmentCenter];
    [animatedTopView addSubview:nameLabel];

    followOrEditBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [followOrEditBtn setFrame:CGRectMake(0, 149, 320, 18)];
    [followOrEditBtn addTarget:self action:@selector(followOrEditClicked:) forControlEvents:UIControlEventTouchUpInside];
    [followOrEditBtn.titleLabel setFont:[UIFont fontWithName:@"SanFranciscoText-Regular" size:16]];
    [followOrEditBtn setTitleColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
    [animatedTopView addSubview:followOrEditBtn];
    
    postsCount = [[UILabel alloc] initWithFrame:CGRectMake(20, 168, 130, 20)];
    [postsCount setTextColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0]];
    [postsCount setText:@"Posts: 0"];
    [postsCount setFont:[UIFont fontWithName:@"SanFranciscoText-Light" size:14]];
    [postsCount setTextAlignment:NSTextAlignmentRight];
    [animatedTopView addSubview:postsCount];
    
    followingCount = [[UILabel alloc] initWithFrame:CGRectMake(170, 168, 130, 20)];
    [followingCount setTextColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0]];
     [followingCount setText:@"Followers: 0"];
    [followingCount setFont:[UIFont fontWithName:@"SanFranciscoText-Light" size:14]];
    [followingCount setTextAlignment:NSTextAlignmentLeft];
    [animatedTopView addSubview:followingCount];
    
    lineImageVw = [[UIImageView alloc] initWithFrame:CGRectMake(0, 197, 320, 1)];
    [lineImageVw setBackgroundColor:[UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0]];
    [animatedTopView addSubview:lineImageVw];
    
}
-(void)backClicked
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)refreshWall
{
    if(!isShowPostCalled)
    {
            [streamDisplay resetData];
            [streamDisplay callStreamsApi:@"next"];
    }
    isShowPostCalled = NO;
}
#pragma mark -
#pragma mark Profile Details
-(void)callUserProfile
{
    AccessToken* token = modelManager.accessToken;
    NSString *command;
        command = @"public_profile";
    NSDictionary* postData = @{@"command": command,@"access_token": token.access_token};
    NSDictionary *userInfo = @{@"command": @"ProfileDetails"};
    NSString *urlAsString = [NSString stringWithFormat:@"%@users/%@",BASE_URL,profileId];
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];

}
-(void)profileDetailsSuccessFull:(NSDictionary *)recievedDict
{
    recievedDict = [recievedDict objectForKey:@"body"];
    nameLabel.text = [recievedDict objectForKey:@"full_name"];
    
    [followingCount setText:[NSString stringWithFormat:@"Followers: %@",[recievedDict objectForKey:@"followers_count"]]];
    [postsCount setText:[NSString stringWithFormat:@"Posts: %@",[recievedDict objectForKey:@"posts_count"]]];
    for(UIView *viw in [profileImageVw subviews])
    {
        [viw removeFromSuperview];
    }
    
    NSArray *nameArray = [[recievedDict objectForKey:@"full_name"] componentsSeparatedByString:@" "];
    
    NSMutableString *parentFnameInitial = [[NSMutableString alloc] init];
    if( [[nameArray firstObject] length] >0)
        [parentFnameInitial appendString:[[[nameArray firstObject] substringToIndex:1] uppercaseString]];
    if( [[nameArray lastObject] length] >0)
        [parentFnameInitial appendString:[[[nameArray lastObject] substringToIndex:1] uppercaseString]];
    
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:parentFnameInitial
                                           attributes:nil];
    NSRange range;
    if(parentFnameInitial.length > 0)
    {
        range.location = 0;
        range.length = 1;
        [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:32]}
                                range:range];
    }
    if(parentFnameInitial.length > 1)
    {
        range.location = 1;
        range.length = 1;
        [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:32]}
                                range:range];
    }
    
    
    //add initials
    
    UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 93, 93)];
    initial.attributedText = attributedText;
    [initial setBackgroundColor:[UIColor clearColor]];
    initial.textAlignment = NSTextAlignmentCenter;
    [profileImageVw addSubview:initial];

    
    __weak UIImageView *weakSelf = profileImageVw;
    __weak ProfilePhotoUtils *weakphotoUtils = photoUtils;
    
    
    
    [profileImageVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[recievedDict objectForKey:@"photo"]]] placeholderImage:[UIImage imageNamed:@"circle-186.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf.image = [weakphotoUtils makeRoundWithBoarder:[weakphotoUtils squareImageWithImage:image scaledToSize:CGSizeMake(93, 93)] withRadious:0];
         
         [initial removeFromSuperview];
         
     }failure:nil];
    
    if([recievedDict objectForKey:@"summary"] != nil)
    {
        CGSize size = [[recievedDict objectForKey:@"summary"] sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:12]}];
        if(size.height < 21)
            size.height = 21;
        CGRect frame =  aboutLabel.frame;
        frame.size.height = size.height;
        aboutLabel.text = [recievedDict objectForKey:@"summary"];
        aboutLabel.frame = frame;
        [aboutLabel setTextColor:[UIColor colorWithRed:49/255.0 green:49/255.0 blue:49/255.0 alpha:1]];
        
        CGRect frameTop = animatedTopView.frame;
        frameTop.size.height += size.height;
        animatedTopView.frame = frameTop;
        [animatedTopView addSubview:aboutLabel];
        
        frame =  followOrEditBtn.frame;
        frame.origin.y += size.height;
        followOrEditBtn.frame = frame;
        
        frame =  followingCount.frame;
        frame.origin.y += size.height;
        followingCount.frame = frame;
        
        frame =  postsCount.frame;
        frame.origin.y += size.height;
        postsCount.frame = frame;
        
        frame =  lineImageVw.frame;
        frame.origin.y += size.height;
        lineImageVw.frame = frame;
        
        
        originalPosition = CGRectMake(0, frame.origin.y+frame.size.height, 320, Deviceheight-frame.size.height-frame.origin.y-64);

      streamDisplay.frame = CGRectMake(0, frame.origin.y+frame.size.height, 320, Deviceheight-frame.size.height-frame.origin.y-64);
    
    }

}
-(void) profileDetailsFailed
{

}
-(void)tableScrolledForTopView:(float)index
{
    DebugLog(@"Did Scroll in TOC %f", index);
    /*
     if (index > 25 && animated == FALSE)
     {
     animated = TRUE;
     [self animateTop];
     }
     */
    if (index < -20 && animated == TRUE)
    {
        [self animateTopDown];
        animated = FALSE;
        return;
    }
    
    if (index > 0)
    {
        if (currentIndex < index) //going back down
        {
            upstart = 0;
            
            if (downstart == 0)
            {
                downstart = currentIndex;
                //DebugLog(@"downstart = %f", currentIndex);
                //[self animateTopDown];
            }
            else
            {
                float distance = currentIndex - downstart;
                //DebugLog(@"down distance %f", distance);
                if (distance > 20 && animated == FALSE)
                {
                    //DebugLog(@"Make it go up");
                    [self animateTopUp];
                    animated = TRUE;
                }
            }
        }
        
        
        if (currentIndex > index) //going back up
        {
            downstart = 0;
            
            if (upstart == 0)
            {
                upstart = currentIndex;
            }
        }
        
        currentIndex = index;
    }
}
- (void)tableScrolled:(float)index
{
    
}
//The event handling method
- (void)animateTopUp
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    // originalPosition = streamView.frame;
    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = animatedTopView.frame;
        animatedTopView.frame = CGRectMake(0, -frame.size.height, screenWidth, frame.size.height);
        streamDisplay.frame = CGRectMake(0, 0, 320, screenHeight-64);
        streamDisplay.streamTableView.frame = CGRectMake(0, 0, 320, screenHeight-64);

    }
                     completion:^(BOOL finished){
                         
                     }
     ];
    
}

- (void)animateTopDown
{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         CGRect frame = animatedTopView.frame;
                         animatedTopView.frame = CGRectMake(0, 0, screenWidth, frame.size.height);
                         streamDisplay.frame = originalPosition;
                         streamDisplay.streamTableView.frame = CGRectMake(0, 0, 320, originalPosition.size.height);

                     }
     ];
    
    
    
}


#pragma mark -
#pragma mark Follow or Unfollow Methods


-(IBAction)followOrEditClicked:(id)sender
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    {
        UIButton *button = (UIButton *)sender;
        if([[button titleForState:UIControlStateNormal] isEqualToString:@"Edit"])
        {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UpdateUserDetailsViewController *login = [mainStoryboard instantiateViewControllerWithIdentifier:@"UpdateUserDetailsViewController"];
            [self.navigationController pushViewController:login animated:NO];
            
        }
        else
        {
            [appdelegate showOrhideIndicator:YES];
            AccessToken* token = modelManager.accessToken;
            NSString *command;

            if([[followOrEditBtn titleForState:UIControlStateNormal] isEqualToString:@"un-follow"])
                command = @"unfollow";
            else
                command = @"follow";
            NSDictionary* postData = @{@"command": command,@"access_token": token.access_token};
            NSDictionary *userInfo = @{@"command": @"followUser"};
            NSString *urlAsString = [NSString stringWithFormat:@"%@users/%@",BASE_URL,profileId];
            [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
            
        }
        
    }
    else
    {
        [self gotoLoginScreen];
    }

}
-(void) followingUserSuccessFull:(NSDictionary *)recievedDict
{
    if([[followOrEditBtn titleForState:UIControlStateNormal] isEqualToString:@"follow"])
    {
        int count =  [[[followingCount.text componentsSeparatedByString:@" "] lastObject] intValue]+1;
        followingCount.text = [NSString stringWithFormat:@"Followers: %i",count];

        [followOrEditBtn setTitle:@"un-follow" forState:UIControlStateNormal];
    }
    else
    {
        int count =  [[[followingCount.text componentsSeparatedByString:@" "] lastObject] intValue] - 1;
        followingCount.text = [NSString stringWithFormat:@"Followers: %i",count];

        [followOrEditBtn setTitle:@"follow" forState:UIControlStateNormal];
    }
    [appdelegate showOrhideIndicator:NO];
}
-(void) followingUserFailed
{
    [appdelegate showOrhideIndicator:NO];
}

-(void)gotoLoginScreen
{
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *login = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    login.view.frame = CGRectMake(0,-screenHeight,screenWidth,screenHeight);
    
    [[[[UIApplication sharedApplication] delegate] window] addSubview:login.view];
    
    
    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        login.view.frame = CGRectMake(0,0,screenWidth,screenHeight);
        
    }
                     completion:^(BOOL finished){
                         [login.view removeFromSuperview];
                         
                         [self.navigationController pushViewController:login animated:NO];
                     }
     ];
    
    
    
}
#pragma mark -
#pragma mark Call backs from stream display
-(void)userProifleClicked:(int)index
{
    
}
- (void)tagCicked:(NSString *)tagName
{
    selectedTag = tagName;
    [self performSegueWithIdentifier: @"TagView" sender: self];

}
- (void)recievedData:(BOOL)isFollowing
{
    
    if(![modelManager.userProfile.uid isEqualToString:profileId])
    {
        followOrEditBtn.hidden = NO;

        if(isFollowing)
            [followOrEditBtn setTitle:@"un-follow" forState:UIControlStateNormal];
        else
            [followOrEditBtn setTitle:@"follow" forState:UIControlStateNormal];


    }
}
- (void)tableDidSelect:(int)index
{
        isShowPostCalled = YES;
        PostDetails *postObject = [streamDisplay.storiesArray objectAtIndex:index];
        selectedPostId = postObject.uid;
        selectedPost = postObject;
        selectedIndex = index;
        [self performSegueWithIdentifier: @"PostSeague" sender: self];
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
    else if ([segue.identifier isEqualToString:@"TagView"])
    {
        
        TagViewController *destViewController = segue.destinationViewController;
        destViewController.tagName = selectedTag;
    }

}
-(void) PostEditedFromPostDetails:(PostDetails *)postDetails
{
        [streamDisplay.storiesArray replaceObjectAtIndex:selectedIndex withObject:postDetails];
        [streamDisplay.streamTableView reloadData];
}
-(void)PostDeletedFromPostDetails
{
        [streamDisplay.storiesArray removeObjectAtIndex:selectedIndex];
        [streamDisplay.streamTableView reloadData];
    
}
-(void)tagImage:(NSDictionary *)url
{
    
}

@end

