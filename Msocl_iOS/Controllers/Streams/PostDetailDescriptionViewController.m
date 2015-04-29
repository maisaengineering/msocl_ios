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
#import "CustomCipher.h"
#import "TagViewController.h"
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
}
@synthesize storiesArray;
@synthesize postID;
@synthesize streamTableView;
@synthesize postObjectFromWall;
@synthesize delegate;
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    appDelegate = [[UIApplication sharedApplication] delegate];
    photoUtils = [ProfilePhotoUtils alloc];
    profileDateUtils = [ProfileDateUtils alloc];
    sharedModel   = [ModelManager sharedModel];
    
    self.title = @"M SOCIAL";
    
   /* //Upvote
    UIButton *follow = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [follow setTitle:@"Follow this post" forState:UIControlStateNormal];
    [follow.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [follow setFrame:CGRectMake(0, 64, 320, 40)];
    [self.view addSubview:follow];
    */
    
    storiesArray = [[NSMutableArray alloc] init];
    streamTableView.frame = CGRectMake(0, 0, 320, Deviceheight-40);
    streamTableView.tableFooterView = [[UIView alloc] init];
    streamTableView.tableHeaderView = nil;
    streamTableView.backgroundColor = [UIColor colorWithRed:(229/255.f) green:(225/255.f) blue:(221/255.f) alpha:1];
    
    UIImage *background = [UIImage imageNamed:@"icon-back.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside]; //adding action
    [button setImage:background forState:UIControlStateNormal];
    button.frame = CGRectMake(0 ,0,13,17);
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;    
    
    self.commentView = [[UIView alloc] initWithFrame:CGRectMake(0, streamTableView.frame.origin.y+streamTableView.frame.size.height, 320, 40)];
        self.commentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.commentView];
    self.txt_comment = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 235, 40)];
    self.txt_comment.delegate = self;
        [self.txt_comment setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];

    [self.commentView addSubview:self.txt_comment];
        
        placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0, self.txt_comment.frame.size.width - 15.0, 40)];
        //[placeholderLabel setText:placeholder];
        [placeholderLabel setBackgroundColor:[UIColor clearColor]];
        [placeholderLabel setNumberOfLines:0];
        placeholderLabel.text = @"Write a comment";
        [placeholderLabel setTextAlignment:NSTextAlignmentLeft];
        [placeholderLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:14]];
        [placeholderLabel setTextColor:[UIColor lightGrayColor]];
        [self.txt_comment addSubview:placeholderLabel];

        
    //Upvote
    UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [commentBtn setFrame:CGRectMake(244, 6, 39, 28)];
    [commentBtn setImage:[UIImage imageNamed:@"comment-post.png"] forState:UIControlStateNormal];
    [commentBtn addTarget:self action:@selector(callCommentApi) forControlEvents:UIControlEventTouchUpInside];
    [self.commentView addSubview:commentBtn];
    
        //Upvote
        UIButton *anonymousButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [anonymousButton setFrame:CGRectMake(283.3, 6, 29, 28)];
        [anonymousButton setImage:[UIImage imageNamed:@"comment-ana.png"] forState:UIControlStateNormal];
        [anonymousButton addTarget:self action:@selector(anonymousCommentClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.commentView addSubview:anonymousButton];
    
    postAnonymous = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 18, 18)];
    
    __weak UIImageView *weakSelf = postAnonymous;
    __weak ProfilePhotoUtils *weakphotoUtils = photoUtils;
    
    [postAnonymous setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:sharedModel.userProfile.image]] placeholderImage:[UIImage imageNamed:@"icon-profile-register.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf.image = [weakphotoUtils makeRoundWithBoarder:[weakphotoUtils squareImageWithImage:image scaledToSize:CGSizeMake(18, 18)] withRadious:0];
         
     }failure:nil];
    [anonymousButton addSubview:postAnonymous];

    
        
    UILabel *line = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 320, 0.5)];
    line.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    [line setTextAlignment:NSTextAlignmentLeft];
    line.backgroundColor = [UIColor colorWithRed:(225/255.f) green:(225/255.f) blue:(225/255.f) alpha:1];
    [self.commentView addSubview:line];

    
        popView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 64)];
    
    UILabel *postAsLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 32)];
    [postAsLabel1 setText:@"Comment as"];
    [postAsLabel1 setTextAlignment:NSTextAlignmentCenter];
    [postAsLabel1 setTextColor:[UIColor colorWithRed:76/255.0 green:121/255.0 blue:251/255.0 alpha:1.0]];
    [postAsLabel1 setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
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
    
    UILabel *line2 = [[UILabel alloc] initWithFrame: CGRectMake(0, 32.5, 300, 0.5)];
    line2.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    [line2 setTextAlignment:NSTextAlignmentLeft];
    line2.backgroundColor = [UIColor colorWithRed:(204/255.f) green:(204/255.f) blue:(204/255.f) alpha:1];
    [popView addSubview:line2];
    
    
    UILabel *postAsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 32, 300, 32)];
    [postAsLabel setText:@"Comment as"];
    [postAsLabel setTextAlignment:NSTextAlignmentCenter];
    [postAsLabel setTextColor:[UIColor colorWithRed:76/255.0 green:121/255.0 blue:251/255.0 alpha:1.0]];
    [postAsLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
    [popView addSubview:postAsLabel];
    
    UIImageView *anonymusImage = [[UIImageView alloc] initWithFrame:CGRectMake(192, 34, 32, 24)];
    [anonymusImage setImage:[UIImage imageNamed:@"icon-anamous.png"]];
    [popView addSubview:anonymusImage];
    
    UIButton *postBtnAnonymous = [UIButton buttonWithType:UIButtonTypeCustom];
    postBtnAnonymous.frame = CGRectMake(0, 32, 300, 32);
    [postBtnAnonymous addTarget:self action:@selector(commentAsAnonymous) forControlEvents:UIControlEventTouchUpInside];
    [popView addSubview:postBtnAnonymous];
    
    
    
        popover = [DXPopover popover];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];

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
    [self callShowPostApi];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
-(void)backClicked
{
    PostDetails *post = [storiesArray lastObject];
    postObjectFromWall.tags = post.tags;
    postObjectFromWall.upVoteCount = post.upVoteCount;
    postObjectFromWall.upvoted = post.upvoted;
    postObjectFromWall.content = post.content;
    postObjectFromWall.anonymous = post.anonymous;
    postObjectFromWall.time = post.time;
    
    [self.delegate PostEditedFromPostDetails:postObjectFromWall];
    [self.navigationController popViewControllerAnimated:YES];
    
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
    if(postObject.editable)
    {
        UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [editButton addTarget:self action:@selector(editClicked) forControlEvents:UIControlEventTouchUpInside]; //adding action
        [editButton setImage:[UIImage imageNamed:@"icon-edit.png"] forState:UIControlStateNormal];
        editButton.frame = CGRectMake(0 ,0,20,18);
        
        UIBarButtonItem *rightbarButton = [[UIBarButtonItem alloc] initWithCustomView:editButton];
        self.navigationItem.rightBarButtonItem = rightbarButton;

    }
    [storiesArray removeAllObjects];
    [storiesArray addObjectsFromArray:postArray];
    [self.streamTableView reloadData];
}
-(void) showPostFailed
{
    
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
    
    [self buildCell:cell withDetails:postDetailsObject];
    
    
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
        CommentCell *cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier forIndexPath:indexPath];
        if (cell == nil)
        {
            cell = (CommentCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        
        //removes any subviews from the cell
        for(UIView *viw in [[cell contentView] subviews])
        {
            [viw removeFromSuperview];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

        
        // Add utility buttons
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:0.7]
                                                    icon:[UIImage imageNamed:@"icon-heart-scroll.png"]];
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:0.7]
                                                    icon:[UIImage imageNamed:@"icon-edit-scroll.png"]];
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:0.7]
                                                    icon:[UIImage imageNamed:@"icon-heart-count.png"]];
        
        
        cell.leftUtilityButtons = rightUtilityButtons;
        cell.delegate = self;

        
        PostDetails *postDetailsObject = [storiesArray lastObject];
        NSDictionary *commentDict = [postDetailsObject.comments objectAtIndex:indexPath.row - 1];
        
        [self buildCommentCell:commentDict :cell];
        return cell;
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(void)buildCommentCell:(NSDictionary *)commentDict :(UITableViewCell *)cell
{
    CGSize expectedLabelSize;
    
        UIImageView *imagVw = [[UIImageView alloc] initWithFrame:CGRectMake(16, 8, 28, 28)];
        [imagVw setImage:[UIImage imageNamed:@"icon-profile-register.png"]];
    if(![[commentDict objectForKey:@"anonymous"] boolValue])
    {
    __weak UIImageView *weakSelf = imagVw;

        //add initials
        //NSString *nickname = [dict valueForKey:@"commented_by"];
        
        NSString *url = [[commentDict objectForKey:@"commenter"] objectForKey:@"photo"];
        if(url != (id)[NSNull null] && url.length > 0)
        {
            // Fetch image, cache it, and add it to the tag.
            [imagVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 [photoUtils saveImageToCache:url :image];
                 
                 weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(28, 28)] withRadious:0];
                 
             }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
             {
                 DebugLog(@"fail");
             }];
        }
    }
        [cell.contentView addSubview:imagVw];
        
        // NSString *temp = [[dict objectForKey:@"commenter"] objectForKey:@"fname"];
    
        NSString *milestoneDate = [commentDict objectForKey:@"createdAt"];
        NSString *formattedTime = [profileDateUtils dailyLanguage:milestoneDate];
        
    
    UIImageView *heartCntImage  = [[UIImageView alloc] initWithFrame:CGRectMake(267, 16, 12, 12)];
    [heartCntImage setImage:[UIImage imageNamed:@"icon-upvote-gray.png"]];
    [cell.contentView addSubview:heartCntImage];

    UILabel *upVoteCount = [[UILabel alloc] initWithFrame:CGRectMake(280,16.5,10,12)];
    [upVoteCount setBackgroundColor:[UIColor clearColor]];
    [upVoteCount setText:[NSString stringWithFormat:@"%i",[[commentDict objectForKey:@"upvote_count"] intValue] ]];
    [upVoteCount setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10]];
    [upVoteCount setTextColor:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]];
    [upVoteCount setNumberOfLines:1];
    [upVoteCount setTextAlignment:NSTextAlignmentLeft];
    [cell.contentView addSubview:upVoteCount];

    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:[UIImage imageNamed:@"icon-more.png"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreClicked:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.frame = CGRectMake(290, 2, 20, 40);
    [moreButton setTag:[[streamTableView indexPathForRowAtPoint:cell.center] row]];
    [cell.contentView addSubview:moreButton];
    
    
        NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:(34/255.f) green:(34/255.f) blue:(34/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]};
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[commentDict objectForKey:@"text"]   attributes:attributes];
    NSAttributedString *timAttr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@",formattedTime] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(170/255.f) green:(170/255.f) blue:(170/255.f) alpha:1],NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Italic" size:7]}];
    [attributedString appendAttributedString:timAttr];

        UILabel *comment = [UILabel new];
        comment.numberOfLines = 0;
        comment.attributedText = attributedString;
        [cell.contentView addSubview:comment];
        
        expectedLabelSize = [comment sizeThatFits:CGSizeMake(205, 9999)];
        comment.frame =  CGRectMake(53, 12, 205, expectedLabelSize.height);
    
}
-(void)buildCell:(UITableViewCell *)cell withDetails:(PostDetails *)postDetailsObject
{
    float yPosition = 5;
    

    
    //Profile Image
    UIImageView *profileImage  = [[UIImageView alloc] initWithFrame:CGRectMake(19, yPosition, 20, 20)];
    if(!postDetailsObject.anonymous)
    {
        __weak UIImageView *weakSelf = profileImage;
        
        [profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[postDetailsObject.owner objectForKey:@"photo"]]] placeholderImage:[UIImage imageNamed:@"icon-profile-register.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(20, 20)] withRadious:0];
             
         }failure:nil];
    }
    else
        [profileImage setImage:[UIImage imageNamed:@"icon-profile-register.png"]];

    
    [cell.contentView addSubview:profileImage];
    
    //Profile name
    if(!postDetailsObject.anonymous)
    {
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(46, yPosition, 140, 20)];
    [name setText:[NSString stringWithFormat:@"%@ %@",[postDetailsObject.owner objectForKey:@"fname"],[postDetailsObject.owner objectForKey:@"lname"]]];
    [name setTextColor:[UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0]];
    [name setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14]];
    [cell.contentView addSubview:name];
    }
    //Time
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(260, yPosition, 50, 20)];
    [time setTextAlignment:NSTextAlignmentRight];
    [time setText:[profileDateUtils dailyLanguage:postDetailsObject.time]];
    [time setTextColor:[UIColor colorWithRed:(153/255.f) green:(153/255.f) blue:(153/255.f) alpha:1]];
    [time setFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:8]];

    [cell.contentView addSubview:time];
        
    [self addDescription:cell withDetails:postDetailsObject];
    
    
    
}
-(void)addDescription:(UITableViewCell *)cell withDetails:(PostDetails *)postDetailsObject
{
    float yPosition = 5;
    
    //Start of Description Text
    yPosition += 30;
    
    //Description
    UILabel *description = [[UILabel alloc] init];
    
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:postDetailsObject.content attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:14],NSForegroundColorAttributeName:[UIColor colorWithRed:(85/255.f) green:(85/255.f) blue:(85/255.f) alpha:1]}];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\::(.*?)\\::" options:NSRegularExpressionCaseInsensitive error:NULL];
    
    
    do{
        
        NSArray *myArray = [regex matchesInString:attributedString.string options:0 range:NSMakeRange(0, [attributedString.string length])] ;
        if(myArray.count > 0)
        {
            NSTextCheckingResult *match =  [myArray firstObject];
            NSRange matchRange = [match rangeAtIndex:1];
            
            UIImage  *image = [UIImage imageNamed:@"EmptyProfilePic.jpg"];
            NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
            textAttachment.image = [photoUtils imageWithImage:image scaledToSize:CGSizeMake(262, 114) withRadious:5.0];
            
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:[NSURL URLWithString:[postDetailsObject.images objectForKey:[attributedString.string substringWithRange:matchRange]]] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                textAttachment.image = [photoUtils makeRoundedCornersWithBorder:[image resizedImageByMagick:@"262x114#"] withRadious:5.0];
                [description setNeedsDisplay];
            }];
            
            NSMutableAttributedString *attrStringWithImage = [[NSMutableAttributedString alloc] initWithString:@"\n" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:2]}];
            [attrStringWithImage appendAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
            
            [attributedString replaceCharactersInRange:match.range withAttributedString:attrStringWithImage];
        }
        else
        {
            break;
        }
        
    }while (1);
    //This regex captures all items between []
    
    [description setAttributedText:attributedString];

    UILabel *label = [UILabel alloc];
    [label setAttributedText:attributedString];
    
    CGSize contentSize = [label sizeThatFits:CGSizeMake(264, CGFLOAT_MAX)];
    description.frame = CGRectMake(44, yPosition, 262, contentSize.height);

        yPosition += contentSize.height;

    [description setNumberOfLines:0];
    [cell.contentView addSubview:description];
    

    
    //Tags
    UIButton *heartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if(postDetailsObject.upvoted)
    [heartButton setImage:[UIImage imageNamed:@"icon-upvote.png"] forState:UIControlStateNormal];
    else
    [heartButton setImage:[UIImage imageNamed:@"icon-upvote-gray.png"] forState:UIControlStateNormal];
    [heartButton setFrame:CGRectMake(269, yPosition+1, 30, 30)];
    [heartButton setTag:[[streamTableView indexPathForCell:cell] row]];
    [heartButton addTarget:self action:@selector(heartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:heartButton];
    
    UILabel *upVoteCount = [[UILabel alloc] initWithFrame:CGRectMake(290, yPosition+4, 20 , 16)];
    [upVoteCount setText:[NSString stringWithFormat:@"%i",postDetailsObject.upVoteCount]];
    [upVoteCount setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
    [cell.contentView addSubview:upVoteCount];
    
    
    UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [flagButton setImage:[UIImage imageNamed:@"flag-inactive.png"] forState:UIControlStateNormal];
    [flagButton setFrame:CGRectMake(230, yPosition+3, 30, 30)];
    [flagButton setTag:[[streamTableView indexPathForCell:cell] row]];
    [flagButton addTarget:self action:@selector(flagButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:flagButton];

    
    if([postDetailsObject.tags count] > 0)
    {
        
            NSAttributedString *tagsStr = [[NSAttributedString alloc] initWithString:[postDetailsObject.tags componentsJoinedByString:@" "] attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:13.0],NSForegroundColorAttributeName:[UIColor blackColor]}];
            CGSize tagsSize = [tagsStr boundingRectWithSize:CGSizeMake(200, CGFLOAT_MAX)
                                                    options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                    context:nil].size;
            
            STTweetLabel *tweetLabel = [[STTweetLabel alloc] initWithFrame:CGRectMake(44, yPosition+5, 200 , tagsSize.height)];
            [tweetLabel setText:tagsStr.string];
            tweetLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:tweetLabel];
            
            [tweetLabel setDetectionBlock:^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
                
                [self tagCicked:string];
            }];
            
            yPosition += tagsSize.height+10;
        
    }
    else
        yPosition += 21+10;
    

    
}

#pragma mark -
#pragma mark Comment Methods
-(void)anonymousCommentClicked:(id)sender
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = [(UIButton *)sender frame];
    frame.origin.y = self.commentView.frame.origin.y+2;
    btn.frame = frame;
    [popover showAtView:btn withContentView:popView];
    }
    else
    {
        [self gotoLoginScreen];
    }
    
}
-(void)commentAsAnonymous
{
    [popover dismiss];
    isAnonymous = YES;
    postAnonymous.image = [UIImage imageNamed:@"icon-anamous.png"];
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
    
    [postAnonymous setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:sharedModel.userProfile.image]] placeholderImage:[UIImage imageNamed:@"icon-profile-register.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf.image = [weakphotoUtils makeRoundWithBoarder:[weakphotoUtils squareImageWithImage:image scaledToSize:CGSizeMake(18, 18)] withRadious:0];
         
     }failure:nil];
    isAnonymous = NO;
}
-(void)callCommentApi
{
    [appDelegate showOrhideIndicator:YES];
    
    PostDetails *postDetls = [storiesArray lastObject];
    
    AccessToken* token = sharedModel.accessToken;
    
    NSDictionary* postData = @{@"command": @"create",@"access_token": token.access_token,@"body":@{@"post_id":postDetls.uid,@"text":self.txt_comment.text,@"anonymous":[NSNumber numberWithBool:isAnonymous]}};
    NSDictionary *userInfo = @{@"command": @"Comment"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@comments",BASE_URL];
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
    [self.txt_comment resignFirstResponder];

}
-(void) commentSuccessful:(NSDictionary *)recievedDict
{
    [appDelegate showOrhideIndicator:NO];
    
    PostDetails *postDetls = [storiesArray lastObject];
    NSMutableArray *commentsArray = [postDetls.comments mutableCopy];
    if(commentsArray == nil)
        commentsArray = [[NSMutableArray alloc] init];
    [commentsArray addObject:recievedDict];
    postDetls.comments = commentsArray;
    [storiesArray replaceObjectAtIndex:0 withObject:postDetls];
    [streamTableView reloadData];
    self.txt_comment.text = @"";
    [self.txt_comment addSubview:placeholderLabel];
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
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:postDetailsObject.content attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:13],NSForegroundColorAttributeName:[UIColor colorWithRed:(85/255.f) green:(85/255.f) blue:(85/255.f) alpha:1]}];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\::(.*?)\\::" options:NSRegularExpressionCaseInsensitive error:NULL];
    
    
    do{
        
        NSArray *myArray = [regex matchesInString:attributedString.string options:0 range:NSMakeRange(0, [attributedString.string length])] ;
        if(myArray.count > 0)
        {
            NSTextCheckingResult *match =  [myArray firstObject];
            UIImage  *image = [UIImage imageNamed:@"EmptyProfilePic.jpg"];
            NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
            textAttachment.image = [photoUtils getSubImageFrom:image WithRect:CGRectMake(0, 0, 262, 114)];
            
            NSMutableAttributedString *attrStringWithImage = [[NSMutableAttributedString alloc] initWithString:@"\n" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:2]}];
            [attrStringWithImage appendAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
            [attributedString replaceCharactersInRange:match.range withAttributedString:attrStringWithImage];
        }
        else
        {
            break;
        }
        
    }while (1);
    //This regex captures all items between []
    
    UILabel *label = [UILabel alloc];
    label.attributedText = attributedString;
    CGSize contentSize = [label sizeThatFits:CGSizeMake(264, CGFLOAT_MAX)];

        height = 35 + contentSize.height;

    
    //Tags height
    NSMutableArray *tagsArray = [[NSMutableArray alloc] init];
    for(NSString *tag in postDetailsObject.tags)
    {
        [tagsArray addObject:[NSString stringWithFormat:@"#%@",tag]];
    }
    
    NSAttributedString *tagsStr = [[NSAttributedString alloc] initWithString:[tagsArray componentsJoinedByString:@" "] attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:13.0],NSForegroundColorAttributeName:[UIColor blackColor]}];
    CGSize tagsSize = [tagsStr boundingRectWithSize:CGSizeMake(200, CGFLOAT_MAX)
                                            options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin)
                                            context:nil].size;
    
    if(postDetailsObject.tags.count > 0)
        height += tagsSize.height+10;
    else
            height += 21+10;
    
    return height;
}

-(CGFloat)cellHeightForComment:(int )row
{
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12]};
    

    
    PostDetails *postDetails = [storiesArray lastObject];
    NSArray *commentsArray = postDetails.comments;
    NSDictionary *commentDict = [commentsArray objectAtIndex:row];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[commentDict objectForKey:@"text"]   attributes:attributes];
    NSString *milestoneDate = [commentDict objectForKey:@"createdAt"];
    NSString *formattedTime = [profileDateUtils dailyLanguage:milestoneDate];

    NSAttributedString *timAttr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@",formattedTime] attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Italic" size:7]}];
    [attributedString appendAttributedString:timAttr];

    UILabel *comment = [UILabel new];
    comment.numberOfLines = 0;
    comment.attributedText = attributedString;
    CGSize expectedLabelSize = [comment sizeThatFits:CGSizeMake(205, 9999)];

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

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            // More button is pressed
            UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share on Facebook", @"Share on Twitter", nil];
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
}


#pragma mark -
#pragma mark TextView Delegate Methods
- (void)textViewDidBeginEditing:(UITextView *)textView1
{
    [placeholderLabel removeFromSuperview];
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView1
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    {
        [placeholderLabel removeFromSuperview];
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
    LoginViewController *login = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self.navigationController pushViewController:login animated:NO];

}

#pragma mark -
#pragma mark More Options In Comment
-(void)moreClicked:(id)sender
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    {
    PostDetails *post = [storiesArray lastObject];
    NSDictionary * commentDict = [post.comments objectAtIndex:[sender tag]-1];
    commentIndex = [sender tag]-1;
   
    UIActionSheet *addImageActionSheet = [[UIActionSheet alloc] init];
    if([[commentDict objectForKey:@"upvoted"] boolValue])
    {
    [addImageActionSheet addButtonWithTitle:@"Undo Like"];
    }
    else
    {
        [addImageActionSheet addButtonWithTitle:@"Like"];
    }
        [addImageActionSheet addButtonWithTitle:@"Flag"];
        
    addImageActionSheet.cancelButtonIndex = [addImageActionSheet addButtonWithTitle:@"Cancel"];

    addImageActionSheet.tag = 1;
    [addImageActionSheet setDelegate:self];
    [addImageActionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
    else
    {
        [self gotoLoginScreen];
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
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
        NSString *emailId = [NSString stringWithFormat:@"%@ %@", itemDate, itemId];
        NSString *emailIdBase64 = [emailId base64EncodedString];
        NSString *emailIdCipher = [CustomCipher encrypt:emailIdBase64];
        
        NSString *bodyText = [NSString stringWithFormat:@"Dear M Socail,\r\n\r\nPlease review the content for a comment dated %@ for inappropriate content.\r\n\r\n[So we can identify the content, please do not change the text between the two lines below, which represents the unique identifier for the content.  However, feel free to provide additional information above these lines for our review.]\r\n\r\n---------------------\r\n%@\r\n---------------------",itemDate, emailIdCipher];
        
        NSMutableDictionary *emailData = [[NSMutableDictionary alloc] init];
        [emailData setValue:@"Inappropriate content" forKey:@"subject"];
        [emailData setValue:bodyText forKey:@"body"];
        [self sendInappropriateEmail:emailData];

    }
}
-(void)CommentUpVote
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    {
        
        [appDelegate showOrhideIndicator:YES];
        AccessToken* token = sharedModel.accessToken;
        
        NSDictionary* postData;
        PostDetails *postDetails = [storiesArray lastObject];
        NSMutableDictionary * commentDict = [[postDetails.comments objectAtIndex:commentIndex] mutableCopy];
        if([[commentDict objectForKey:@"upvoted"] boolValue])
        {
            [commentDict setObject:[NSNumber numberWithBool:NO] forKey:@"upvoted"];
            [commentDict setObject:[NSNumber numberWithInt:[[commentDict objectForKey:@"upvote_count"] intValue]-1] forKey:@"upvote_count"];

            postData = @{@"command": @"undoVoting",@"access_token": token.access_token};
        }
        else
        {
            [commentDict setObject:[NSNumber numberWithBool:YES] forKey:@"upvoted"];
            [commentDict setObject:[NSNumber numberWithInt:[[commentDict objectForKey:@"upvote_count"] intValue]+1] forKey:@"upvote_count"];
            postData = @{@"command": @"upvote",@"access_token": token.access_token};
        }
        
        [postDetails.comments replaceObjectAtIndex:commentIndex withObject:commentDict];
        
        NSDictionary *userInfo = @{@"command": @"commentUpvote"};
        NSString *urlAsString = [NSString stringWithFormat:@"%@comments/%@",BASE_URL,[commentDict objectForKey:@"uid"]];
        [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
        
        [storiesArray replaceObjectAtIndex:0 withObject:postDetails];
        [streamTableView reloadData];
    }
    else
    {
        [self gotoLoginScreen];
    }
    
}
-(void) commentUpVoteSuccessFull:(NSDictionary *)recievedDict
{
    [appDelegate showOrhideIndicator:NO];
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
        NSString *emailId = [NSString stringWithFormat:@"%@ %@", itemDate, itemId];
        NSString *emailIdBase64 = [emailId base64EncodedString];
        NSString *emailIdCipher = [CustomCipher encrypt:emailIdBase64];
        
        NSString *bodyText = [NSString stringWithFormat:@"Dear M Socail,\r\n\r\nPlease review the content for a post item dated %@ for inappropriate content.\r\n\r\n[So we can identify the content, please do not change the text between the two lines below, which represents the unique identifier for the content.  However, feel free to provide additional information above these lines for our review.]\r\n\r\n---------------------\r\n%@\r\n---------------------",itemDate, emailIdCipher];
        
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
        [mailComposer setToRecipients:[NSArray arrayWithObjects: @"contact@maisasolutions.com",nil]];
        
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
    
}

@end
