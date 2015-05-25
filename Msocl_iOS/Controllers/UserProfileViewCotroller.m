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
}
@synthesize name;
@synthesize profileId;
@synthesize photo;
@synthesize followOrEditBtn;
@synthesize nameLabel;
@synthesize profileImageVw;
@synthesize aboutLabel;

-(void)viewDidLoad
{
    [super viewDidLoad];
    

    
    aboutLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 180, 320, 30)];
    aboutLabel.font =[UIFont fontWithName:@"Ubuntu-Light" size:12];
    [aboutLabel setTextAlignment:NSTextAlignmentCenter];
    aboutLabel.textColor = [UIColor colorWithRed:(68/255.f) green:(68/255.f) blue:(68/255.f) alpha:1];
    aboutLabel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:aboutLabel];

    
    streamDisplay = [[StreamDisplayView alloc] initWithFrame:CGRectMake(0, 180, 320, Deviceheight-180-64)];
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
        [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"Ubuntu" size:32]}
                                range:range];
    }
    if(parentFnameInitial.length > 1)
    {
        range.location = 1;
        range.length = 1;
        [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"ubuntu" size:32]}
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
    
    [self callUserProfile];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO];
    if([modelManager.userProfile.uid isEqualToString:profileId])
    {
        
        
        nameLabel.text = [NSString stringWithFormat:@"%@ %@",modelManager.userProfile.fname,modelManager.userProfile.lname];
        __weak UIImageView *weakSelf = profileImageVw;
        __weak ProfilePhotoUtils *weakphotoUtils = photoUtils;

        [profileImageVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:modelManager.userProfile.image]] placeholderImage:[UIImage imageNamed:@"icon-profile-register.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             weakSelf.image = [weakphotoUtils makeRoundWithBoarder:[weakphotoUtils squareImageWithImage:image scaledToSize:CGSizeMake(93, 93)] withRadious:0];
             
         }failure:nil];
        

    }
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
    
    __weak UIImageView *weakSelf = profileImageVw;
    __weak ProfilePhotoUtils *weakphotoUtils = photoUtils;
    
    [profileImageVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[recievedDict objectForKey:@"photo"]]] placeholderImage:[UIImage imageNamed:@"icon-profile-register.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf.image = [weakphotoUtils makeRoundWithBoarder:[weakphotoUtils squareImageWithImage:image scaledToSize:CGSizeMake(93, 93)] withRadious:0];
         
     }failure:nil];
    
    if([recievedDict objectForKey:@"summary"] != nil)
    {
        CGSize size = [[recievedDict objectForKey:@"summary"] sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Ubuntu-Light" size:12]}];
        if(size.height < 21)
            size.height = 21;
        CGRect frame =  aboutLabel.frame;
        frame.size.height = size.height;
        aboutLabel.text = [recievedDict objectForKey:@"summary"];
        aboutLabel.frame = frame;
        
      streamDisplay.frame = CGRectMake(0, frame.origin.y+frame.size.height, 320, Deviceheight-frame.size.height-frame.origin.y-64);
    
    }

}
-(void) profileDetailsFailed
{

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
            if(!followOrEditBtn.selected)
                command = @"follow";
            else
                command = @"unfollow";
            NSDictionary* postData = @{@"command": command,@"access_token": token.access_token};
            NSDictionary *userInfo = @{@"command": @"followUser"};
            NSString *urlAsString = [NSString stringWithFormat:@"%@users/%@",BASE_URL,profileId];
            [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
            
        }
        
    }
    else
    {
    }

}
-(void) followingUserSuccessFull:(NSDictionary *)recievedDict
{
    followOrEditBtn.selected = !followOrEditBtn.selected;
    [appdelegate showOrhideIndicator:NO];
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
    {
        followOrEditBtn.selected = YES;
    }
    else
    {
        followOrEditBtn.selected = NO;
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
- (void)tableScrolled:(float)y
{
    
}
-(void)tagImage:(NSString *)url
{
    
}

@end

