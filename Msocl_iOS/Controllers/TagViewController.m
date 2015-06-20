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
    BOOL animated;
    float currentIndex;
    float upstart;
    float downstart;
    CGRect originalPosition;
    
}
@synthesize tagName;
@synthesize followOrEditBtn;
@synthesize nameLabel;
@synthesize profileImageVw;
@synthesize smallProfileImageVw;
@synthesize animatedTopView;
@synthesize followingCount;
@synthesize postsCount;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    
    followOrEditBtn.hidden = YES;
    
    
    streamDisplay = [[StreamDisplayView alloc] initWithFrame:CGRectMake(0, 198, 320, Deviceheight-198-64)];
    streamDisplay.delegate = self;
    streamDisplay.isTag = YES;
    streamDisplay.tagName = [tagName stringByReplacingOccurrencesOfString:@"#" withString:@""];
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
    
    
    
    nameLabel.text = tagName;
    
    NSArray *tagsArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"Groups"];
    NSArray *array = [tagsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name = %@",tagName]];
    
    NSDictionary *dict = [array lastObject];
    /* __weak UIImageView *weakSelf = profileImageVw;
     __weak TagViewController *weakSelf2 = self;
     profileImageVw.tintColor = [UIColor redColor];
     
     
     [profileImageVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[dict objectForKey:@"image"]]] placeholderImage:[UIImage imageNamed:@"placeHolder_show.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
     weakSelf.image = [weakSelf2 grayishImage:[image resizedImageByMagick:@"320x195#"]];
     
     }failure:nil];
     */
    profileImageVw.backgroundColor = [UIColor colorWithRed:197/255.0 green:33/255.0 blue:40/255.0 alpha:1.0];
    __weak UIImageView *weakSelf1 = smallProfileImageVw;
    [smallProfileImageVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[dict objectForKey:@"image"]]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         CATransition *transition = [CATransition animation];
         transition.duration = 1.0;
         transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
         transition.type = kCATransitionFade;
         [weakSelf1.layer addAnimation:transition forKey:nil];

         weakSelf1.image = [image resizedImageByMagick:@"320x198#"];
         
     }failure:nil];
    
    [self callTagDetails];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClicked:)];
    addButton.tintColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
    self.navigationItem.rightBarButtonItem= addButton;


}
-(void)addClicked:(id)sender
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
        [self performSegueWithIdentifier: @"AddPostsSegue" sender: self];
    else
    {
        [self gotoLoginScreen];
    }
}

#pragma mark -
#pragma mark Tag Details
-(void)callTagDetails
{
    AccessToken* token = modelManager.accessToken;
    NSString *command;
    command = @"show";
    NSDictionary* postData = @{@"command": command,@"access_token": token.access_token,@"body":@{@"name":tagName}};
    NSDictionary *userInfo = @{@"command": @"ProfileDetails"};
    NSString *urlAsString = [NSString stringWithFormat:@"%@groups",BASE_URL];
    
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
    
}
-(void)profileDetailsSuccessFull:(NSDictionary *)recievedDict
{
    recievedDict = [recievedDict objectForKey:@"body"];

    followOrEditBtn.hidden = NO;
    if([[recievedDict objectForKey:@"follow"] boolValue])
        [followOrEditBtn setTitle:@"un-follow" forState:UIControlStateNormal];
    else
        [followOrEditBtn setTitle:@"follow" forState:UIControlStateNormal];
    
    self.tagId = [recievedDict objectForKey:@"uid"];
    [followingCount setText:[NSString stringWithFormat:@"Followers: %@",[recievedDict objectForKey:@"followers_count"]]];
    [postsCount setText:[NSString stringWithFormat:@"Posts: %@",[recievedDict objectForKey:@"posts_count"]]];
    
    __weak UIImageView *weakSelf1 = smallProfileImageVw;
    
    [smallProfileImageVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[recievedDict objectForKey:@"image"]]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         
         weakSelf1.image = [image resizedImageByMagick:@"320x198#"];
         CATransition *transition = [CATransition animation];
         transition.duration = 1.0;
         transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
         transition.type = kCATransitionFade;
         [weakSelf1.layer addAnimation:transition forKey:nil];

         
     }failure:nil];

}

-(void) profileDetailsFailed
{
        
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
- (UIImage*) grayishImage: (UIImage*) inputImage {
    
    // Create a graphic context.
    UIGraphicsBeginImageContextWithOptions(inputImage.size, YES, 1.0);
    CGRect imageRect = CGRectMake(0, 0, inputImage.size.width, inputImage.size.height);
    
    // Draw the image with the luminosity blend mode.
    // On top of a white background, this will give a black and white image.
    [inputImage drawInRect:imageRect blendMode:kCGBlendModeLuminosity alpha:1.0];
    
    // Get the resulting image.
    UIImage *filteredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return filteredImage;
    
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
        if([[followOrEditBtn titleForState:UIControlStateNormal] isEqualToString:@"follow"])
            command = @"follow";
        else
            command = @"unfollow";
        NSDictionary* postData = @{@"command": command,@"access_token": token.access_token};
        NSDictionary *userInfo = @{@"command": @"followGroup"};
        NSString *urlAsString = [NSString stringWithFormat:@"%@groups/%@",BASE_URL,self.tagId
                                 ];
        [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
        
        
    }
    else
    {
        [self gotoLoginScreen];
    }
    
}
-(void) followingGroupSuccessFull:(NSDictionary *)recievedDict
{
    [appdelegate showOrhideIndicator:NO];
    if([[followOrEditBtn titleForState:UIControlStateNormal] isEqualToString:@"follow"])
    {
        [followOrEditBtn setTitle:@"un-follow" forState:UIControlStateNormal];
        
        int count =  [[[followingCount.text componentsSeparatedByString:@" "] lastObject] intValue]+1;
        followingCount.text = [NSString stringWithFormat:@"Followers: %i",count];
    }
    else
    {
        int count =  [[[followingCount.text componentsSeparatedByString:@" "] lastObject] intValue] - 1;
        followingCount.text = [NSString stringWithFormat:@"Followers: %i",count];
        
        [followOrEditBtn setTitle:@"follow" forState:UIControlStateNormal];
        
    }
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
- (void)animateTopUp
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    // originalPosition = streamView.frame;
    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        animatedTopView.frame = CGRectMake(0, -198, screenWidth, 198);
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
                         animatedTopView.frame = CGRectMake(0, 0, screenWidth, 198);
                         streamDisplay.frame = originalPosition;
                         streamDisplay.streamTableView.frame = CGRectMake(0, 0, 320, originalPosition.size.height);
                         
                     }
     ];
    
    
    
}

-(void)tagImage:(NSDictionary *)tagDetails
{
    /*   __weak TagViewController *weakSelf2 = self;
     __weak UIImageView *weakSelf = profileImageVw;
     
     [profileImageVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:[UIImage imageNamed:@"placeHolder_show.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
     weakSelf.image = [weakSelf2 grayishImage:[image resizedImageByMagick:@"320x195#"]];
     }failure:nil];
     */
    
    
}

@end
