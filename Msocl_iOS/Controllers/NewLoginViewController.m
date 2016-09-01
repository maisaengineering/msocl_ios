//
//  NewLoginViewController.m
//  Msocl_iOS
//
//  Created by Maisa Pride on 9/1/16.
//  Copyright © 2016 Maisa Solutions. All rights reserved.
//

#import "NewLoginViewController.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "StringConstants.h"
#import "ProfilePhotoUtils.h"
#import "ProfileDateUtils.h"
#import "ModelManager.h"
#import "PostDetails.h"
#import "SDWebImageManager.h"
#import "STTweetLabel.h"
#import "UIImage+ResizeMagick.h"
#import "UIImage+GIF.h"
#import "AppDelegate.h"
#import "UIImage+animatedGIF.h"
#import "LoginFirstViewController.h"
#import "SlideNavigationController.h"
#import "AddPostViewController.h"
#import "VerificationViewController.h"
@interface NewLoginViewController ()
{
    
    ModelManager *sharedModel;
    Webservices *webServices;
    AppDelegate *appDelegate;

}
@end

@implementation NewLoginViewController
@synthesize bgImageView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    sharedModel   = [ModelManager sharedModel];
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"gandhi" withExtension:@"gif"];
    UIImage *gif_image = [UIImage animatedImageWithAnimatedGIFURL:url];
    bgImageView.image = gif_image;

    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginFirstViewController *login = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginFirstViewController"];
    UINavigationController *navgCntrl = [[UINavigationController alloc] initWithRootViewController:login];
    navgCntrl.navigationBarHidden = YES;
    
    [self addChildViewController:navgCntrl];
    [navgCntrl.view setFrame:CGRectMake(0.0f, 150, self.view.frame.size.width, self.view.frame.size.height - 150)];
    [self.view addSubview:navgCntrl.view];
    [navgCntrl didMoveToParentViewController:self];
    
    [self registerNotifications];

    
    // Do any additional setup after loading the view.
}
-(void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recievedNotification:)
                                                 name:@"CallClose"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recievedNotification:)
                                                 name:@"PushToVerifyPhoneNumber"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recievedNotification:)
                                                 name:@"PushToAddPost"
                                               object:nil];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)recievedNotification:(NSNotification *)notification
{
    if ([notification.name isEqualToString:@"CallClose"])
    {
        [self closeClicked:nil];

    }
   else if ([notification.name isEqualToString:@"PushToVerifyPhoneNumber"])
   {
       [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
       
       UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                bundle: nil];
       
       VerificationViewController *addPostViewCntrl = (VerificationViewController*)[mainStoryboard
                                                                          instantiateViewControllerWithIdentifier: @"VerificationViewController"];
       SlideNavigationController *slide = [SlideNavigationController sharedInstance];
       
       NSMutableArray *viewCntrlArray = [[slide viewControllers] mutableCopy];
       [viewCntrlArray removeLastObject];
       [viewCntrlArray addObject:addPostViewCntrl];
       [slide setViewControllers:viewCntrlArray animated:YES];

   }
   else if ([notification.name isEqualToString:@"PushToAddPost"])
   {
       [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
       
       UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                bundle: nil];
       
       AddPostViewController *addPostViewCntrl = (AddPostViewController*)[mainStoryboard
                                                                          instantiateViewControllerWithIdentifier: @"AddPostViewController"];
       SlideNavigationController *slide = [SlideNavigationController sharedInstance];
       
       NSMutableArray *viewCntrlArray = [[slide viewControllers] mutableCopy];
       [viewCntrlArray removeLastObject];
       [viewCntrlArray addObject:addPostViewCntrl];
       [slide setViewControllers:viewCntrlArray animated:YES];

   }
}


-(IBAction)closeClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (BOOL)prefersStatusBarHidden {
    return NO;
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [super viewWillAppear:YES];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [super viewWillDisappear:YES];
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
