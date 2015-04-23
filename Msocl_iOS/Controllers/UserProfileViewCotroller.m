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
}
@synthesize name;
@synthesize profileId;
@synthesize photo;
@synthesize followOrEditBtn;
@synthesize nameLabel;
@synthesize profileImageVw;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *line = [[UILabel alloc] initWithFrame: CGRectMake(0, 228.5, 320, 0.5)];
    line.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    [line setTextAlignment:NSTextAlignmentLeft];
    line.backgroundColor = [UIColor colorWithRed:(204/255.f) green:(204/255.f) blue:(204/255.f) alpha:1];
    [self.view addSubview:line];

    
    streamDisplay = [[StreamDisplayView alloc] initWithFrame:CGRectMake(0, 229, 320, Deviceheight-229)];
    streamDisplay.delegate = self;
    streamDisplay.isUserProfilePosts = YES;
    streamDisplay.userProfileId = profileId;
    [self.view addSubview:streamDisplay];
    
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
    if([modelManager.userProfile.uid isEqualToString:profileId])
    {
        [followOrEditBtn setTitle:@"Edit" forState:UIControlStateNormal];
    }
    else
        followOrEditBtn.hidden = YES;
    
    nameLabel.text = name;

        __weak UIImageView *weakSelf = profileImageVw;
    __weak ProfilePhotoUtils *weakphotoUtils = photoUtils;
        
        [profileImageVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:photo]] placeholderImage:[UIImage imageNamed:@"icon-profile-register.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             weakSelf.image = [weakphotoUtils makeRoundWithBoarder:[weakphotoUtils squareImageWithImage:image scaledToSize:CGSizeMake(36, 36)] withRadious:0];
             
         }failure:nil];
    

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO];
    
    [self refreshWall];
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
#pragma mark Follow or Unfollow Methods
-(IBAction)followOrEditClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if([[button titleForState:UIControlStateNormal] isEqualToString:@"Edit"])
    {
        
    }
    else
    {
        [appdelegate showOrhideIndicator:YES];
        AccessToken* token = modelManager.accessToken;
        NSString *command;
        if([[button titleForState:UIControlStateNormal] isEqualToString:@"Follow"])
            command = @"follow";
        else
            command = @"unfollow";
        NSDictionary* postData = @{@"command": command,@"access_token": token.access_token};
        NSDictionary *userInfo = @{@"command": @"followUser"};
        NSString *urlAsString = [NSString stringWithFormat:@"%@users/%@",BASE_URL,profileId];
        [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];

    }
}
-(void) followingUserSuccessFull:(NSDictionary *)recievedDict
{
    [appdelegate showOrhideIndicator:NO];
    if([[followOrEditBtn titleForState:UIControlStateNormal] isEqualToString:@"Follow"])
    [followOrEditBtn setTitle:@"Unfollow" forState:UIControlStateNormal];
    else
        [followOrEditBtn setTitle:@"Follow" forState:UIControlStateNormal];
}
-(void) followingUserFailed
{
    [appdelegate showOrhideIndicator:NO];
}
#pragma mark -
#pragma mark Call backs from stream display
-(void)userProifleClicked:(int)index
{
    
}
- (void)recievedData:(BOOL)isFollowing
{
    
    if(![modelManager.userProfile.uid isEqualToString:profileId])
    {
        followOrEditBtn.hidden = NO;
    if(isFollowing)
    {
        [followOrEditBtn setTitle:@"Unfollow" forState:UIControlStateNormal];
        
    }
    else
    {
        [followOrEditBtn setTitle:@"Follow" forState:UIControlStateNormal];
    }
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
}
-(void) PostEditedFromPostDetails:(PostDetails *)postDetails
{
        [streamDisplay.storiesArray replaceObjectAtIndex:selectedIndex withObject:postDetails];
}
-(void)PostDeletedFromPostDetails
{
        [streamDisplay.storiesArray removeObjectAtIndex:selectedIndex];
        [streamDisplay.streamTableView reloadData];
    
}


@end

