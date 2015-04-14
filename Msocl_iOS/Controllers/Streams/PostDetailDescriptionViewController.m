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
    streamTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, Deviceheight-40)];
    streamTableView.delegate = self;
    streamTableView.dataSource = self;
    streamTableView.tableFooterView = nil;
    streamTableView.tableHeaderView = nil;
    streamTableView.backgroundColor = [UIColor colorWithRed:(229/255.f) green:(225/255.f) blue:(221/255.f) alpha:1];
    [streamTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:streamTableView];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    {
    self.commentView = [[UIView alloc] initWithFrame:CGRectMake(0, streamTableView.frame.origin.y+streamTableView.frame.size.height, 320, 40)];
    [self.view addSubview:self.commentView];
    self.txt_comment = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 250, 40)];
    [self.txt_comment setText:@"Add comment"];
    self.txt_comment.delegate = self;
    [self.commentView addSubview:self.txt_comment];
    //Upvote
    UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [commentBtn setTitle:@"Comment" forState:UIControlStateNormal];
    [commentBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [commentBtn setFrame:CGRectMake(250, 0, 70, 40)];
    [commentBtn addTarget:self action:@selector(commentClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.commentView addSubview:commentBtn];
    [self.view addSubview:self.commentView];
    
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
    return [self cellHeight:[storiesArray objectAtIndex:indexPath.row]];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [storiesArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
                                                        options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
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
    [heartButton setFrame:CGRectMake(287, yPosition, 17, 16)];
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
    
    UILabel *line1 = [[UILabel alloc] initWithFrame: CGRectMake(10, yPosition, 300, 0.5)];
    line1.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    [line1 setTextAlignment:NSTextAlignmentLeft];
    line1.backgroundColor = [UIColor colorWithRed:(204/255.f) green:(204/255.f) blue:(204/255.f) alpha:1];
    [cell.contentView addSubview:line1];

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
    
    //Comments list
     y = yPosition;
    CGSize expectedLabelSize;
    NSArray *commentsArray = postDetailsObject.comments;
    for (int i = 0; i < commentsArray.count; i++)
    {
        NSDictionary *dict = [commentsArray objectAtIndex:i];
        
        UIImageView *imagVw = [[UIImageView alloc] initWithFrame:CGRectMake(20, y, 47, 47)];
        [imagVw setImage:[UIImage imageNamed:@"EmptyProfilePic.jpg"]];
        //add initials
        //NSString *nickname = [dict valueForKey:@"commented_by"];
        NSString *nickname = @"test";
        NSArray *nameArray = [nickname componentsSeparatedByString:@" "];
        
        NSString *firstName = [[nameArray.firstObject substringToIndex:1]uppercaseString];;
        NSString *lastName = [[nameArray.lastObject substringToIndex:1] uppercaseString];;
        
        
        NSMutableString *commenterInitial = [[NSMutableString alloc] init];
        [commenterInitial appendString:firstName];
        [commenterInitial appendString:lastName];
        
        NSMutableAttributedString *attributedTextForComment = [[NSMutableAttributedString alloc] initWithString:commenterInitial attributes:nil];
        
        NSRange range;
        if(firstName.length > 0)
        {
            range.location = 0;
            range.length = 1;
            [attributedTextForComment setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:13]}
                                              range:range];
        }
        if(lastName.length > 0)
        {
            range.location = 1;
            range.length = 1;
            [attributedTextForComment setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:13]}
                                              range:range];
        }
        
        
        UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 47, 47)];
        initial.attributedText = attributedTextForComment;
        [initial setBackgroundColor:[UIColor clearColor]];
        initial.textAlignment = NSTextAlignmentCenter;
        [imagVw addSubview:initial];
        //end add initials
        
        __weak UIImageView *weakSelf = imagVw;
        DebugLog(@"*************%@",dict);
        NSString *url = [[dict objectForKey:@"commenter"] objectForKey:@"photo"];
        if(url != (id)[NSNull null] && url.length > 0)
        {
            // Fetch image, cache it, and add it to the tag.
            [imagVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 [photoUtils saveImageToCache:url :image];
                 
                 [weakSelf setImage:[UIImage imageNamed:@"EmptyProfilePic.jpg"]];
                 UIImageView *userImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 47, 47)];
                 userImage.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(51, 51)] withRadious:0];
                 [weakSelf addSubview:userImage];
                 [initial removeFromSuperview];
             }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
             {
                 DebugLog(@"fail");
             }];
        }
        
        [cell.contentView addSubview:imagVw];
        
        // NSString *temp = [[dict objectForKey:@"commenter"] objectForKey:@"fname"];
        NSString *temp = @"test";
        UILabel *nameLabel;
        if (temp != (id)[NSNull null] && temp.length > 0)
        {
            NSDictionary *attribs = @{
                                      NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:15]
                                      };
            expectedLabelSize = [temp boundingRectWithSize:CGSizeMake(200, 9999) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attribs context:nil].size;
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(77,y+2,130,12)];
            [nameLabel setBackgroundColor:[UIColor clearColor]];
            [nameLabel setText:[temp capitalizedString]];
            [nameLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:11]];
            [nameLabel setTextColor:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]];
            [nameLabel setNumberOfLines:0];
            [cell.contentView addSubview:nameLabel];
            attribs = @{
                        NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:10]
                        };
            expectedLabelSize = [temp boundingRectWithSize:CGSizeMake(200, 9999) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attribs context:nil].size;
            
        }
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(190,y+2,110,12)];
        [dateLabel setBackgroundColor:[UIColor clearColor]];
        
        NSString *milestoneDate = [dict objectForKey:@"created_at"];
        NSString *formattedTime = [profileDateUtils dailyLanguage:milestoneDate];
        
        [dateLabel setText:formattedTime];
        [dateLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10]];
        [dateLabel setTextColor:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]];
        [dateLabel setNumberOfLines:0];
        [dateLabel setTextAlignment:NSTextAlignmentRight];
        [cell.contentView addSubview:dateLabel];
        
        NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]};
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[dict objectForKey:@"text"]   attributes:attributes];
        UILabel *comment = [UILabel new];
        comment.numberOfLines = 0;
        comment.attributedText = attributedString;
        [cell.contentView addSubview:comment];
        
        expectedLabelSize = [comment sizeThatFits:CGSizeMake(198, 9999)];
        comment.frame =  CGRectMake(77, y+14, 203, expectedLabelSize.height);
        
        
        if(comment.frame.size.height+14 > 47)
            y+=expectedLabelSize.height+5+14;
        else
            y+=47+5;
        
        
        UILabel *line = [[UILabel alloc] initWithFrame: CGRectMake(20, y, 280, 0.5)];
        line.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        [line setTextAlignment:NSTextAlignmentLeft];
        line.backgroundColor = [UIColor colorWithRed:(204/255.f) green:(204/255.f) blue:(204/255.f) alpha:1];
        [cell.contentView addSubview:line];
        
        y+=5;
        
        
    }
    
    
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
    NSDictionary *dict = @{@"commenter": @{@"fname":sharedModel.userProfile.fname ,@"lname": sharedModel.userProfile.lname,@"photo":sharedModel.userProfile.image},@"editable": [NSNumber numberWithBool:YES],@"text":self.txt_comment};
   
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
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:postDetailsObject.content attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\::(.*?)\\::" options:NSRegularExpressionCaseInsensitive error:NULL];
    
    do{
        
        NSArray *myArray = [regex matchesInString:attributedString.string options:0 range:NSMakeRange(0, [attributedString.string length])] ;
        if(myArray.count > 0)
        {
            NSTextCheckingResult *match =  [myArray firstObject];
            NSRange matchRange = [match rangeAtIndex:1];
            NSLog(@"%@", [attributedString.string substringWithRange:matchRange]);
            
            UIImage  *image = [photoUtils squareImageWithImage:[UIImage imageNamed:@"EmptyProfilePic.jpg"] scaledToSize:CGSizeMake(262, 114)];
            NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
            textAttachment.image = image;
            NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
            [attributedString replaceCharactersInRange:match.range withAttributedString:attrStringWithImage];
        }
        else
        {
            break;
        }
        
    }while (1);
    
    CGRect contentSize = [attributedString boundingRectWithSize:CGSizeMake(262, CGFLOAT_MAX)
                                                        options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
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
                                            options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                            context:nil].size;
        height += tagsSize.height+10;
    
    
    //Comments list
    
    int taggedPhotosHeight1 = (([postDetailsObject.comments count]%9)!=0?1:0)+(int)[postDetailsObject.comments count]/9;
    height += taggedPhotosHeight1 * 30;
    
    NSArray *commentsArray = postDetailsObject.comments;
    
    for(int i=0;i<commentsArray.count;i++) //increase the size for each comment
    {
        NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12]};
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[[commentsArray objectAtIndex:i] objectForKey:@"text"]   attributes:attributes];
        
        UILabel *comment = [UILabel new];
        comment.numberOfLines = 0;
        comment.attributedText = attributedString;
        CGSize expectedLabelSize = [comment sizeThatFits:CGSizeMake(198, 9999)];
        
        if(expectedLabelSize.height+14 > 47) //if there is a lot of text
        {
            height+=expectedLabelSize.height+10+14;
        }
        else //set a default size
        {
            height+=47+10;
        }
    }
    
    return height;
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
