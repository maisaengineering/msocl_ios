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
@synthesize smallProfileImageVw;
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [followOrEditBtn setImage:[UIImage imageNamed:@"icon-favorite.png"] forState:UIControlStateSelected];

    
    
    followOrEditBtn.hidden = YES;

    
    streamDisplay = [[StreamDisplayView alloc] initWithFrame:CGRectMake(0, 195, 320, Deviceheight-195)];
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
    
    
    nameLabel = [[UILabel alloc] init];
    [nameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:nameLabel];
    nameLabel.text = tagName;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont fontWithName:@"Ubuntu" size:17];
    
    CGSize size = [tagName sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Ubuntu" size:24]}];
    
    CGRect frame ;
    frame.origin.x = (320-size.width)/2;
    frame.size.width = size.width;
    frame.origin.y = 144;
    frame.size.height = 26;
    nameLabel.frame = frame;
    nameLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    nameLabel.layer.borderWidth = 1.5f;
    nameLabel.layer.cornerRadius = 5;
    nameLabel.layer.masksToBounds = YES;
    nameLabel.backgroundColor = [UIColor clearColor];

    
    smallProfileImageVw.layer.borderColor = [UIColor whiteColor].CGColor;
    smallProfileImageVw.layer.borderWidth = 3.0f;

    

  NSArray *tagsArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"Groups"];
    NSArray *array = [tagsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name = %@",tagName]];

    NSDictionary *dict = [array lastObject];
   __weak UIImageView *weakSelf = profileImageVw;
    __weak TagViewController *weakSelf2 = self;
    profileImageVw.tintColor = [UIColor redColor];

    
    [profileImageVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[dict objectForKey:@"image"]]] placeholderImage:[UIImage imageNamed:@"placeHolder_show.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf.image = [weakSelf2 grayishImage:[image resizedImageByMagick:@"320x195#"]];
         
     }failure:nil];

    profileImageVw.backgroundColor = [UIColor colorWithRed:197/255.0 green:33/255.0 blue:40/255.0 alpha:1.0];
    __weak UIImageView *weakSelf1 = smallProfileImageVw;
    
    [smallProfileImageVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[dict objectForKey:@"image"]]] placeholderImage:[UIImage imageNamed:@"placeHolder_show.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf1.image = [image resizedImageByMagick:@"110x80#"];
         
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
    __weak TagViewController *weakSelf2 = self;
    __weak UIImageView *weakSelf = profileImageVw;
    
    [profileImageVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:[UIImage imageNamed:@"placeHolder_show.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf.image = [weakSelf2 grayishImage:[image resizedImageByMagick:@"320x195#"]];
     }failure:nil];
    
    __weak UIImageView *weakSelf1 = smallProfileImageVw;
    
    [smallProfileImageVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:[UIImage imageNamed:@"placeHolder_show.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf1.image = [image resizedImageByMagick:@"110x80#"];
         
     }failure:nil];
    

}

@end
