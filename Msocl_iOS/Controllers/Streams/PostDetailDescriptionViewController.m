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
#import "PostDetails.h"
#import "SDWebImageManager.h"
#import "STTweetLabel.h"
#import "AppDelegate.h"

@implementation PostDetailDescriptionViewController
{
    ProfilePhotoUtils *photoUtils;
    ProfileDateUtils *profileDateUtils;
    ModelManager *sharedModel;
    AppDelegate *appDelegate;
    Webservices *webServices;
}
@synthesize storiesArray;
@synthesize postID;
@synthesize streamTableView;

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
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    {
    self.commentView = [[UIView alloc] initWithFrame:CGRectMake(0, streamTableView.frame.origin.y+streamTableView.frame.size.height, 320, 40)];
    [self.view addSubview:self.commentView];
    self.txt_comment = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 250, 40)];
    [self.txt_comment setText:@"Add comment"];
    self.txt_comment.delegate = self;
    [self.commentView addSubview:self.txt_comment];
        
    //Upvote
    UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [commentBtn setFrame:CGRectMake(275, 0, 45, 41)];
    [commentBtn setImage:[UIImage imageNamed:@"icon-comment-main.png"] forState:UIControlStateNormal];
    [commentBtn addTarget:self action:@selector(commentClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.commentView addSubview:commentBtn];
    [self.view addSubview:self.commentView];
        
    UILabel *line = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 320, 0.5)];
    line.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    [line setTextAlignment:NSTextAlignmentLeft];
    line.backgroundColor = [UIColor colorWithRed:(204/255.f) green:(204/255.f) blue:(204/255.f) alpha:1];
    [self.commentView addSubview:line];

    
    }
    
}
-(void)viewWillAppear:(BOOL)animated
{
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
    [storiesArray removeAllObjects];
    [storiesArray addObjectsFromArray:postArray];
    [streamTableView reloadData];
    
}
-(void) showPostFailed
{
    
}

#pragma mark -
#pragma mark TableViewMethods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    return [self cellHeight:[storiesArray objectAtIndex:indexPath.row]];
    else
        return [self cellHeightForComment:(int )indexPath.row-1];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    PostDetails *post = [storiesArray lastObject];
    return [storiesArray count] + post.comments.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
    static NSString *simpleTableIdentifier = @"StreamCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    PostDetails *postDetailsObject = [storiesArray objectAtIndex:indexPath.row];
    
    //removes any subviews from the cell
    for(UIView *viw in [[cell contentView] subviews])
    {
        [viw removeFromSuperview];
    }
    
    [self buildCell:cell withDetails:postDetailsObject];
    
    
    return cell;
    }
    else
    {
        static NSString *simpleTableIdentifier = @"CommentCell";
        CommentCell *cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier forIndexPath:indexPath];
        if (cell == nil)
        {
            cell = (CommentCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        
        //removes any subviews from the cell
        for(UIView *viw in [[cell contentView] subviews])
        {
            [viw removeFromSuperview];
        }
        
        
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
        [imagVw setImage:[UIImage imageNamed:@"EmptyProfilePic.jpg"]];
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
        
        [cell.contentView addSubview:imagVw];
        
        // NSString *temp = [[dict objectForKey:@"commenter"] objectForKey:@"fname"];
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(260,8,110,12)];
        [dateLabel setBackgroundColor:[UIColor clearColor]];
        
        NSString *milestoneDate = [commentDict objectForKey:@"created_at"];
        NSString *formattedTime = [profileDateUtils dailyLanguage:milestoneDate];
        
        [dateLabel setText:@"1 day"];
        [dateLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10]];
        [dateLabel setTextColor:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]];
        [dateLabel setNumberOfLines:0];
        [dateLabel setTextAlignment:NSTextAlignmentRight];
        [cell.contentView addSubview:dateLabel];
        
        NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]};
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[commentDict objectForKey:@"text"]   attributes:attributes];
        UILabel *comment = [UILabel new];
        comment.numberOfLines = 0;
        comment.attributedText = attributedString;
        [cell.contentView addSubview:comment];
        
        expectedLabelSize = [comment sizeThatFits:CGSizeMake(220, 9999)];
        comment.frame =  CGRectMake(53, 12, 220, expectedLabelSize.height);
    
}
-(void)buildCell:(UITableViewCell *)cell withDetails:(PostDetails *)postDetailsObject
{
    float yPosition = 5;
    

    
    //Profile Image
    UIImageView *profileImage  = [[UIImageView alloc] initWithFrame:CGRectMake(19, yPosition, 20, 20)];
    [profileImage setImageWithURL:[NSURL URLWithString:postDetailsObject.profileImage] placeholderImage:[UIImage imageNamed:@"EmptyProfilePic.jpg"]];
    [cell.contentView addSubview:profileImage];
    
    //Profile name
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(46, yPosition, 140, 20)];
    [name setText:postDetailsObject.name];
    [name setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]];
    [cell.contentView addSubview:name];
    
    //Time
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(260, yPosition, 50, 20)];
    [time setTextAlignment:NSTextAlignmentRight];
    [time setText:@"5 min ago"];
    [time setTextColor:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]];
    [time setFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:10]];
    [cell.contentView addSubview:time];
        
    [self addDescription:cell withDetails:postDetailsObject];
    
    
    
}
-(void)addDescription:(UITableViewCell *)cell withDetails:(PostDetails *)postDetailsObject
{
    float yPosition = 5;
    
    //Start of Description Text
    yPosition += 35;
    
    //Description
    UILabel *description = [[UILabel alloc] init];
    
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:postDetailsObject.content attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:12],NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]}];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\::(.*?)\\::" options:NSRegularExpressionCaseInsensitive error:NULL];
    
    
    do{
        
        NSArray *myArray = [regex matchesInString:attributedString.string options:0 range:NSMakeRange(0, [attributedString.string length])] ;
        if(myArray.count > 0)
        {
            NSTextCheckingResult *match =  [myArray firstObject];
            NSRange matchRange = [match rangeAtIndex:1];
            
            UIImage  *image = [UIImage imageNamed:@"EmptyProfilePic.jpg"];
            NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
            textAttachment.image = [photoUtils getSubImageFrom:image WithRect:CGRectMake(0, 0, 262, 114)];
            
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:[NSURL URLWithString:[postDetailsObject.images objectForKey:[attributedString.string substringWithRange:matchRange]]] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                textAttachment.image = [photoUtils getSubImageFrom:image WithRect:CGRectMake(0, 0, 262, 114)];
                [description setNeedsDisplay];
            }];
            
            NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
            [attributedString replaceCharactersInRange:match.range withAttributedString:attrStringWithImage];
        }
        else
        {
            break;
        }
        
    }while (1);
    //This regex captures all items between []
    
    CGRect contentSize = [attributedString boundingRectWithSize:CGSizeMake(264, CGFLOAT_MAX)
                                                        options:(NSStringDrawingUsesLineFragmentOrigin)
                                                        context:nil];
    description.frame = CGRectMake(44, yPosition, 264, contentSize.size.height);

        yPosition += contentSize.size.height;
    
    [description setAttributedText:attributedString];
    [description setTextAlignment:NSTextAlignmentLeft];
    [description setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
    [description setNumberOfLines:0];
    [cell.contentView addSubview:description];
    
    //Tags
    UIButton *heartButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [heartButton setImage:[UIImage imageNamed:@"icon-heart.png"] forState:UIControlStateNormal];
    [heartButton setFrame:CGRectMake(287, yPosition+3, 17, 16)];
    [cell.contentView addSubview:heartButton];

    
    if([postDetailsObject.tags count] > 0)
    {
            NSMutableArray *tagsArray = [[NSMutableArray alloc] init];
            for(NSString *tag in postDetailsObject.tags)
            {
                [tagsArray addObject:[NSString stringWithFormat:@"#%@",tag]];
            }
            
            NSAttributedString *tagsStr = [[NSAttributedString alloc] initWithString:[tagsArray componentsJoinedByString:@" "] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor blackColor]}];
            CGSize tagsSize = [tagsStr boundingRectWithSize:CGSizeMake(240, CGFLOAT_MAX)
                                                    options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                    context:nil].size;
            
            STTweetLabel *tweetLabel = [[STTweetLabel alloc] initWithFrame:CGRectMake(44, yPosition, 240 , tagsSize.height)];
            [tweetLabel setText:tagsStr.string];
            tweetLabel.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:tweetLabel];
            
            [tweetLabel setDetectionBlock:^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
                
            }];
            
            yPosition += tagsSize.height+10;
        
    }
    else
        yPosition += 21+10;

    UIView *likesView = [[UIView alloc] init];
    [likesView setBackgroundColor:[UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0f]];
    [cell.contentView addSubview:likesView];

    NSMutableArray *commenters = [NSMutableArray arrayWithArray:postDetailsObject.commenters];
        
        float x = 22,y = 0;
        for(int i = 0; i < commenters.count; i++)
        {
            
            NSString *url = [commenters objectAtIndex:i];
            UIImageView *imagVw = [[UIImageView alloc] initWithFrame:CGRectMake(x, y+10, 19, 19)];
            [likesView addSubview:imagVw];
            
            __weak UIImageView *weakSelf = imagVw;
            
            
            [imagVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:[photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:[UIImage imageNamed:@"EmptyProfilePic.jpg"] scaledToSize:CGSizeMake(19,19)] withRadious:0] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(19, 19)] withRadious:0];
                 
             }failure:nil];
            
            
            x+= 19 + 3;
            
            if( i%9 == 0)
            {
                x = 22;
                y += 30;
            }
        }
    likesView.frame = CGRectMake(0, yPosition, 320, y);
    
    
}

-(void)commentClicked:(id)sender
{
    [appDelegate showOrhideIndicator:YES];
    
    PostDetails *postDetls = [storiesArray lastObject];

    AccessToken* token = sharedModel.accessToken;
    
    NSDictionary* postData = @{@"command": @"create",@"access_token": token.access_token,@"body":@{@"post_id":postDetls.uid,@"text":self.txt_comment.text}};
    NSDictionary *userInfo = @{@"command": @"Comment"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@comments",BASE_URL];
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
    [self.txt_comment resignFirstResponder];
    

}
-(void) commentSuccessful:(NSDictionary *)recievedDict
{
    [appDelegate showOrhideIndicator:NO];
    NSDictionary *dict = @{@"commenter": @{@"fname":@"" ,@"lname": @"",@"photo":@""},@"editable": [NSNumber numberWithBool:YES],@"text":self.txt_comment.text};
    
    PostDetails *postDetls = [storiesArray lastObject];
    NSMutableArray *commentsArray = [postDetls.comments mutableCopy];
    [commentsArray addObject:dict];
    postDetls.comments = commentsArray;
    [storiesArray replaceObjectAtIndex:0 withObject:postDetls];
    [streamTableView reloadData];
}
-(void) commentFailed
{
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
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:postDetailsObject.content attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:12],NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]}];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\::(.*?)\\::" options:NSRegularExpressionCaseInsensitive error:NULL];
    
    
    do{
        
        NSArray *myArray = [regex matchesInString:attributedString.string options:0 range:NSMakeRange(0, [attributedString.string length])] ;
        if(myArray.count > 0)
        {
            NSTextCheckingResult *match =  [myArray firstObject];
            UIImage  *image = [UIImage imageNamed:@"EmptyProfilePic.jpg"];
            NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
            textAttachment.image = [photoUtils getSubImageFrom:image WithRect:CGRectMake(0, 0, 262, 114)];
            
            NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
            [attributedString replaceCharactersInRange:match.range withAttributedString:attrStringWithImage];
        }
        else
        {
            break;
        }
        
    }while (1);
    //This regex captures all items between []
    
    CGRect contentSize = [attributedString boundingRectWithSize:CGSizeMake(264, CGFLOAT_MAX)
                                                        options:(NSStringDrawingUsesLineFragmentOrigin)
                                                        context:nil];

        height = 40 + contentSize.size.height;

    
    //Tags height
    NSMutableArray *tagsArray = [[NSMutableArray alloc] init];
    for(NSString *tag in postDetailsObject.tags)
    {
        [tagsArray addObject:[NSString stringWithFormat:@"#%@",tag]];
    }
    
    NSAttributedString *tagsStr = [[NSAttributedString alloc] initWithString:[tagsArray componentsJoinedByString:@" "] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor blackColor]}];
    CGSize tagsSize = [tagsStr boundingRectWithSize:CGSizeMake(240, CGFLOAT_MAX)
                                            options:(NSStringDrawingUsesLineFragmentOrigin)
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
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[[commentsArray objectAtIndex:row] objectForKey:@"text"]   attributes:attributes];
    UILabel *comment = [UILabel new];
    comment.numberOfLines = 0;
    comment.attributedText = attributedString;
    CGSize expectedLabelSize = [comment sizeThatFits:CGSizeMake(220, 9999)];

    CGFloat height;
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



@end
