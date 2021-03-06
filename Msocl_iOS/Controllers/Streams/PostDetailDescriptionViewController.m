//
//  PostDetailDescriptionViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/10/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "PostDetailDescriptionViewController.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "StringConstants.h"
#import "ProfilePhotoUtils.h"
#import "ProfileDateUtils.h"
#import "ModelManager.h"
#import "SDWebImageManager.h"
#import "STTweetLabel.h"
#import "AppDelegate.h"
#import "DXPopover.h"
#import "AddPostViewController.h"
#import "LoginViewController.h"
#import "UIImage+ResizeMagick.h"
#import "Base64.h"
#import "TagViewController.h"
#import "EditCommentViewController.h"
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"
#import "UserProfileViewCotroller.h"
#import "UIImage+GIF.h"
#import "UIImage+animatedGIF.h"
//#import "Flurry.h"
#import "PromptViewController.h"
#import "NewLoginViewController.h"
#import "STTweetLabel.h"
#import "HashTagViewController.h"

@implementation PostDetailDescriptionViewController
{
    ProfilePhotoUtils *photoUtils;
    ProfileDateUtils *profileDateUtils;
    ModelManager *sharedModel;
    AppDelegate *appDelegate;
    Webservices *webServices;
    UILabel *placeholderLabel;
    BOOL isAnonymous;
    DXPopover *popover;
    UIView *popView;
    long int commentIndex;
    MFMailComposeViewController *mailComposer;
    NSString *selectedTag;
    UIImageView *postAnonymous;
    BOOL isImageClicked;
    UIView *addPopUpView;
    UIView *inputView;
    UIImageView *iconImage;
    UIButton *editButton;
    UIBarButtonItem *shareButton;
    CGRect keyboardFrameBeginRect;
    CGRect originalPostion;
    UIButton *inviteButton;
    NSString *shareUrl;
}
@synthesize storiesArray;
@synthesize postID;
@synthesize streamTableView;
@synthesize postObjectFromWall;
@synthesize delegate;
@synthesize timerHomepage;
@synthesize subContext;
@synthesize homeContext;
@synthesize comment_uid;
@synthesize showShareDialog;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"";
    
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    appDelegate = [[UIApplication sharedApplication] delegate];
    photoUtils = [ProfilePhotoUtils alloc];
    profileDateUtils = [ProfileDateUtils alloc];
    sharedModel   = [ModelManager sharedModel];
    
    
   /* //Upvote
    UIButton *follow = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [follow setTitle:@"Follow this post" forState:UIControlStateNormal];
    [follow.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [follow setFrame:CGRectMake(0, 64, 320, 40)];
    [self.view addSubview:follow];
    */
    
    streamTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, Deviceheight-118)];
    streamTableView.delegate = self;
    streamTableView.dataSource = self;
    streamTableView.tableFooterView = [[UIView alloc] init];
    streamTableView.tableHeaderView = nil;
    streamTableView.backgroundColor = [UIColor colorWithRed:(229/255.f) green:(225/255.f) blue:(221/255.f) alpha:1];
    [streamTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.view addSubview:streamTableView];

    originalPostion = streamTableView.frame;
    
    storiesArray = [[NSMutableArray alloc] init];
    UIImage *background = [UIImage imageNamed:@"icon-back.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside]; //adding action
    [button setImage:background forState:UIControlStateNormal];
    button.frame = CGRectMake(0 ,0,13,17);
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;    
    
    self.commentView = [[UIView alloc] initWithFrame:CGRectMake(0, streamTableView.frame.origin.y+streamTableView.frame.size.height, 320, 54)];
        self.commentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.commentView];
    self.txt_comment = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 188, 54)];
    self.txt_comment.delegate = self;
        [self.txt_comment setFont:[UIFont fontWithName:@"SanFranciscoText-Light" size:14]];

    [self.commentView addSubview:self.txt_comment];
        
        placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0, self.txt_comment.frame.size.width - 15.0, 54)];
        //[placeholderLabel setText:placeholder];
        [placeholderLabel setBackgroundColor:[UIColor clearColor]];
        [placeholderLabel setNumberOfLines:0];
        placeholderLabel.text = @"Give your advice";
        [placeholderLabel setTextAlignment:NSTextAlignmentLeft];
        [placeholderLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:14]];
        [placeholderLabel setTextColor:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1.0]];
        [self.txt_comment addSubview:placeholderLabel];

        
    //Upvote
    UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [commentBtn setFrame:CGRectMake(188, 6.5, 84, 41)];
    [commentBtn setTitleColor:[UIColor colorWithRed:197/255.0 green:33/255.0 blue:40/255.0 alpha:1.0] forState:UIControlStateNormal];
    [commentBtn setTitle:@"Advice as" forState:UIControlStateNormal];
    [commentBtn.titleLabel setFont:[UIFont fontWithName:@"SanFranciscoText-Light" size:12]];
    [commentBtn setBackgroundImage:[UIImage imageNamed:@"comment-btn.png"] forState:UIControlStateNormal];
    [commentBtn addTarget:self action:@selector(callCommentApi) forControlEvents:UIControlEventTouchUpInside];
    [self.commentView addSubview:commentBtn];
    
        //Upvote
        UIButton *anonymousButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [anonymousButton setFrame:CGRectMake(272.3, 6.5, 43, 41)];
        [anonymousButton setImage:[UIImage imageNamed:@"comment-ana.png"] forState:UIControlStateNormal];
        [anonymousButton addTarget:self action:@selector(anonymousCommentClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.commentView addSubview:anonymousButton];
    
    postAnonymous = [[UIImageView alloc] initWithFrame:CGRectMake(11.5, 7.5, 25, 25)];
    
    __weak UIImageView *weakSelf = postAnonymous;
    __weak ProfilePhotoUtils *weakphotoUtils = photoUtils;
    
    NSMutableString *parentFnameInitial = [[NSMutableString alloc] init];
    if( [sharedModel.userProfile.fname length] >0)
        [parentFnameInitial appendString:[[sharedModel.userProfile.fname substringToIndex:1] uppercaseString]];
    if( [sharedModel.userProfile.lname length] >0)
        [parentFnameInitial appendString:[[sharedModel.userProfile.lname substringToIndex:1] uppercaseString]];
    
    if(parentFnameInitial.length < 1)
    {
        if( [sharedModel.userProfile.handle length] >0)
            [parentFnameInitial appendString:[[sharedModel.userProfile.handle substringToIndex:1] uppercaseString]];
        if( [sharedModel.userProfile.handle length] >1)
            [parentFnameInitial appendString:[[sharedModel.userProfile.handle substringWithRange:NSMakeRange(1, 1)] uppercaseString]];
    }
    
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:parentFnameInitial
                                           attributes:nil];
    NSRange range;
    if(parentFnameInitial.length > 0)
    {
        range.location = 0;
        range.length = 1;
        [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:13]}
                                range:range];
    }
    if(parentFnameInitial.length > 1)
    {
        range.location = 1;
        range.length = 1;
        [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:13]}
                                range:range];
    }
    
    
    //add initials
    
    UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    initial.attributedText = attributedText;
    [initial setBackgroundColor:[UIColor clearColor]];
    initial.textAlignment = NSTextAlignmentCenter;
    [postAnonymous addSubview:initial];

    [postAnonymous setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:sharedModel.userProfile.image]] placeholderImage:[UIImage imageNamed:@"circle-80.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf.image = [weakphotoUtils makeRoundWithBoarder:[weakphotoUtils squareImageWithImage:image scaledToSize:CGSizeMake(25, 25)] withRadious:0];
         [initial removeFromSuperview];
         
     }failure:nil];
    [anonymousButton addSubview:postAnonymous];

    UIImageView *dropDown = [[UIImageView alloc] initWithFrame:CGRectMake(300, 34, 9, 8)];
    [dropDown setImage:[UIImage imageNamed:@"option-dropdown.png"]];
    [self.commentView addSubview:dropDown];
        
    UILabel *line = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 320, 0.5)];
    line.font =[UIFont fontWithName:@"SanFranciscoText-Light" size:10];
    [line setTextAlignment:NSTextAlignmentLeft];
    line.backgroundColor = [UIColor colorWithRed:(225/255.f) green:(225/255.f) blue:(225/255.f) alpha:1];
    [self.commentView addSubview:line];
    
    
    inputView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [inputView setBackgroundColor:[UIColor colorWithRed:0.56f
                                                  green:0.59f
                                                   blue:0.63f
                                                  alpha:1.0f]];
    UIButton *donebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [donebtn setFrame:CGRectMake(250, 0, 70, 40)];
    [donebtn setTitle:@"Done" forState:UIControlStateNormal];
    [donebtn.titleLabel setFont:[UIFont fontWithName:@"SanFranciscoText-Medium" size:15]];
    [donebtn addTarget:self action:@selector(doneClick:) forControlEvents:UIControlEventTouchUpInside];
    [inputView addSubview:donebtn];
    
        popover = [DXPopover popover];
    
    iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(149.5, 8, 21, 28)];
    [iconImage setImage:[UIImage imageNamed:@"header-icon-samepinch.png"]];
    
    editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton addTarget:self action:@selector(editClicked) forControlEvents:UIControlEventTouchUpInside]; //adding action
    [editButton setImage:[UIImage imageNamed:@"icon-edit.png"] forState:UIControlStateNormal];
    editButton.frame = CGRectMake(250 ,10,30,30);

    [editButton setHidden:YES];

    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            postID, @"post_uid",
                            nil];
    
  //  [Flurry logEvent:@"navigation_to_post" withParameters:params timed:YES];
    
    inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteButton setTitle:@"INVITE" forState:UIControlStateNormal];
    [inviteButton setFrame:CGRectMake(220, 4, 56, 44)];
    [inviteButton.titleLabel setFont:[UIFont fontWithName:@"SanFranciscoText-Regular" size:15]];
    [inviteButton setTitleColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
    [inviteButton addTarget:self action:@selector(inviteClicked) forControlEvents:UIControlEventTouchUpInside];


}

-(void)viewWillAppear:(BOOL)animated
{
    
    [self.navigationController setNavigationBarHidden:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];

    
    DebugLog(@"postID:%@",postID);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];		

    [super viewWillAppear:YES];
    
    //[self check];
    [self.navigationController.navigationBar addSubview:iconImage];

    
    if(!isImageClicked)
    {
        isImageClicked = NO;
        [self callShowPostApi];
    }
    if([storiesArray count] > 0)
    {
    PostDetails *post = [storiesArray lastObject];
        if([post.can containsObject:@"edit"])
            [self.navigationController.navigationBar addSubview:editButton];
        
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //[self.navigationController.navigationBar addSubview:inviteButton];
    
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    {
        if(isAnonymous)
        {
            [self commentAsAnonymous];
        }
        else
        {
            [self commentClicked:nil];
        }
    }


}
- (void)keyboardDidShow:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
     keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    CGRect frame = streamTableView.frame;
    frame.size.height -= keyboardFrameBeginRect.size.height;
    streamTableView.frame = frame;
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)inviteClicked
{
    UIActionSheet *inviteActionSheet = [[UIActionSheet alloc] initWithTitle:@"Invite" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Invite by FB",@"Invite by Email",@"Invite by SMS", nil];
    inviteActionSheet.tag = 3;
    [inviteActionSheet showInView:self.view];

}
-(void)showShareOptions
{
    PostDetails *post = [storiesArray lastObject];
    shareUrl = post.url;
    [self shareOptions];
}
-(void)shareOptions
{
    UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Dismiss" destructiveButtonTitle:nil otherButtonTitles:@"Copy Link",@"Share by Email",@"Share by SMS",@"Share on WhatsApp", nil];
    shareActionSheet.tag = 2;
    [shareActionSheet showInView:self.view];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [iconImage removeFromSuperview];
    [editButton removeFromSuperview];
   
    
    //Invalidate the timer
    if([[self  timerHomepage] isValid])
        [[self  timerHomepage] invalidate];

    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            postID, @"post_uid",
                            nil];
    //[Flurry endTimedEvent:@"navigation_to_post" withParameters:params];
    
    [inviteButton removeFromSuperview];

}

-(void)backClicked
{
    if([storiesArray count] >0)
    {
    PostDetails *post = [storiesArray lastObject];
    postObjectFromWall.tags = post.tags;
    postObjectFromWall.upVoteCount = post.upVoteCount;
    postObjectFromWall.upvoted = post.upvoted;
    //postObjectFromWall.content = post.content;
    postObjectFromWall.anonymous = post.anonymous;
    postObjectFromWall.viewsCount = post.viewsCount;
    postObjectFromWall.time = post.time;
    //postObjectFromWall.images = post.images;
    [self.delegate PostEditedFromPostDetails:postObjectFromWall];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(void)doneClick:(id)sender
{
    [self.txt_comment resignFirstResponder];
    streamTableView.frame = originalPostion;
}

-(void)editClicked
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    AddPostViewController *addPost = (AddPostViewController*)[mainStoryboard
                                                                         instantiateViewControllerWithIdentifier: @"AddPostViewController"];
    addPost.postDetailsObject = [storiesArray lastObject];
    addPost.delegate = self;
    [self.navigationController pushViewController:addPost animated:YES];
}
#pragma mark -
#pragma mark API calls to get Stream data
-(void)callShowPostApi
{
    [appDelegate showOrhideIndicator:YES];
    AccessToken* token = sharedModel.accessToken;
    
    NSDictionary* postData = @{@"command": @"show",@"access_token": token.access_token};
    NSDictionary *userInfo = @{@"command": @"ShowPost"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@posts/%@",BASE_URL,postID];
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}
-(void) didReceiveShowPost:(NSDictionary *)recievedDict
{
    NSArray *postArray = [recievedDict objectForKey:@"posts"];
    PostDetails *postObject = [postArray lastObject];
    if([postObject.can containsObject:@"edit"])
    {
        [self.navigationController.navigationBar addSubview:editButton];
        [editButton setHidden:NO];
    }
    
    shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showShareOptions)];
    shareButton.tintColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
    self.navigationItem.rightBarButtonItem= shareButton;
    
    [storiesArray removeAllObjects];
    [storiesArray addObjectsFromArray:postArray];
    [self.streamTableView reloadData];
    
    if(self.comment_uid.length > 0)
    {
        NSArray *commentArray = [postObject.comments filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid = %@",self.comment_uid]];
        [self.streamTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[postObject.comments indexOfObject:[commentArray lastObject]] inSection:0]
                         atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
    }
    
    if(showShareDialog)
    {
        showShareDialog = NO;
        
        
        [[appDelegate.promptView view] removeFromSuperview];
        shareUrl = postObject.url;
        [self shareOptions];
        
    }
    
    [appDelegate showOrhideIndicator:NO];
}
-(void) showPostFailed
{
    [appDelegate showOrhideIndicator:NO];
}

#pragma mark -
#pragma mark TableViewMethods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostDetails *post = [storiesArray lastObject];

    if(indexPath.row == 0)
    return [self cellHeight:[storiesArray objectAtIndex:indexPath.row]];
    else if([storiesArray count] + post.comments.count == indexPath.row)
        return 44;
    else
        return [self cellHeightForComment:(int )indexPath.row-1];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    PostDetails *post = [storiesArray lastObject];
    long int count =0;
    count = [storiesArray count] + post.comments.count;
    return count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostDetails *postDetailsObject = [storiesArray lastObject];

    
    if(indexPath.row == 0)
    {
    static NSString *simpleTableIdentifier = @"StreamCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    
    //removes any subviews from the cell
    for(UIView *viw in [[cell contentView] subviews])
    {
        [viw removeFromSuperview];
    }
    
        [self buildCell:cell withDetails:postDetailsObject :indexPath];
    
    
    return cell;
    }
    else if([storiesArray count] + postDetailsObject.comments.count == indexPath.row)
    {
        static NSString *simpleTableIdentifier = @"DeleteCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
    
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setFrame:CGRectMake(0, 0, 320, 44)];
        [deleteButton setImage:[UIImage imageNamed:@"btn-delete.png"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:deleteButton];
        
        return cell;
    }
    else
    {
        static NSString *simpleTableIdentifier = @"CommentCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        
        
        //removes any subviews from the cell
        for(UIView *viw in [[cell contentView] subviews])
        {
            [viw removeFromSuperview];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

        
        PostDetails *postDetailsObject = [storiesArray lastObject];
        NSDictionary *commentDict = [postDetailsObject.comments objectAtIndex:indexPath.row - 1];
        
        [self buildCommentCell:commentDict :cell :indexPath];
        return cell;
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(void)buildCommentCell:(NSDictionary *)commentDict :(UITableViewCell *)cell :(NSIndexPath *)indexPath
{
    CGSize expectedLabelSize;
    
        UIImageView *imagVw = [[UIImageView alloc] initWithFrame:CGRectMake(16, 8, 28, 28)];
        [imagVw setImage:[UIImage imageNamed:@"circle-56.png"]];
    if(![[commentDict objectForKey:@"anonymous"] boolValue])
    {
    __weak UIImageView *weakSelf = imagVw;

        //add initials
        //NSString *nickname = [dict valueForKey:@"commented_by"];
        
        NSMutableString *parentFnameInitial = [[NSMutableString alloc] init];
        if([[commentDict objectForKey:@"commenter" ] valueForKey:@"fname"] != (id)[NSNull null] && [[[commentDict objectForKey:@"commenter" ] valueForKey:@"fname"] length] >0)
            [parentFnameInitial appendString:[[[[commentDict objectForKey:@"commenter" ] valueForKey:@"fname"] substringToIndex:1] uppercaseString]];
        if([[commentDict objectForKey:@"commenter" ] valueForKey:@"lname"] != (id)[NSNull null] && [[[commentDict objectForKey:@"commenter" ]  valueForKey:@"lname"] length]>0)
            [parentFnameInitial appendString:[[[[commentDict objectForKey:@"commenter" ] valueForKey:@"lname"] substringToIndex:1] uppercaseString]];
        

        
        NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:parentFnameInitial
                                               attributes:nil];
        NSRange range;
        if(parentFnameInitial.length > 0)
        {
            range.location = 0;
            range.length = 1;
            [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:14]}
                                    range:range];
        }
        if(parentFnameInitial.length > 1)
        {
            range.location = 1;
            range.length = 1;
            [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:14]}
                                    range:range];
        }
        
        
        //add initials
        
        UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        initial.attributedText = attributedText;
        [initial setBackgroundColor:[UIColor clearColor]];
        initial.textAlignment = NSTextAlignmentCenter;
        [imagVw addSubview:initial];

        
        NSString *url = [[commentDict objectForKey:@"commenter"] objectForKey:@"photo"];
        if(url != (id)[NSNull null] && url.length > 0)
        {
            // Fetch image, cache it, and add it to the tag.
            [imagVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 [photoUtils saveImageToCache:url :image];
                 
                 weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(28, 28)] withRadious:0];
                 [initial removeFromSuperview];
                 
             }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
             {
                 DebugLog(@"fail");
             }];
        }
    }
    else
    {
        __weak UIImageView *weakSelf = imagVw;
        
        //add initials
        //NSString *nickname = [dict valueForKey:@"commented_by"];
        
        NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:@"anonymous_image"];
        if(url != (id)[NSNull null] && url.length > 0)
        {
            // Fetch image, cache it, and add it to the tag.
            [imagVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 [photoUtils saveImageToCache:url :image];
                 
                 weakSelf.image = image;
                 
             }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
             {
                 DebugLog(@"fail");
             }];
        }

        

    }
    

        [cell.contentView addSubview:imagVw];
    
    
    
    UIButton *profileButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    //    profileButton1.tag = [[streamTableView indexPathForRowAtPoint:cell.center] row];
    profileButton1.tag = indexPath.row;
    [profileButton1 setFrame:imagVw.frame];
    [profileButton1 addTarget:self action:@selector(commentProfileButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:profileButton1];

    
        // NSString *temp = [[dict objectForKey:@"commenter"] objectForKey:@"fname"];
    
    
    UIImageView *heartCntImage  = [[UIImageView alloc] initWithFrame:CGRectMake(267, 15, 8, 12)];
    [heartCntImage setImage:[UIImage imageNamed:@"thumbsup_grey.png"]];

    [cell.contentView addSubview:heartCntImage];

    UILabel *upVoteCount = [[UILabel alloc] initWithFrame:CGRectMake(276,16.5,10,12)];
    [upVoteCount setBackgroundColor:[UIColor clearColor]];
    [upVoteCount setText:[NSString stringWithFormat:@"%i",[[commentDict objectForKey:@"upvote_count"] intValue] ]];
    [upVoteCount setFont:[UIFont fontWithName:@"SanFranciscoText-Light" size:12]];
    [upVoteCount setTextColor:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]];
    [upVoteCount setNumberOfLines:1];
    [upVoteCount setTextAlignment:NSTextAlignmentLeft];
    [cell.contentView addSubview:upVoteCount];

    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:[UIImage imageNamed:@"icon-more.png"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreClicked:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.frame = CGRectMake(280, 2, 40, 40);
    [moreButton setTag:[indexPath row]];
    [cell.contentView addSubview:moreButton];
    
    
        NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14]};
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[commentDict objectForKey:@"text"]   attributes:attributes];
    

    NIAttributedLabel *textView1 = [NIAttributedLabel new];
    textView1.numberOfLines = 0;
    textView1.font = [UIFont fontWithName:@"SanFranciscoText-Light" size:14];
    
    STTweetLabel *textView = [STTweetLabel new];

    
    textView.numberOfLines = 0;
    textView.attributedText = attributedString;
    textView1.attributedText = attributedString;

    expectedLabelSize = [textView1 sizeThatFits:CGSizeMake(205, 9999)];
    textView.frame =  CGRectMake(53, 12, 205, expectedLabelSize.height);
    [cell.contentView addSubview:textView];
    
    textView.detectionBlock = ^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
        
        if(hotWord == 1)
        {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            HashTagViewController *tagView = [mainStoryboard instantiateViewControllerWithIdentifier:@"HashTagViewController"];
            tagView.tagName = string;
            [self.navigationController pushViewController:tagView animated:YES];
            
            
        }
        else if(hotWord == 2)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
            
        }
    };
    
    
}
-(void)buildCell:(UITableViewCell *)cell withDetails:(PostDetails *)postDetailsObject :(NSIndexPath *)indexPath
{
    float yPosition = 6;
    

    
    //Profile Image
    UIImageView *profileImage  = [[UIImageView alloc] initWithFrame:CGRectMake(8, yPosition, 28, 28)];
    if(!postDetailsObject.anonymous)
    {
        __weak UIImageView *weakSelf = profileImage;
        
        NSMutableString *parentFnameInitial = [[NSMutableString alloc] init];
        if([postDetailsObject.owner valueForKey:@"fname"] != (id)[NSNull null] && [[postDetailsObject.owner valueForKey:@"fname"] length] >0)
            [parentFnameInitial appendString:[[[postDetailsObject.owner valueForKey:@"fname"] substringToIndex:1] uppercaseString]];
        if([postDetailsObject.owner valueForKey:@"lname"] != (id)[NSNull null] && [[postDetailsObject.owner valueForKey:@"lname"] length]>0)
            [parentFnameInitial appendString:[[[postDetailsObject.owner valueForKey:@"lname"] substringToIndex:1] uppercaseString]];
        

        NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:parentFnameInitial
                                               attributes:nil];
        NSRange range;
        if(parentFnameInitial.length > 0)
        {
            range.location = 0;
            range.length = 1;
            [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:14]}
                                    range:range];
        }
        if(parentFnameInitial.length > 1)
        {
            range.location = 1;
            range.length = 1;
            [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:14]}
                                    range:range];
        }
        
        
        //add initials
        
        UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        initial.attributedText = attributedText;
        [initial setBackgroundColor:[UIColor clearColor]];
        initial.textAlignment = NSTextAlignmentCenter;
        [profileImage addSubview:initial];

        
        [profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[postDetailsObject.owner objectForKey:@"photo"]]] placeholderImage:[UIImage imageNamed:@"circle-56.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             [initial removeFromSuperview];
             weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(28, 28)] withRadious:0];
             
         }failure:nil];
    }
    else
    {
        __weak UIImageView *weakSelf = profileImage;
        
        [profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"anonymous_image"]]] placeholderImage:[UIImage imageNamed:@"icon-profile-register.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             weakSelf.image = image;
             
         }failure:nil];

        
    }
    
    [cell.contentView addSubview:profileImage];
    
    //Profile name
    UILabel *name;
    if(!postDetailsObject.anonymous)
    {
   name = [[UILabel alloc] initWithFrame:CGRectMake(42, yPosition, 120, 28)];
    [name setText:[NSString stringWithFormat:@"%@ %@",[postDetailsObject.owner objectForKey:@"fname"],[postDetailsObject.owner objectForKey:@"lname"]]];
    [name setTextColor:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1.0]];
    [name setFont:[UIFont fontWithName:@"SanFranciscoText-Medium" size:16]];
    [cell.contentView addSubview:name];
        
        

    }
    else
    {
        name = [[UILabel alloc] initWithFrame:CGRectMake(42, yPosition, 120, 28)];
        [name setText:@"anonymous"];
        [name setTextColor:[UIColor grayColor]];
        [name setFont:[UIFont fontWithName:@"SanFranciscoText-Medium" size:16]];
        [cell.contentView addSubview:name];
    }
    
    
//    UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [profileButton addTarget:self action:@selector(profileButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    profileButton.tag = [[streamTableView indexPathForRowAtPoint:cell.center] row];
//    [profileButton setFrame:name.frame];
//    [cell.contentView addSubview:profileButton];
    
    UIButton *profileButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    //    profileButton1.tag = [[streamTableView indexPathForRowAtPoint:cell.center] row];
    profileButton1.tag = indexPath.row;
    [profileButton1 setFrame:profileImage.frame];
    [profileButton1 addTarget:self action:@selector(profileButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:profileButton1];

    
    UIButton *heartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [heartButton setImage:[UIImage imageNamed:@"thumbsup_grey.png"] forState:UIControlStateNormal];
    [heartButton setFrame:CGRectMake(204+68+4, 12, 9, 15)];
    [heartButton setTag:[indexPath row]];
    [cell.contentView addSubview:heartButton];
    
    UILabel *upVoteCount = [[UILabel alloc] initWithFrame:CGRectMake(222+65, 13, 20 , 18)];
    [upVoteCount setText:[NSString stringWithFormat:@"%i",postDetailsObject.upVoteCount]];
     [upVoteCount setTextColor:[UIColor colorWithRed:(153/255.f) green:(153/255.f) blue:(153/255.f) alpha:1]];
    [upVoteCount setFont:[UIFont fontWithName:@"SanFranciscoText-Light" size:10]];
    [cell.contentView addSubview:upVoteCount];
    

    
    UIImageView *viewsCntImage  = [[UIImageView alloc] initWithFrame:CGRectMake(162+68, 16, 22, 13)];
    [viewsCntImage setImage:[UIImage imageNamed:@"icon-view-count.png"]];
    [cell.contentView addSubview:viewsCntImage];
    
    UILabel *viewsCount = [[UILabel alloc] initWithFrame:CGRectMake(184+68, 13, 20, 18)];
    [viewsCount setText:postDetailsObject.time];
    [viewsCount setTextAlignment:NSTextAlignmentLeft];
    [viewsCount setText:[NSString stringWithFormat:@"%i",postDetailsObject.viewsCount]];
    [viewsCount setTextColor:[UIColor colorWithRed:(153/255.f) green:(153/255.f) blue:(153/255.f) alpha:1]];
    [viewsCount setFont:[UIFont fontWithName:@"SanFranciscoText-Light" size:10]];
    [cell.contentView addSubview:viewsCount];

    
    
    [self addDescription:cell withDetails:postDetailsObject :indexPath];
    
    
    
}
-(void)addDescription:(UITableViewCell *)cell withDetails:(PostDetails *)postDetailsObject :(NSIndexPath *)indexPath
{
    __block float yPosition = 45;
    
    UIImageView *lineImage  =[[UIImageView alloc] initWithFrame:CGRectMake(0, 39, 320, 1)];
    lineImage.backgroundColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1.0];
    [cell.contentView addSubview:lineImage];

    
    //Start of Description Text
    
    //Description
    
    NSString *str = [postDetailsObject.content stringByReplacingOccurrencesOfString:@"\n::" withString:@"::"];
    str = [str stringByReplacingOccurrencesOfString:@"::\n" withString:@"::"];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14],NSForegroundColorAttributeName:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1.0]}];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\::(.*?)\\::" options:NSRegularExpressionCaseInsensitive error:NULL];
    
    
    do{
        
        NSArray *myArray = [regex matchesInString:attributedString.string options:0 range:NSMakeRange(0, [attributedString.string length])] ;
        if(myArray.count > 0)
        {
            NSTextCheckingResult *match =  [myArray firstObject];
            NSRange matchRange = [match rangeAtIndex:1];
            
            UIImage  *image = [UIImage sd_animatedGIFNamed:@"Preloader_2"];
            NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
            image.accessibilityIdentifier = [postDetailsObject.large_images objectForKey:[attributedString.string substringWithRange:matchRange]];
            textAttachment.image = image;
            NSMutableAttributedString *attrStringWithImage = [[NSMutableAttributedString alloc] init];
            [attrStringWithImage appendAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
            
            [attributedString replaceCharactersInRange:match.range withAttributedString:attrStringWithImage];
        }
        else
        {
            break;
        }
        
    }while (1);
    //This regex captures all items between []
    
    [attributedString enumerateAttributesInRange:NSMakeRange(0, attributedString.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:
     ^(NSDictionary *attributes, NSRange attrRange, BOOL *stop)
     {
         
         NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
         
         NSTextAttachment *textAttachment1 = [mutableAttributes objectForKey:@"NSAttachment"];
         if(textAttachment1 != nil)
         {
             NSString *identifier = textAttachment1.image.accessibilityIdentifier;
             if (identifier!= nil)
             {
                 UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(144, yPosition+5+59, 32, 32)];
                 __weak UIImageView *weakImageView  = imageView;
                 UIImage *placeHolder  = [UIImage sd_animatedGIFNamed:@"Preloader_2"];
                 placeHolder.accessibilityIdentifier = identifier;
                 
                 UITapGestureRecognizer *oneTouch=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedTextView:)];
                 [oneTouch setNumberOfTouchesRequired:1];
                 [imageView addGestureRecognizer:oneTouch];
                 imageView.userInteractionEnabled = YES;
                 
                 if([identifier rangeOfString:@".gif" options:NSCaseInsensitiveSearch].location != NSNotFound)
                     
                 {
                     weakImageView.image = placeHolder;

                     UIImage *thumb = [photoUtils getGIFImageFromCache:identifier];
                     
                     if(thumb ==nil)
                     {
                         dispatch_queue_t myQueue = dispatch_queue_create("imageque",NULL);
                         dispatch_async(myQueue, ^{
                             NSData *data =  [NSData dataWithContentsOfURL:[NSURL URLWithString:identifier]];
                             UIImage *gif_image = [UIImage animatedImageWithAnimatedGIFData:data];
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 CGRect frame = weakImageView.frame;
                                 weakImageView.frame =  CGRectMake(10, frame.origin.y-59, 300, 150);
                                 [weakImageView setContentMode:UIViewContentModeRedraw];
                                 
                                 
                                 gif_image.accessibilityIdentifier = identifier;
                                 weakImageView.image  = gif_image;
                                 
                                 CATransition *transition = [CATransition animation];
                                 transition.duration = 1.0f;
                                 transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                 transition.type = kCATransitionFade;
                                 
                                 [weakImageView.layer addAnimation:transition forKey:nil];
                                 
                                 [photoUtils saveImageToCacheWithData:identifier :data];
                             });
                         });
                         

                     }
                     else
                     {
                         CGRect frame = weakImageView.frame;
                         weakImageView.frame =  CGRectMake(10, frame.origin.y-59, 300, 150);
                         [weakImageView setContentMode:UIViewContentModeRedraw];
                         
                         
                         thumb.accessibilityIdentifier = identifier;
                         weakImageView.image  = thumb;
                         
                         CATransition *transition = [CATransition animation];
                         transition.duration = 1.0f;
                         transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                         transition.type = kCATransitionFade;
                         
                         [weakImageView.layer addAnimation:transition forKey:nil];

                     }
                     
                 }
                 else
                 {
                 [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:identifier]] placeholderImage:placeHolder success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                     
                     CGRect frame = weakImageView.frame;
                     weakImageView.frame =  CGRectMake(10, frame.origin.y-59, 300, 150);
                     
                     image = [image resizedImageByMagick:@"300x150#"];
                     image.accessibilityIdentifier = identifier;
                     weakImageView.image  = image;
                     
                     CATransition *transition = [CATransition animation];
                     transition.duration = 1.0f;
                     transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                     transition.type = kCATransitionFade;
                     
                     [weakImageView.layer addAnimation:transition forKey:nil];
                     

                     
                 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                      
                 }];
                 }
                 [cell.contentView addSubview:imageView];
                 yPosition += 150+10;
                 
             }
         }
         else
         {
             NIAttributedLabel *textView1 = [NIAttributedLabel new];
             textView1.numberOfLines = 0;
             textView1.font = [UIFont fontWithName:@"SanFranciscoText-Light" size:14];
             textView1.text = [attributedString.string substringWithRange:attrRange];

             STTweetLabel *textView = [STTweetLabel new];
            
             textView.numberOfLines = 0;
             textView.font = [UIFont fontWithName:@"SanFranciscoText-Light" size:14];
             textView.text = [attributedString.string substringWithRange:attrRange];
             CGSize contentSize = [textView1 sizeThatFits:CGSizeMake(300, CGFLOAT_MAX)];
             textView.frame = CGRectMake(10, yPosition, 300, contentSize.height);
             [cell.contentView addSubview:textView];
             yPosition += contentSize.height;

             textView.detectionBlock = ^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
                 
                 if(hotWord == 1)
                 {
                     UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                     HashTagViewController *tagView = [mainStoryboard instantiateViewControllerWithIdentifier:@"HashTagViewController"];
                     tagView.tagName = string;
                     [self.navigationController pushViewController:tagView animated:YES];

                     
                 }
                 else if(hotWord == 2)
                 {
                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
                     
                 }
             };
             
         }
         
     }];

    
    
    //Tags

    UIView *tagsView = [[UIView alloc] initWithFrame:CGRectMake(15, yPosition+5, 220, 30)];
    [cell.contentView addSubview:tagsView];
    NSArray *tagsArray = postDetailsObject.tags;
    int xPosition =0, y = 6;
    for(int i=0; i <tagsArray.count ;i++)
    {
        NSString *tagNameStr = tagsArray[i];
        CGSize size = [tagNameStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
        
        if(size.width + xPosition >= 220)
        {
            xPosition = 0;
            y += 26;
            i --;
            continue;
        }
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
        btn.layer.borderColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1.0].CGColor;
        btn.layer.borderWidth = 1.0f;
        btn.layer.cornerRadius = 5;
        btn.layer.masksToBounds = YES;
        [btn setTitle:tagNameStr forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont fontWithName:@"SanFranciscoText-Light" size:10]];
        [btn addTarget:self action:@selector(tagClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
        [tagsView addSubview:btn];
        btn.frame = CGRectMake(xPosition, y, size.width, 20);
        
        xPosition += btn.frame.size.width + 3;
        
    }
    
    if(y+26 > 32)
    {
        CGRect frame = tagsView.frame;
        frame.size.height = y+26+6;
        tagsView.frame = frame;
    }
    
    
/*
        NSMutableArray *tagarray = [[NSMutableArray alloc] init];
        for(NSString *tag in postDetailsObject.tags)
            [tagarray addObject:[NSString stringWithFormat:@"%@",tag]];

        
            NSAttributedString *tagsStr = [[NSAttributedString alloc] initWithString:[tagarray componentsJoinedByString:@" "] attributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:15.0],NSForegroundColorAttributeName:[UIColor blackColor]}];
            CGSize tagsSize = [tagsStr boundingRectWithSize:CGSizeMake(220, CGFLOAT_MAX)
                                                    options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                    context:nil].size;
            
            STTweetLabel *tweetLabel = [[STTweetLabel alloc] initWithFrame:CGRectMake(10, yPosition, 220 , tagsSize.height)];
            [tweetLabel setText:tagsStr.string];
            tweetLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:tweetLabel];
            
            [tweetLabel setDetectionBlock:^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
                
               [self tagCicked:[string stringByReplacingOccurrencesOfString:@"#" withString:@""]];
            }];
            
           //yPosition += tagsSize.height+10;
    */


    if([postDetailsObject.can containsObject:@"flag"])
    {
    UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [flagButton setImage:[UIImage imageNamed:@"icon-flag.png"] forState:UIControlStateNormal];
    [flagButton setFrame:CGRectMake(240, yPosition+6, 28, 28)];
    [flagButton setTag:[indexPath row]];
    [flagButton addTarget:self action:@selector(flagButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:flagButton];
    }
    UIButton *heartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if(postDetailsObject.upvoted)
    {
        [heartButton setFrame:CGRectMake(278, yPosition, 28, 35)];
        [heartButton setImage:[UIImage imageNamed:@"thumbsup.png"] forState:UIControlStateNormal];
    }
    else
    {
        [heartButton setFrame:CGRectMake(278, yPosition+4, 28, 35)];
        [heartButton setImage:[UIImage imageNamed:@"fist.png"] forState:UIControlStateNormal];
    }
    [heartButton setTag:[indexPath row]];
    [heartButton addTarget:self action:@selector(heartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:heartButton];

    yPosition += 40;

}
-(void)tagClicked:(id)sender
{
    UIButton *btn = sender;
    [self tagCicked:[btn titleForState:UIControlStateNormal]];
    
}
-(void)profileButtonClicked:(id)sender
{
    // Resrict the anonymous users
    PostDetails *postObject = [storiesArray lastObject];
    if (!postObject.anonymous)
    {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        UserProfileViewCotroller *destViewController = (UserProfileViewCotroller*)[mainStoryboard
                                                                  instantiateViewControllerWithIdentifier: @"UserProfileViewCotroller"];
        destViewController.photo = [postObject.owner objectForKey:@"photo"];
        destViewController.name = [NSString stringWithFormat:@"%@ %@",[postObject.owner objectForKey:@"fname"],[postObject.owner objectForKey:@"lname"]];
        destViewController.imageUrl = [postObject.owner objectForKey:@"photo"];

        destViewController.profileId = [postObject.owner objectForKey:@"uid"];
        [self.navigationController pushViewController:destViewController animated:YES];

    }
}

-(void)commentProfileButtonClicked:(id)sender
{
    // Resrict the anonymous users
    PostDetails *post = [storiesArray lastObject];
    NSDictionary * commentDict = [post.comments objectAtIndex:[sender tag]-1];

    if (![[commentDict objectForKey:@"anonymous"] boolValue])
    {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        UserProfileViewCotroller *destViewController = (UserProfileViewCotroller*)[mainStoryboard
                                                                                   instantiateViewControllerWithIdentifier: @"UserProfileViewCotroller"];
        destViewController.photo = [[commentDict objectForKey:@"commenter"] objectForKey:@"photo"];
        destViewController.name = [NSString stringWithFormat:@"%@ %@",[[commentDict objectForKey:@"commenter"] objectForKey:@"fname"],[[commentDict objectForKey:@"commenter"] objectForKey:@"lname"]];
        destViewController.imageUrl = [[commentDict objectForKey:@"commenter"] objectForKey:@"photo"];

        destViewController.profileId = [[commentDict objectForKey:@"commenter"] objectForKey:@"uid"];
        [self.navigationController pushViewController:destViewController animated:YES];
        
        
    }
}

#pragma mark -
#pragma mark Comment Methods
-(void)anonymousCommentClicked:(id)sender
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    {
        if([[self  timerHomepage] isValid])
            [[self  timerHomepage] invalidate];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = [(UIButton *)sender frame];
    frame.origin.y = self.commentView.frame.origin.y+4;
    btn.frame = frame;
        
        popView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];

        if(isAnonymous)
        {
            UILabel *postAsLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
            [postAsLabel1 setTextAlignment:NSTextAlignmentRight];
            [postAsLabel1 setTextColor:[UIColor colorWithRed:76/255.0 green:121/255.0 blue:251/255.0 alpha:1.0]];
            [postAsLabel1 setFont:[UIFont fontWithName:@"SanFranciscoText-Light" size:14]];
            [popView addSubview:postAsLabel1];
            
           
            if(sharedModel.userProfile.fname.length > 0 && sharedModel.userProfile.lname.length > 0)
                    [postAsLabel1 setText:[NSString stringWithFormat:@"Advice as %@ %@",sharedModel.userProfile.fname,sharedModel.userProfile.lname]];
            else if(sharedModel.userProfile.fname.length > 0)
                    [postAsLabel1 setText:[NSString stringWithFormat:@"Advice as %@",sharedModel.userProfile.fname]];
            else if(sharedModel.userProfile.lname.length > 0)
                    [postAsLabel1 setText:[NSString stringWithFormat:@"Advice as %@",sharedModel.userProfile.lname]];
            else if(sharedModel.userProfile.handle.length > 0)
                postAsLabel1.text = [NSString stringWithFormat:@"Advice as %@",sharedModel.userProfile.handle];
            else if(sharedModel.userProfile.email.length > 0)
                postAsLabel1.text = [NSString stringWithFormat:@"Advice as %@",sharedModel.userProfile.email];
            else if(sharedModel.userProfile.phno.length > 0)
                postAsLabel1.text = [NSString stringWithFormat:@"Advice as %@",sharedModel.userProfile.phno];

            
            UIImageView *userImage = [[UIImageView alloc] initWithFrame:CGRectMake(210, 7, 24, 24)];
            
            __weak UIImageView *weakSelf1 = userImage;
            __weak ProfilePhotoUtils *weakphotoUtils1 = photoUtils;
            
            NSMutableString *parentFnameInitial = [[NSMutableString alloc] init];
            if( [sharedModel.userProfile.fname length] >0)
                [parentFnameInitial appendString:[[sharedModel.userProfile.fname substringToIndex:1] uppercaseString]];
            if( [sharedModel.userProfile.lname length] >0)
                [parentFnameInitial appendString:[[sharedModel.userProfile.lname substringToIndex:1] uppercaseString]];
            
            if(parentFnameInitial.length < 1)
            {
                if( [sharedModel.userProfile.handle length] >0)
                    [parentFnameInitial appendString:[[sharedModel.userProfile.handle substringToIndex:1] uppercaseString]];
                if( [sharedModel.userProfile.handle length] >1)
                    [parentFnameInitial appendString:[[sharedModel.userProfile.handle substringWithRange:NSMakeRange(1, 1)] uppercaseString]];
                
            }

            
            NSMutableAttributedString *attributedText =
            [[NSMutableAttributedString alloc] initWithString:parentFnameInitial
                                                   attributes:nil];
            NSRange range;
            if(parentFnameInitial.length > 0)
            {
                range.location = 0;
                range.length = 1;
                [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:14]}
                                        range:range];
            }
            if(parentFnameInitial.length > 1)
            {
                range.location = 1;
                range.length = 1;
                [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:14]}
                                        range:range];
            }
            
            
            //add initials
            
            UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
            initial.attributedText = attributedText;
            [initial setBackgroundColor:[UIColor clearColor]];
            initial.textAlignment = NSTextAlignmentCenter;
            [userImage addSubview:initial];

            
            [userImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:sharedModel.userProfile.image]] placeholderImage:[UIImage imageNamed:@"circle-80.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 weakSelf1.image = [weakphotoUtils1 makeRoundWithBoarder:[weakphotoUtils1 squareImageWithImage:image scaledToSize:CGSizeMake(24, 24)] withRadious:0];
                 [initial removeFromSuperview];
                 
             }failure:nil];
            [popView addSubview:userImage];
            
            UIButton *postBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            postBtn.frame = CGRectMake(0, 0, 300, 40);
            [postBtn addTarget:self action:@selector(commentClicked:) forControlEvents:UIControlEventTouchUpInside];
            [popView addSubview:postBtn];

        }
        else
        {
            UILabel *postAsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 260, 40)];
            [postAsLabel setText:@"Advice as anonymous"];
            [postAsLabel setTextAlignment:NSTextAlignmentCenter];
            [postAsLabel setTextColor:[UIColor colorWithRed:76/255.0 green:121/255.0 blue:251/255.0 alpha:1.0]];
            [postAsLabel setFont:[UIFont fontWithName:@"SanFranciscoText-Light" size:16]];
            [popView addSubview:postAsLabel];
            
            UIImageView *anonymusImage = [[UIImageView alloc] initWithFrame:CGRectMake(220, 5, 30, 30)];
            [anonymusImage setImage:[UIImage imageNamed:@"anamous.png"]];
            [popView addSubview:anonymusImage];
            
            UIButton *postBtnAnonymous = [UIButton buttonWithType:UIButtonTypeCustom];
            postBtnAnonymous.frame = CGRectMake(0, 0, 300, 40);
            [postBtnAnonymous addTarget:self action:@selector(commentAsAnonymous) forControlEvents:UIControlEventTouchUpInside];
            [popView addSubview:postBtnAnonymous];

        }
        
        
    [popover showAtView:btn withContentView:popView inView:self.view];
    }
    else
    {
        [self gotoLoginScreen];
    }
    
}
-(void)commentAsAnonymous
{
    for(UIView *viw in [postAnonymous subviews])
    {
        [viw removeFromSuperview];
    }
    [popover dismiss];
    isAnonymous = YES;
    postAnonymous.image = [UIImage imageNamed:@"anamous.png"];
}
-(void)PostDeletedFromEditPostDetails
{
    [self.delegate PostDeletedFromPostDetails];
}
-(void)commentClicked:(id)sender
{
    [popover dismiss];
    isAnonymous = NO;
    __weak UIImageView *weakSelf = postAnonymous;
    __weak ProfilePhotoUtils *weakphotoUtils = photoUtils;
    
    NSMutableString *parentFnameInitial = [[NSMutableString alloc] init];
    if( [sharedModel.userProfile.fname length] >0)
        [parentFnameInitial appendString:[[sharedModel.userProfile.fname substringToIndex:1] uppercaseString]];
    if( [sharedModel.userProfile.lname length] >0)
        [parentFnameInitial appendString:[[sharedModel.userProfile.lname substringToIndex:1] uppercaseString]];
    
    if(parentFnameInitial.length < 1)
    {
        if( [sharedModel.userProfile.handle length] >0)
            [parentFnameInitial appendString:[[sharedModel.userProfile.handle substringToIndex:1] uppercaseString]];
        if( [sharedModel.userProfile.handle length] >1)
            [parentFnameInitial appendString:[[sharedModel.userProfile.handle substringWithRange:NSMakeRange(1, 1)] uppercaseString]];
    }
    
    
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:parentFnameInitial
                                           attributes:nil];
    NSRange range;
    if(parentFnameInitial.length > 0)
    {
        range.location = 0;
        range.length = 1;
        [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:13]}
                                range:range];
    }
    if(parentFnameInitial.length > 1)
    {
        range.location = 1;
        range.length = 1;
        [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:13]}
                                range:range];
    }
    
    
    //add initials
    
    UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    initial.attributedText = attributedText;
    [initial setBackgroundColor:[UIColor clearColor]];
    initial.textAlignment = NSTextAlignmentCenter;
    [postAnonymous addSubview:initial];

    
    [postAnonymous setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:sharedModel.userProfile.image]] placeholderImage:[UIImage imageNamed:@"circle-80.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf.image = [weakphotoUtils makeRoundWithBoarder:[weakphotoUtils squareImageWithImage:image scaledToSize:CGSizeMake(25, 25)] withRadious:0];
         [initial removeFromSuperview];
         
     }failure:nil];
    isAnonymous = NO;
}
-(void)callCommentApi
{
    PostDetails *postDetls = [storiesArray lastObject];

    if(!postDetls.uid)
    {
        return;
    }
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    {
        [self gotoLoginScreen];
        return;
        
    }
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    if(self.txt_comment.text.length ==  0 || ([[self.txt_comment.text stringByTrimmingCharactersInSet: set] length] == 0))
    {
        ShowAlert(PROJECT_NAME, @"Please enter comment", @"OK");
        return;
    }
    
    //Invalidate the timer
    if([[self  timerHomepage] isValid])
        [[self  timerHomepage] invalidate];


    
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            postID, @"post_uid",
                            nil];
    
   // [Flurry logEvent:@"post_comment" withParameters:params timed:YES];

    
    [appDelegate showOrhideIndicator:YES];
    
    
    AccessToken* token = sharedModel.accessToken;
    
    NSDictionary* postData = @{@"command": @"create",@"access_token": token.access_token,@"body":@{@"post_id":postDetls.uid,@"text":self.txt_comment.text,@"anonymous":[NSNumber numberWithBool:isAnonymous]}};
    NSDictionary *userInfo = @{@"command": @"Comment"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@comments",BASE_URL];
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
    [self.txt_comment resignFirstResponder];
    streamTableView.frame = originalPostion;
    
    

}
-(void) commentSuccessful:(NSDictionary *)recievedDict
{
    [appDelegate showOrhideIndicator:NO];
    
    PostDetails *postDetls = [storiesArray lastObject];
    NSMutableArray *commentsArray = [postDetls.comments mutableCopy];
    if(commentsArray == nil)
        commentsArray = [[NSMutableArray alloc] init];
    [commentsArray insertObject:recievedDict atIndex:0];
    postDetls.comments = commentsArray;
    [storiesArray replaceObjectAtIndex:0 withObject:postDetls];
    [streamTableView reloadData];
    self.txt_comment.text = @"";
    [self.txt_comment addSubview:placeholderLabel];
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"share"];
    if(dict != nil)
    {
        if([[dict objectForKey:@"fb"] boolValue])
        {
            [self shareToFB];
        }
    }

}
-(void) commentFailed
{
    self.txt_comment.text = @"";
    [self.txt_comment addSubview:placeholderLabel];
    [appDelegate showOrhideIndicator:NO];
}
-(void)follow:(id)sender
{
    
}

#pragma Cell Height
-(CGFloat)cellHeight:(PostDetails *)postDetailsObject
{
    //This default image height + 5 pixels up and 5 pixels down margin
    CGFloat height = 5;
    
    //Calculating content height
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\::(.*?)\\::" options:NSRegularExpressionCaseInsensitive error:NULL];
    
    
    float height1 = 0;
    
    NSString *str = [postDetailsObject.content stringByReplacingOccurrencesOfString:@"\n::" withString:@"::"];
    str = [str stringByReplacingOccurrencesOfString:@"::\n" withString:@"::"];
        NSArray *myArray = [regex matchesInString:str options:0 range:NSMakeRange(0, [str length])] ;
    
        if(myArray.count > 0)
        {
            NSString *modifiedString = [regex stringByReplacingMatchesInString:str options:0 range:NSMakeRange(0, [str length]) withTemplate:@"@:@:"];
            NSArray *stringarray = [modifiedString componentsSeparatedByString:@"@:@:"];
            
            for(NSString *str in stringarray)
            {
                if(str.length > 0)
                {
                NIAttributedLabel *textView = [NIAttributedLabel new];
                textView.numberOfLines = 0;
                textView.font = [UIFont fontWithName:@"SanFranciscoText-Light" size:14];
                textView.text = str;
                CGSize contentSize = [textView sizeThatFits:CGSizeMake(300, CGFLOAT_MAX)];
                height1 += contentSize.height;
                }
            }
            
            height1 += myArray.count * 150 + myArray.count*10;
            
        }
        else
        {

            NIAttributedLabel *textView = [NIAttributedLabel new];
            textView.numberOfLines = 0;
            textView.font = [UIFont fontWithName:@"SanFranciscoText-Light" size:14];
            textView.text = str;
            CGSize contentSize = [textView sizeThatFits:CGSizeMake(300, CGFLOAT_MAX)];
            height1 = contentSize.height ;

        }
    
    height = 45 + height1;

    
    NSArray *tagsArray = postDetailsObject.tags;
    int xPosition =0, y = 6;
    for(int i=0; i <tagsArray.count ;i++)
    {
        NSString *tagNameStr = tagsArray[i];
        CGSize size = [tagNameStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
        
        if(size.width + xPosition >= 220)
        {
            xPosition = 0;
            y += 26;
            i --;
            continue;
        }
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
        btn.layer.borderColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1.0].CGColor;
        btn.layer.borderWidth = 1.0f;
        btn.layer.cornerRadius = 5;
        btn.layer.masksToBounds = YES;
        [btn setTitle:tagNameStr forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont fontWithName:@"SanFranciscoText-Light" size:10]];
        [btn addTarget:self action:@selector(tagClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:[UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1.0] forState:UIControlStateNormal];
        btn.frame = CGRectMake(xPosition, y, size.width, 20);
        
        xPosition += btn.frame.size.width + 3;
        
    }
    
    if(y+26 > 32)
    {
        height += y+26 + 6;
    }
    else
    {
        height += 40;
    }
    
    
    //Tags height
    return height;
}

-(CGFloat)cellHeightForComment:(int )row
{
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:@"SanFranciscoText-Light" size:14]};
    
    PostDetails *postDetails = [storiesArray lastObject];
    NSArray *commentsArray = postDetails.comments;
    NSDictionary *commentDict = [commentsArray objectAtIndex:row];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[commentDict objectForKey:@"text"]   attributes:attributes];
    
    NIAttributedLabel *textView = [NIAttributedLabel new];
    textView.numberOfLines = 0;
    textView.attributedText = attributedString;
    CGSize expectedLabelSize = [textView sizeThatFits:CGSizeMake(205, 9999)];
    
    
    CGFloat height =0;
    if(expectedLabelSize.height+12 > 44) //if there is a lot of text
    {
        height+=expectedLabelSize.height+12+12;
    }
    else //set a default size
    {
        height+=44;
    }
    return height;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            // More button is pressed
            UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Share on Twitter", nil];
            [shareActionSheet showInView:self.view];
            
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 1:
        {
            // Delete button is pressed
            break;
        }
        default:
            break;
    }
}


//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.commentView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.commentView.frame = containerFrame;
    
    
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.commentView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.commentView.frame = containerFrame;
    
    
    // commit animations
    [UIView commitAnimations];
    
    streamTableView.frame = originalPostion;
}


#pragma mark -
#pragma mark TextView Delegate Methods
- (void)textViewDidBeginEditing:(UITextView *)textView1
{
    [placeholderLabel removeFromSuperview];
    [textView1 setInputAccessoryView:inputView];
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView1
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    {
        [textView1 setInputAccessoryView:inputView];
        [placeholderLabel removeFromSuperview];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        
        
        DebugLog(@"postID:%@",postID);
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];

        return YES;

    }
    else
    {
        [self gotoLoginScreen];
        return NO;
    }
    
}
- (void)textViewDidEndEditing:(UITextView *)txtView
{
    if (![txtView hasText])
        [txtView addSubview:placeholderLabel];
}
- (void)textViewDidChange:(UITextView *)textView1
{
    if(![textView1 hasText])
    {
        [textView1 addSubview:placeholderLabel];
    }
    else if ([[textView1 subviews] containsObject:placeholderLabel])
    {
        [placeholderLabel removeFromSuperview];
        
    }
    
}

-(void)textChangedCustomEvent
{
    [placeholderLabel removeFromSuperview];
    
}

#pragma mark -
#pragma mark Heart Button Actions
-(void)heartButtonClicked:(id)sender
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    {
        //Invalidate the timer
        if([[self  timerHomepage] isValid])
            [[self  timerHomepage] invalidate];

    [appDelegate showOrhideIndicator:YES];
    AccessToken* token = sharedModel.accessToken;
    
    NSDictionary* postData;
    PostDetails *postDetails = [storiesArray lastObject];
    
    if(postDetails.upvoted)
    {
        postDetails.upvoted = NO;
        postDetails.upVoteCount -= 1;
        postData = @{@"command": @"undoVoting",@"access_token": token.access_token};
    }
    else
    {
        postDetails.upvoted = YES;
        postDetails.upVoteCount += 1;
        postData = @{@"command": @"upvote",@"access_token": token.access_token};
    }
    NSDictionary *userInfo = @{@"command": @"hearting"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@posts/%@",BASE_URL,postID];
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
   
    [storiesArray replaceObjectAtIndex:0 withObject:postDetails];
    [streamTableView reloadData];
    }
    else
    {
        [self gotoLoginScreen];
    }

}
-(void) heartingSuccessFull:(NSDictionary *)recievedDict
{
    [appDelegate showOrhideIndicator:NO];
    PostDetails *postDetails = [storiesArray lastObject];
    if(postDetails.upvoted)
    {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"share"];
    if(dict != nil)
    {
        int value = [[dict objectForKey:@"sliderValue"] intValue];
        if([[dict objectForKey:@"fb"] boolValue] && value >= 2)
        {
            [self shareToFB];
        }
    }
    }
}
-(void) heartingFailed
{
     [appDelegate showOrhideIndicator:NO];
}

-(void) PostEdited:(PostDetails *)postDetails
{
    [storiesArray replaceObjectAtIndex:0 withObject:postDetails];
    [streamTableView reloadData];
}
#pragma mark -
#pragma mark Delete Methods
-(void)deleteButtonClicked
{
    UIAlertView *cautionAlert = [[UIAlertView alloc]initWithTitle:@"Sure you want to delete this post?" message:@"" delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel", nil];
    cautionAlert.tag = 1;
    [cautionAlert show];
    

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        if (buttonIndex == 0)
        {
            // Delete
            //Invalidate the timer
            if([[self  timerHomepage] isValid])
                [[self  timerHomepage] invalidate];

            [appDelegate showOrhideIndicator:YES];
            AccessToken* token = sharedModel.accessToken;
            
            NSDictionary *postData = @{@"command": @"destroy",@"access_token": token.access_token};
            NSDictionary *userInfo = @{@"command": @"deletePost"};
            
            NSString *urlAsString = [NSString stringWithFormat:@"%@posts/%@",BASE_URL,postID];
            [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
        }
        else if (buttonIndex == 1)
        {
            // Cancel
        }
    }
    

}
-(void) postDeleteSuccessFull:(NSDictionary *)recievedDict
{
    [appDelegate showOrhideIndicator:NO];
    [self.delegate PostDeletedFromPostDetails];
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(void) postDeleteFailed
{
    [appDelegate showOrhideIndicator:NO];
}

-(void)gotoLoginScreen
{
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewLoginViewController *login = [mainStoryboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
    
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
-(void)CommentEdited:(NSDictionary *)commentDetails
{
    PostDetails *postDetails = [storiesArray lastObject];
    [postDetails.comments replaceObjectAtIndex:commentIndex withObject:commentDetails];
    [storiesArray replaceObjectAtIndex:0 withObject:postDetails];
    [streamTableView reloadData];
}
#pragma mark -
#pragma mark More Options In Comment
-(void)moreClicked:(id)sender
{
    PostDetails *post = [storiesArray lastObject];
    NSDictionary * commentDict = [post.comments objectAtIndex:[sender tag]-1];
    commentIndex = [sender tag]-1;
    
    UIActionSheet *addImageActionSheet = [[UIActionSheet alloc] init];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    {
    if([[commentDict objectForKey:@"upvoted"] boolValue])
    {
        [addImageActionSheet addButtonWithTitle:@"Undo Like"];
    }
    else
    {
        [addImageActionSheet addButtonWithTitle:@"Like"];
        
        if([[commentDict objectForKey:@"can"] containsObject:@"edit"])
            [addImageActionSheet addButtonWithTitle:@"Edit"];
        
        
    }
    if([[commentDict objectForKey:@"can"] containsObject:@"flag"])
        [addImageActionSheet addButtonWithTitle:@"Flag"];
    
    }
        [addImageActionSheet addButtonWithTitle:@"Share"];

    addImageActionSheet.cancelButtonIndex = [addImageActionSheet addButtonWithTitle:@"Cancel"];
    
    addImageActionSheet.tag = 1;
    [addImageActionSheet setDelegate:self];
    [addImageActionSheet showInView:[UIApplication sharedApplication].keyWindow];

    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 1)
    {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Like"])
    {
        [self CommentUpVote];
    }
    else if(([title isEqualToString:@"Undo Like"]))
    {
        [self CommentUpVote];
    }
    else if([title isEqualToString:@"Flag"])
    {
        PostDetails *postDetails = [storiesArray lastObject];
        NSMutableDictionary * commentDict = [[postDetails.comments objectAtIndex:commentIndex] mutableCopy];
        NSString *itemDate = [commentDict objectForKey:@"createdAt"];
        NSString *itemId = [commentDict objectForKey:@"uid"];
        NSString *emailId = [NSString stringWithFormat:@"%@", itemId];
        NSString *emailIdBase64 = [emailId base64EncodedString];
        //NSString *emailIdCipher = [CustomCipher encrypt:emailIdBase64];
        
        NSString *bodyText = [NSString stringWithFormat:@"Dear Same Pinch,\r\n\r\nPlease review the content for a comment dated %@ for inappropriate content.\r\n\r\n[So we can identify the content, please do not change the text between the two lines below, which represents the unique identifier for the content.  However, feel free to provide additional information above these lines for our review.]\r\n\r\n---------------------\r\n%@\r\n---------------------",itemDate, emailIdBase64];
        
        NSMutableDictionary *emailData = [[NSMutableDictionary alloc] init];
        [emailData setValue:@"Inappropriate content" forKey:@"subject"];
        [emailData setValue:bodyText forKey:@"body"];
        [self sendInappropriateEmail:emailData];

    }
    else if([title isEqualToString:@"Edit"])
    {
        [self performSegueWithIdentifier: @"EditComment" sender: self];
    }
        
    else if([title isEqualToString:@"Share"])
    {
        [self getShareUrl];
    }
        
    }
    else if(actionSheet.tag == 2)
    {
        if(buttonIndex != actionSheet.cancelButtonIndex)
        {
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                    postID, @"post_uid",
                                    nil];
            
           // [Flurry logEvent:@"post_share" withParameters:params timed:YES];
            
        }
        
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"Share on Facebook"])
        {
            [self shareToFB];
        }
        else if([title isEqualToString:@"Share by Email"])
        {
            [self shareMailComposerSheet];
        }
        else if([title isEqualToString:@"Share by SMS"])
        {
            [self showSMS];
        }
        else if([title isEqualToString:@"Share on WhatsApp"])
        {
            PostDetails *post = [storiesArray lastObject];
            NSString * msg = post.url;

            msg = [msg stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
            msg = [msg stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
            msg = [msg stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
            msg = [msg stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
            msg = [msg stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
            msg = [msg stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];

            NSURL *whatsappURL = [NSURL URLWithString:[NSString stringWithFormat:@"whatsapp://send?text=%@",msg]];
            if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
                [[UIApplication sharedApplication] openURL: whatsappURL];
            }
            else
            {
                UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"WhatsApp not installed" message:@"Please install WhatsApp to share the post" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [warningAlert show];
                return;

            }
        }
        else if([title isEqualToString:@"Copy Link"])
        {
            PostDetails *post = [storiesArray lastObject];
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.URL = [NSURL URLWithString:post.url];

        }
        

    }
    else if(actionSheet.tag == 3)
    {
     /*   NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"Invite by FB"])
        {
            FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
            NSString *iTunesLink = @"https://fb.me/546766048829450";

            content.appLinkURL = [NSURL URLWithString:iTunesLink];
            //optionally set previewImageURL
           // content.appInvitePreviewImageURL = [NSURL URLWithString:@"https://www.mydomain.com/my_invite_image.jpg"];
            
            // Present the dialog. Assumes self is a view controller
            // which implements the protocol `FBSDKAppInviteDialogDelegate`.
            [FBSDKAppInviteDialog showWithContent:content delegate:self];

        }
      */
    }
}
/*- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results
{
    
}
- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error
{
    
}
 */
-(void)CommentUpVote
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    {
        
        //Invalidate the timer
        if([[self  timerHomepage] isValid])
            [[self  timerHomepage] invalidate];

        [appDelegate showOrhideIndicator:YES];
        AccessToken* token = sharedModel.accessToken;
        
        NSDictionary* postData;
        PostDetails *postDetails = [storiesArray lastObject];
        NSMutableDictionary * commentDict = [[postDetails.comments objectAtIndex:commentIndex] mutableCopy];
        if([[commentDict objectForKey:@"upvoted"] boolValue])
        {

            postData = @{@"command": @"undoVoting",@"access_token": token.access_token};
        }
        else
        {
            postData = @{@"command": @"upvote",@"access_token": token.access_token};
        }
        
        
        NSDictionary *userInfo = @{@"command": @"commentUpvote"};
        NSString *urlAsString = [NSString stringWithFormat:@"%@comments/%@",BASE_URL,[commentDict objectForKey:@"uid"]];
        [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
    }
    else
    {
        [self gotoLoginScreen];
    }
    
}
-(void) commentUpVoteSuccessFull:(NSDictionary *)recievedDict
{
    PostDetails *postDetails = [storiesArray lastObject];
    [postDetails.comments replaceObjectAtIndex:commentIndex withObject:recievedDict];
    [storiesArray replaceObjectAtIndex:0 withObject:postDetails];
    [streamTableView reloadData];
    [appDelegate showOrhideIndicator:NO];
    if([[recievedDict objectForKey:@"upvoted"] boolValue])
    {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"share"];
    if(dict != nil)
    {
        int value = [[dict objectForKey:@"sliderValue"] intValue];
        if([[dict objectForKey:@"fb"] boolValue] && value >= 2)
        {
            [self shareToFB];
        }
    }
    }
    
}
-(void) commentUpVoteFailed
{
    [appDelegate showOrhideIndicator:NO];
}

#pragma mark -
#pragma mark Post Flag
-(void)flagButtonClicked:(id)sender
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    {
        PostDetails *postDetails = [self.storiesArray lastObject];
        NSString *itemDate = postDetails.time;
        NSString *itemId = postID;
        
        NSString *bodyText = [NSString stringWithFormat:@"Dear Same Pinch,\r\n\r\nPlease review the content for a post item dated %@ for inappropriate content.\r\n\r\n[So we can identify the content, please do not change the text between the two lines below, which represents the unique identifier for the content.  However, feel free to provide additional information above these lines for our review.]\r\n\r\n---------------------\r\n%@\r\n---------------------",itemDate, itemId];
        
        NSMutableDictionary *emailData = [[NSMutableDictionary alloc] init];
        [emailData setValue:@"Inappropriate content" forKey:@"subject"];
        [emailData setValue:bodyText forKey:@"body"];
        [self sendInappropriateEmail:emailData];
        
    }    else
        [self gotoLoginScreen];
}
#
#pragma mark - 
#pragma mark Flag Methods
- (void)showSMS
{
    
    if(![MFMessageComposeViewController canSendText])
    {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    PostDetails *post = [storiesArray lastObject];
    [appDelegate showOrhideIndicator:YES];
    
    NSString *message =  shareUrl;
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:^{ [appDelegate showOrhideIndicator:NO];}];
}

//This method is called when a button is clicked in the native send SMS popup
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result)
    {
        case MessageComposeResultCancelled:
        {
        }
            break;
            
        case MessageComposeResultFailed:
        {
            break;
        }
            
        case MessageComposeResultSent:
        {
            //calling sms confirmation api
        }
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)shareMailComposerSheet
{
    if([MFMailComposeViewController canSendMail])
    {
        [appDelegate showOrhideIndicator:YES];

        PostDetails *post = [storiesArray lastObject];

        NSString *body = shareUrl;
        
        mailComposer= [[MFMailComposeViewController alloc] init];
        [mailComposer setMailComposeDelegate:self];
        [mailComposer setMessageBody:body isHTML:NO];
        mailComposer.navigationBar.barStyle = UIBarStyleBlackOpaque;
        
        //        [self presentModalViewController:mailComposer animated:TRUE];
        [self presentViewController:mailComposer animated:TRUE completion:^{    [appDelegate showOrhideIndicator:NO];
}];
    }
}

-(void)sendInappropriateEmail: (NSDictionary *) dict
{
    NSString *subject =  dict[@"subject"];
    NSString *body =  dict[@"body"];
    [self displayMailComposerSheet:subject :body];
}

- (void)displayMailComposerSheet: (NSString *)subject : (NSString *)body
{
    if([MFMailComposeViewController canSendMail])
    {
        mailComposer= [[MFMailComposeViewController alloc] init];
        [mailComposer setMailComposeDelegate:self];
        [mailComposer setSubject:subject];
        [mailComposer setMessageBody:body isHTML:NO];
        mailComposer.navigationBar.barStyle = UIBarStyleBlackOpaque;
        [mailComposer setToRecipients:[NSArray arrayWithObjects: @"abuse@samepinch.co",nil]];
        
        //        [self presentModalViewController:mailComposer animated:TRUE];
        [self presentViewController:mailComposer animated:TRUE completion:NULL];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    NSString *messageStr = nil;
    switch (result){
            
        case MFMailComposeResultSaved:; //Mail is saved
            messageStr = @"Email saved successfully";
            break;
            
        case MFMailComposeResultSent:; //Mail is sent
            messageStr = @"Email sent successfully";
            break;
            
            
        case MFMailComposeResultFailed:;    //Mail sending id failed.
            //messageStr = @"Email sending failed";
            break;
            
        case MFMailComposeResultCancelled: break; //If we click on the cancle.
            
        default: break;
            
    }
    //    [self dismissModalViewControllerAnimated:TRUE];
    [self dismissViewControllerAnimated:TRUE completion:NULL];
}

#pragma mark -
#pragma mark Push Methods
- (void)tagCicked:(NSString *)tagName
{
    selectedTag = tagName;
    [self performSegueWithIdentifier: @"TagView" sender: self];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TagView"])
    {
        
        TagViewController *destViewController = segue.destinationViewController;
        destViewController.tagName = selectedTag;
    }
    else if ([segue.identifier isEqualToString:@"EditComment"])
    {
        EditCommentViewController *destViewController = segue.destinationViewController;
        PostDetails *postDetails = [storiesArray lastObject];
        NSMutableDictionary * commentDict = [[postDetails.comments objectAtIndex:commentIndex] mutableCopy];

        destViewController.commentDetails = commentDict;
    }
    
}

- (void)tappedTextView:(UITapGestureRecognizer *)tapGesture {
    if (tapGesture.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    UIImageView *imgView = (UIImageView *)tapGesture.view;
        JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
        imageInfo.imageURL = [NSURL URLWithString:imgView.image.accessibilityIdentifier];

        JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                               initWithImageInfo:imageInfo
                                               mode:JTSImageViewControllerMode_Image
                                               backgroundStyle:JTSImageViewControllerBackgroundOption_None];
        
        // Present the view controller.
        [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOffscreen];
        isImageClicked = YES;
        return;
}
- (void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point {
    if (result.resultType == NSTextCheckingTypeLink) {
        [[UIApplication sharedApplication] openURL:result.URL];
    }
}


#pragma mark -
#pragma mark Timed Reminders
-(void)check
{
    NSMutableArray *timedReminderArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"PageGuidePopUpImages"];
    NSArray *array = [timedReminderArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"context = %@",@"ViewPost"]];
    if(array.count > 0)
    {
        homeContext = [[array firstObject] mutableCopy];
        NSDictionary *dictionary = [array firstObject];
        NSArray *graphicsArray = [dictionary objectForKey:@"graphics"];
        if(graphicsArray.count > 0)
        {
            
            subContext = [graphicsArray firstObject];
            [self setUpTimerWithStartInSubContext:subContext];
            
            
        }
    }
    
    
}
-(void)setUpTimerWithStartInSubContext:(NSMutableDictionary *)subContext1
{
    NSTimeInterval timeInterval = [[subContext1 valueForKey:@"start"] doubleValue];
    
    if (!timerHomepage) {
        
        timerHomepage = [NSTimer scheduledTimerWithTimeInterval: timeInterval
                                                         target: self
                                                       selector: @selector(displayPromptForNewKidWhenStreamDataEmpty)
                                                       userInfo: nil
                                                        repeats: NO];
    }
    else
    {
        
        [timerHomepage invalidate];
        timerHomepage = nil;
        timerHomepage = [NSTimer scheduledTimerWithTimeInterval: timeInterval
                                                         target: self
                                                       selector: @selector(displayPromptForNewKidWhenStreamDataEmpty)
                                                       userInfo: nil
                                                        repeats: NO];
    }
}
/// Display the pop up
-(void)displayPromptForNewKidWhenStreamDataEmpty
{

    streamTableView.frame = originalPostion;
    
    [self.txt_comment resignFirstResponder];

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    addPopUpView = [[UIView alloc] initWithFrame:CGRectMake(0,0,screenWidth,screenHeight)];
    [addPopUpView setBackgroundColor:[UIColor clearColor]];
    
    
    //MARK:POP Up image
    UIImageView *popUpContent = [[UIImageView alloc] init];
    [popUpContent setFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    
    NSString *imageURL = [subContext objectForKey:@"asset"];
    UIImage *thumb;
    if (imageURL.length >0)
    {
        photoUtils = [ProfilePhotoUtils alloc];
        thumb = [photoUtils getImageFromCache:imageURL];
        
        if (thumb == nil)
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^(void)
                           {
                               NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
                               UIImage* image = [[UIImage alloc] initWithData:imageData];
                               if (image) {
                                   [photoUtils saveImageToCache:imageURL :image];
                                   
                               }
                           });
        }
        else
        {
            [popUpContent setImage:thumb];
        }
    }
    else
    {
        //[popUpContent setImage:[UIImage imageNamed:@"New_Child_Stream_Empty.png"]];
    }
    [popUpContent setImage:thumb];
    
    [addPopUpView addSubview:popUpContent];
    
    // MARK:Got it button
    UIButton *gotItButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [gotItButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    gotItButton.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    gotItButton.tag = 1;
    [addPopUpView addSubview:gotItButton];
    
    if (thumb)
    {
        [[[[UIApplication sharedApplication] delegate] window] addSubview:addPopUpView];
    }
    
}
- (void)buttonClicked:(UIButton *)sender
{
    //
    [addPopUpView removeFromSuperview];
    
    NSMutableArray *userDefaultsArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PageGuidePopUpImages"] mutableCopy];
    long int index = [userDefaultsArray indexOfObject:homeContext];
    NSMutableArray *graphicsArrray =  [[homeContext objectForKey:@"graphics"] mutableCopy];
    [graphicsArrray removeObject:subContext];
    [homeContext setObject:graphicsArrray forKey:@"graphics"];
    [userDefaultsArray replaceObjectAtIndex:index withObject:homeContext];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userDefaultsArray forKey:@"PageGuidePopUpImages"];
    
    
    ////////////Saving already viewed uids in userdefaults
    NSMutableArray *visitedRemainders =  [[userDefaults objectForKey:@"time_reminder_visits"] mutableCopy];
    if(visitedRemainders.count >0 )
    {
        NSArray *contextArray  = [visitedRemainders filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"reminder_uid = %@",[homeContext objectForKey:@"uid"]]];
        if(contextArray.count >0)
        {
            NSMutableDictionary *contextDict = [[contextArray firstObject] mutableCopy];
            long int index = [visitedRemainders indexOfObject:contextDict];
            NSMutableArray *graphicsArray = [[contextDict objectForKey:@"graphic_uids"] mutableCopy];
            [graphicsArray addObject:[subContext objectForKey:@"uid"]];
            [contextDict setObject:graphicsArray forKey:@"graphic_uids"];
            [visitedRemainders replaceObjectAtIndex:index withObject:contextDict];
            [userDefaults setObject:visitedRemainders forKey:@"time_reminder_visits"];
            
        }
        else
        {
            [visitedRemainders addObject:@{@"reminder_uid":[homeContext objectForKey:@"uid"],@"graphic_uids":[NSArray arrayWithObject:[subContext objectForKey:@"uid"]]}];
            [userDefaults setObject:visitedRemainders forKey:@"time_reminder_visits"];
            
        }
        
        
    }
    else
    {
        NSArray *visited_Remainders = [NSArray arrayWithObject:@{@"reminder_uid":[homeContext objectForKey:@"uid"],@"graphic_uids":[NSArray arrayWithObject:[subContext objectForKey:@"uid"]]}];
        [userDefaults setObject:visited_Remainders forKey:@"time_reminder_visits"];
        
    }
    
    [userDefaults synchronize];
    
    
    //[self check];
    
    
}
#pragma mark -
#pragma mark Share Methods
-(void)getShareUrl
{
    
    PostDetails *postDetails = [storiesArray lastObject];
    NSMutableDictionary * commentDict = [[postDetails.comments objectAtIndex:commentIndex] mutableCopy];
    NSString *itemId = [commentDict objectForKey:@"uid"];
    
    AccessToken* token = sharedModel.accessToken;
    
    NSDictionary* postData = @{@"command": @"shareUrl",@"access_token": token.access_token,@"body":@{@"commentId":itemId}};
    NSDictionary *userInfo = @{@"command": @"shareUrl"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@posts",BASE_URL];
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];

    [appDelegate showOrhideIndicator:YES];
}
-(void)shareUrlSuccessFull:(NSDictionary *)recievedDict
{
    shareUrl = [recievedDict objectForKey:@"url"];
    [appDelegate showOrhideIndicator:NO];
    [self shareOptions];
}
-(void)shareUrlFailed
{
    [appDelegate showOrhideIndicator:NO];
}
#pragma mark -
#pragma mark FB Share Methods
-(void)shareToFB
{
  /*  if (![[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"])
    {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];

        [loginManager logInWithPublishPermissions:@[@"publish_actions"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
         {
             if ([result.grantedPermissions containsObject:@"publish_actions"])
             {
                 FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
                 content.contentURL = [NSURL URLWithString:shareUrl];
                 [FBSDKShareAPI shareWithContent:content delegate:nil];

             }}];
    }
    else
    {
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:shareUrl];
    [FBSDKShareAPI shareWithContent:content delegate:nil];

    }
*/
    
//    FacebookShareController *fbc = [[FacebookShareController alloc] init];
//    fbc.postedConfirmationDelegate = self;
//    [fbc PostToFacebookViaAPI:post.url:@"":@"":@"story"];
    

}
@end
