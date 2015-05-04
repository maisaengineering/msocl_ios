//
//  TagViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/25/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "TagViewController.h"
#import "ModelManager.h"
#import "LoginViewController.h"
#import "PostDetails.h"
#import "UIImageView+AFNetworking.h"
#import "ProfilePhotoUtils.h"
#import "AppDelegate.h"
#import "UserProfileViewCotroller.h"
#import "UpdateUserDetailsViewController.h"
#import "UIImage+ResizeMagick.h"
@implementation TagViewController
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
@synthesize tagName;
@synthesize followOrEditBtn;
@synthesize nameLabel;
@synthesize profileImageVw;
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [followOrEditBtn setImage:[UIImage imageNamed:@"icon-favorite.png"] forState:UIControlStateSelected];

    
    UILabel *line = [[UILabel alloc] initWithFrame: CGRectMake(0, 228.5, 320, 0.5)];
    line.font =[UIFont fontWithName:@"Ubuntu-Light" size:10];
    [line setTextAlignment:NSTextAlignmentLeft];
    line.backgroundColor = [UIColor colorWithRed:(204/255.f) green:(204/255.f) blue:(204/255.f) alpha:1];
    [self.view addSubview:line];
    
    followOrEditBtn.hidden = YES;

    
    streamDisplay = [[StreamDisplayView alloc] initWithFrame:CGRectMake(0, 219, 320, Deviceheight-219)];
    streamDisplay.delegate = self;
    streamDisplay.isTag = YES;
    streamDisplay.tagName = [tagName stringByReplacingOccurrencesOfString:@"#" withString:@""];
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
    
    nameLabel.text = tagName;

  NSArray *tagsArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"Groups"];
    NSArray *array = [tagsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name = %@",tagName]];

    NSDictionary *dict = [array lastObject];
   __weak UIImageView *weakSelf = profileImageVw;
    
    [profileImageVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[dict objectForKey:@"picture"]]] placeholderImage:[UIImage imageNamed:@"icon-profile-register.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf.image = [image resizedImageByMagick:@"260x114#"];
         
     }failure:nil];
    
    
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
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    {
            [appdelegate showOrhideIndicator:YES];
            AccessToken* token = modelManager.accessToken;
            NSString *command;
            if(!followOrEditBtn.selected)
                command = @"follow";
            else
                command = @"unfollow";
            NSDictionary* postData = @{@"command": command,@"access_token": token.access_token};
            NSDictionary *userInfo = @{@"command": @"followGroup"};
            NSString *urlAsString = [NSString stringWithFormat:@"%@groups/%@",BASE_URL,streamDisplay.tagId
                                     ];
            [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
            
        
    }
    else
    {
    }
    
}
-(void) followingGroupSuccessFull:(NSDictionary *)recievedDict
{
    [appdelegate showOrhideIndicator:NO];
    followOrEditBtn.selected = !followOrEditBtn.selected;
}
-(void) followingGroupFailed
{
    [appdelegate showOrhideIndicator:NO];

}

#pragma mark -
#pragma mark Call backs from stream display
- (void)userProifleClicked:(int)index
{
    selectedIndex = index;
    PostDetails *postObject;
        postObject = [streamDisplay.storiesArray objectAtIndex:selectedIndex];

    if([[postObject.owner objectForKey:@"uid"] isEqualToString:modelManager.userProfile.uid])
    {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UpdateUserDetailsViewController *login = [mainStoryboard instantiateViewControllerWithIdentifier:@"UpdateUserDetailsViewController"];
        [self.navigationController pushViewController:login animated:NO];
        
    }
    else
        [self performSegueWithIdentifier: @"UserProfile" sender: self];

    [self performSegueWithIdentifier: @"UserProfile" sender: self];
}
- (void)tagCicked:(NSString *)tag
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TagViewController *tagView = [mainStoryboard instantiateViewControllerWithIdentifier:@"TagViewController"];
    tagView.tagName = tag;
    [self.navigationController pushViewController:tagView animated:YES];

}
- (void)recievedData:(BOOL)isFollowing
{
    
    if([streamDisplay.tagId length] > 0)
    {
    
        followOrEditBtn.hidden = NO;
        if(isFollowing)
        {
            [followOrEditBtn setSelected:YES];
            
        }
        else
        {
            [followOrEditBtn setSelected:YES];
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
    else if ([segue.identifier isEqualToString:@"AddPostsSegue"])
        {
            AddPostViewController *destViewController = segue.destinationViewController;
            destViewController.selectedtagsArray = [NSMutableArray arrayWithObject:tagName];
        }
    else if ([segue.identifier isEqualToString:@"UserProfile"])
    {
        PostDetails *postObject;

        postObject = [streamDisplay.storiesArray objectAtIndex:selectedIndex];
        
        UserProfileViewCotroller *destViewController = segue.destinationViewController;
        destViewController.photo = [postObject.owner objectForKey:@"photo"];
        destViewController.name = [NSString stringWithFormat:@"%@ %@",[postObject.owner objectForKey:@"fname"],[postObject.owner objectForKey:@"lname"]];
        destViewController.profileId = [postObject.owner objectForKey:@"uid"];
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
- (void)tableScrolled:(float)y
{
    
}

-(void)tagImage:(NSString *)url
{
    __weak UIImageView *weakSelf = profileImageVw;
    
    [profileImageVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:[UIImage imageNamed:@"icon-profile-register.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf.image = [image resizedImageByMagick:@"260x114#"];
         
     }failure:nil];

}

@end
