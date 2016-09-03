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
#import "LoginSecondViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface NewLoginViewController ()
{
    
    ModelManager *sharedModel;
    Webservices *webServices;
    AppDelegate *appDelegate;
    UINavigationController *navgCntrl;
    LoginFirstViewController *loginFirst;
    LoginSecondViewController *loginSecond;
}
@end

@implementation NewLoginViewController
@synthesize bgImageView;
@synthesize backButton;
@synthesize addPostFromNotifications;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    sharedModel   = [ModelManager sharedModel];
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    
  /*  NSURL *url = [[NSBundle mainBundle] URLForResource:@"gandhi2" withExtension:@"gif"];
    UIImage *gif_image = [UIImage animatedImageWithAnimatedGIFURL:url];
    bgImageView.animationImages = gif_image.images;
    bgImageView.animationDuration = gif_image.duration;
    bgImageView.animationRepeatCount = 1;
    bgImageView.image = gif_image.images.lastObject;
    [bgImageView startAnimating];
*/
    
    [self.view.layer addSublayer:self.playerLayer];
    
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    loginFirst = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginFirstViewController"];
    [loginFirst.view setFrame:CGRectMake(0.0f, 0, self.view.frame.size.width, self.view.frame.size.height)];
    loginFirst.isFromEmailPrompt = _isFromEmailPrompt;
    loginFirst.isFromPhonePrompt = _isFromPhonePrompt;
    if(self.isFromPhonePrompt)
    {
        [loginFirst.txt_username setPlaceholder:@"Enter phone number"];
    }
    else if(self.isFromEmailPrompt)
    {
        [loginFirst.txt_username setPlaceholder:@"Email"];
    }
    [self.view addSubview:loginFirst.view];
    /*
    navgCntrl = [[UINavigationController alloc] initWithRootViewController:login];
    navgCntrl.navigationBarHidden = YES;
    
    [self addChildViewController:navgCntrl];
    [navgCntrl.view setFrame:CGRectMake(0.0f, 50, self.view.frame.size.width, self.view.frame.size.height - 50)];
    [self.view addSubview:navgCntrl.view];
    [navgCntrl didMoveToParentViewController:self];
    */
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(closeClicked:)];
    
    [self.view addGestureRecognizer:tap];
    
    
    [self registerNotifications];

    backButton.hidden = YES;
    
    // Do any additional setup after loading the view.
}
-(AVPlayerLayer*)playerLayer{
    if(!_playerLayer){
        
        // find movie file
        NSString *moviePath = [[NSBundle mainBundle] pathForResource:@"gandhiVd" ofType:@"mp4"];
        NSURL *movieURL = [NSURL fileURLWithPath:moviePath];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:[[AVPlayer alloc]initWithURL:movieURL]];
        _playerLayer.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height);
        [_playerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];

        [_playerLayer.player play];
        
    }
    return _playerLayer;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recievedNotification:)
                                                 name:@"ShowBackButton"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recievedNotification:)
                                                 name:@"nextClicked"
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
        addPostViewCntrl.addPostFromNotifications = self.addPostFromNotifications;
       
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
   else  if ([notification.name isEqualToString:@"ShowBackButton"])
   {
       backButton.hidden = NO;
       
   }
   else  if ([notification.name isEqualToString:@"nextClicked"])
   {
       if(self.isFromEmailPrompt)
       {
           [self closeClicked:nil];
       }
       else if(self.isFromPhonePrompt)
       {
           [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
           
           UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                    bundle: nil];
           
           VerificationViewController *addPostViewCntrl = (VerificationViewController*)[mainStoryboard
                                                                                        instantiateViewControllerWithIdentifier: @"VerificationViewController"];
           addPostViewCntrl.isFromStreamPage = YES;
          
           SlideNavigationController *slide = [SlideNavigationController sharedInstance];
           
           NSMutableArray *viewCntrlArray = [[slide viewControllers] mutableCopy];
           [viewCntrlArray removeLastObject];
           [viewCntrlArray addObject:addPostViewCntrl];
           [slide setViewControllers:viewCntrlArray animated:YES];

       }
       else
       {
       backButton.hidden = NO;
       UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
       loginSecond = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginSecondViewController"];
       loginSecond.view.frame = CGRectMake(320,0, self.view.frame.size.width, self.view.frame.size.height);
       [self.view addSubview:loginSecond.view];
           loginSecond.isSignUp = loginFirst.isSignUp;
           loginSecond.userName = loginFirst.txt_username.text;
           if(loginSecond.isSignUp)
           {
               [loginSecond.txt_password setPlaceholder:@"choose password"];
           }
           [loginSecond.backBtn addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
           loginSecond.addPostFromNotifications = self.addPostFromNotifications;

       [UIView animateWithDuration:0.7f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
           loginFirst.view.frame = CGRectMake(-320,0, self.view.frame.size.width, self.view.frame.size.height);
           loginSecond.view.frame = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height);
           
       }
                        completion:^(BOOL finished){
                            
                        }
        ];
       }
   }
    

}


-(IBAction)closeClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}
-(IBAction)backClicked:(id)sender
{
    [loginSecond.txt_password resignFirstResponder];
    backButton.hidden = YES;
    //[navgCntrl popViewControllerAnimated:YES];
    [UIView animateWithDuration:0.7f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        loginFirst.view.frame = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height);
        loginSecond.view.frame = CGRectMake(320,0, self.view.frame.size.width, self.view.frame.size.height);
        
    }
                     completion:^(BOOL finished){
                         [loginSecond.view removeFromSuperview];
                         loginSecond = nil;
                     }
     ];
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [super viewWillAppear:YES];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
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
