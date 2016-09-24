//
//  HashTagViewController.m
//  Msocl_iOS
//
//  Created by Maisa Pride on 9/23/16.
//  Copyright © 2016 Maisa Solutions. All rights reserved.
//

#import "HashTagViewController.h"
#import "ModelManager.h"
#import "LoginViewController.h"
#import "PostDetails.h"
#import "UIImageView+AFNetworking.h"
#import "ProfilePhotoUtils.h"
#import "AppDelegate.h"
#import "UserProfileViewCotroller.h"
#import "UpdateUserDetailsViewController.h"
#import "UIImage+ResizeMagick.h"
//#import "Flurry.h"
#import "NewLoginViewController.h"
#import "TagViewController.h"
@interface HashTagViewController ()
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
    

}
@end
@implementation HashTagViewController
@synthesize tagName;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    streamDisplay = [[StreamDisplayView alloc] initWithFrame:CGRectMake(0, 0, 320, Deviceheight-64)];
    streamDisplay.delegate = self;
    [self.view addSubview:streamDisplay];
    
    
    streamDisplay.isSearching = YES;
    streamDisplay.searchString = tagName;
    streamDisplay.isHashTag = YES;
    
    
    appdelegate = [[UIApplication sharedApplication] delegate];
    
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    
    modelManager = [ModelManager sharedModel];
    photoUtils = [ProfilePhotoUtils alloc];
    
    UIImage *background = [UIImage imageNamed:@"icon-back.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside]; //adding action
    [button setImage:background forState:UIControlStateNormal];
    button.frame = CGRectMake(0 ,0,13,17);
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;

    
    self.title = tagName;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO];
    if(tagName.length > 0)
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
- (void)hashTagCicked:(NSString *)tagName1
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HashTagViewController *tagView = [mainStoryboard instantiateViewControllerWithIdentifier:@"HashTagViewController"];
    tagView.tagName = tagName1;
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
        destViewController.imageUrl = [postObject.owner objectForKey:@"photo"];
        
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
