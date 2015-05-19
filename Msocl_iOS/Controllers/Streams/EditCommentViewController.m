//
//  EditCommentViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/30/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "EditCommentViewController.h"
#import "StringConstants.h"
#import "AppDelegate.h"
#import "ModelManager.h"
#import "ProfilePhotoUtils.h"
#import "DXPopover.h"
#import "UIImageView+AFNetworking.h"

@implementation EditCommentViewController
{
    UITextView *textView;
    AppDelegate *appdelegate;
    Webservices *webServices;
    DXPopover *popover;
    UIView *popView;
    UIImageView *postAnonymous;
    UIButton *commentBtn;
    ProfilePhotoUtils  *photoUtils;
    ModelManager *sharedModel;
    UIButton *anonymousButton;
    BOOL isAnonymous;
    UIImageView *dropDown;

}
@synthesize commentDetails;
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    photoUtils = [ProfilePhotoUtils alloc];
    
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    
    popover = [DXPopover popover];
    
    self.title = @"EDIT COMMENT";
    
    UIImage *background = [UIImage imageNamed:@"icon-back.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside]; //adding action
    [button setImage:background forState:UIControlStateNormal];
    button.frame = CGRectMake(0 ,0,13,17);
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    

    
    
    commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [commentBtn addTarget:self action:@selector(callCommentApi) forControlEvents:UIControlEventTouchUpInside];
    [commentBtn setFrame:CGRectMake(244, 5, 43, 30.5)];
    [commentBtn setImage:[UIImage imageNamed:@"btn-post.png"] forState:UIControlStateNormal];
    
    anonymousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [anonymousButton setImage:[UIImage imageNamed:@"btn-post-ana.png"] forState:UIControlStateNormal];
    [anonymousButton addTarget:self action:@selector(anonymousCommentClicked:) forControlEvents:UIControlEventTouchUpInside];
    [anonymousButton setFrame:CGRectMake(287, 5, 30, 30)];
    
    postAnonymous = [[UIImageView alloc] initWithFrame:CGRectMake(4, 2.5, 22, 22)];
    
    dropDown = [[UIImageView alloc] initWithFrame:CGRectMake(302, 24, 10, 9)];
    [dropDown setImage:[UIImage imageNamed:@"btn-post-dropdown.png"]];

    
    __weak UIImageView *weakSelf = postAnonymous;
    __weak ProfilePhotoUtils *weakphotoUtils = photoUtils;
    sharedModel = [ModelManager sharedModel];
    
    [postAnonymous setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:sharedModel.userProfile.image]] placeholderImage:[UIImage imageNamed:@"icon-profile-register.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf.image = [weakphotoUtils makeRoundWithBoarder:[weakphotoUtils squareImageWithImage:image scaledToSize:CGSizeMake(18, 18)] withRadious:0];
         
     }failure:nil];
    [anonymousButton addSubview:postAnonymous];
    
    [self.navigationController.navigationBar addSubview:commentBtn];
    [self.navigationController.navigationBar addSubview:anonymousButton];
    [self.navigationController.navigationBar addSubview:dropDown];

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 300, 108)];
    [imageView setImage:[UIImage imageNamed:@"textfield.png"]];
    [self.view addSubview:imageView];
    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(14,24,292, 100)];
    textView.font = [UIFont fontWithName:@"Ubuntu-Light" size:13];
    textView.delegate = self;
    [self.view addSubview:textView];

    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    [self setDetails];

}
-(void)setDetails
{
    textView.text = [commentDetails objectForKey:@"text"];
    if([[commentDetails objectForKey:@"anonymous"] boolValue])
    {
        postAnonymous.image = [UIImage imageNamed:@"icon-anamous.png"];
        isAnonymous = YES;
    }

}
-(void)backClicked
{
    [textView resignFirstResponder];
    [commentBtn removeFromSuperview];
    [postAnonymous removeFromSuperview];
    [anonymousButton removeFromSuperview];
    [dropDown removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark -
#pragma mark Comment Methods
-(void)anonymousCommentClicked:(id)sender
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = [(UIButton *)sender frame];
        frame.origin.y += 20;
        btn.frame = frame;
        
        popView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 32)];
        
        if(isAnonymous)
        {
            UILabel *postAsLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 32)];
            [postAsLabel1 setText:@"Comment as"];
            [postAsLabel1 setTextAlignment:NSTextAlignmentCenter];
            [postAsLabel1 setTextColor:[UIColor colorWithRed:76/255.0 green:121/255.0 blue:251/255.0 alpha:1.0]];
            [postAsLabel1 setFont:[UIFont fontWithName:@"Ubuntu-Light" size:14]];
            [popView addSubview:postAsLabel1];
            
            UIImageView *userImage = [[UIImageView alloc] initWithFrame:CGRectMake(200, 4, 24, 24)];
            
            __weak UIImageView *weakSelf1 = userImage;
            __weak ProfilePhotoUtils *weakphotoUtils1 = photoUtils;
            
            [userImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:sharedModel.userProfile.image]] placeholderImage:[UIImage imageNamed:@"icon-profile-register.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 weakSelf1.image = [weakphotoUtils1 makeRoundWithBoarder:[weakphotoUtils1 squareImageWithImage:image scaledToSize:CGSizeMake(24, 24)] withRadious:0];
                 
             }failure:nil];
            [popView addSubview:userImage];
            
            UIButton *postBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            postBtn.frame = CGRectMake(0, 0, 300, 32);
            [postBtn addTarget:self action:@selector(commentClicked:) forControlEvents:UIControlEventTouchUpInside];
            [popView addSubview:postBtn];
            
        }
        else
        {
            UILabel *postAsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 32)];
            [postAsLabel setText:@"Comment as"];
            [postAsLabel setTextAlignment:NSTextAlignmentCenter];
            [postAsLabel setTextColor:[UIColor colorWithRed:76/255.0 green:121/255.0 blue:251/255.0 alpha:1.0]];
            [postAsLabel setFont:[UIFont fontWithName:@"Ubuntu-Light" size:14]];
            [popView addSubview:postAsLabel];
            
            UIImageView *anonymusImage = [[UIImageView alloc] initWithFrame:CGRectMake(192, 4, 32, 24)];
            [anonymusImage setImage:[UIImage imageNamed:@"icon-anamous.png"]];
            [popView addSubview:anonymusImage];
            
            UIButton *postBtnAnonymous = [UIButton buttonWithType:UIButtonTypeCustom];
            postBtnAnonymous.frame = CGRectMake(0, 0, 300, 32);
            [postBtnAnonymous addTarget:self action:@selector(commentAsAnonymous) forControlEvents:UIControlEventTouchUpInside];
            [popView addSubview:postBtnAnonymous];
            
        }
        
        
        [popover showAtView:btn withContentView:popView];
    }
   
}
-(void)commentAsAnonymous
{
    [popover dismiss];
    isAnonymous = YES;
    postAnonymous.image = [UIImage imageNamed:@"icon-anamous.png"];
}
-(void)commentClicked:(id)sender
{
    [popover dismiss];
    isAnonymous = NO;
    __weak UIImageView *weakSelf = postAnonymous;
    __weak ProfilePhotoUtils *weakphotoUtils = photoUtils;
    
    [postAnonymous setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:sharedModel.userProfile.image]] placeholderImage:[UIImage imageNamed:@"icon-profile-register.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf.image = [weakphotoUtils makeRoundWithBoarder:[weakphotoUtils squareImageWithImage:image scaledToSize:CGSizeMake(18, 18)] withRadious:0];
         
     }failure:nil];
    isAnonymous = NO;
}
-(void)callCommentApi
{
    [appdelegate showOrhideIndicator:YES];
    
    
    AccessToken* token = sharedModel.accessToken;
    
    NSDictionary* postData = @{@"command": @"update",@"access_token": token.access_token,@"body":@{@"text":textView.text,@"anonymous":[NSNumber numberWithBool:isAnonymous]}};
    NSDictionary *userInfo = @{@"command": @"Comment"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@comments/%@",BASE_URL,[commentDetails objectForKey:@"uid"]];
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
    [textView resignFirstResponder];
    
}
-(void) commentSuccessful:(NSDictionary *)recievedDict
{
    
    [appdelegate showOrhideIndicator:NO];
    [self.delegate CommentEdited:recievedDict];
    [textView resignFirstResponder];
    [commentBtn removeFromSuperview];
    [postAnonymous removeFromSuperview];
    [anonymousButton removeFromSuperview];
    [dropDown removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];

}
-(void) commentFailed
{
    [appdelegate showOrhideIndicator:NO];
}

@end
