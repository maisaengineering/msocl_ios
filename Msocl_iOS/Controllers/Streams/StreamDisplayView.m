//
//  StreamDisplayView.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/8/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "StreamDisplayView.h"
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


@implementation StreamDisplayView
{
    ProfilePhotoUtils *photoUtils;
    ProfileDateUtils *profileDateUtils;
    UIRefreshControl *refreshControl;
    BOOL isMoreAvailabel;
    BOOL isPrevious;
    ModelManager *sharedModel;
    
    Webservices *webServices;
    
    BOOL bProcessing;
    BOOL isDragging;
    
}
@synthesize storiesArray;
@synthesize streamTableView;
@synthesize delegate;
@synthesize profileID;
@synthesize isMostRecent;
@synthesize isFollowing;
@synthesize isUserProfilePosts;
@synthesize timeStamp;
@synthesize userProfileId;
@synthesize isTag;
@synthesize tagName;
@synthesize tagId;
@synthesize isSearching;
@synthesize searchString;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self baseInit];
    }
    return self;
}
-(void)resetData
{
    self.postCount = 0;
    self.timeStamp = @"";
    self.etag = @"";
    
}
-(void)baseInit
{
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    
    photoUtils = [ProfilePhotoUtils alloc];
    profileDateUtils = [ProfileDateUtils alloc];
    [self setBackgroundColor:[UIColor clearColor]];
    sharedModel   = [ModelManager sharedModel];
    
  
    
    storiesArray = [[NSMutableArray alloc] init];
    streamTableView = [[UITableView alloc] initWithFrame:self.bounds];
    streamTableView.delegate = self;
    streamTableView.dataSource = self;
    streamTableView.tableFooterView = nil;
    streamTableView.tableHeaderView = nil;
    streamTableView.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
    [streamTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self addSubview:streamTableView];
    
    refreshControl = [[UIRefreshControl alloc] init];
    // refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    refreshControl.backgroundColor= [UIColor clearColor];
    
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [streamTableView addSubview:refreshControl];
    
}
-(void)handleRefresh:(id)sender
{
    //    UIRefreshControl *refresh = sender;
    //     refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    if (bProcessing) return;
    // Released above the header
    [self resetData];
    
    [self performSelectorInBackground:@selector(callStreamsApi:) withObject:@"next"];
    
}

#pragma mark -
#pragma mark API calls to get Stream data
-(void)callStreamsApi:(NSString *)step
{
    if(bProcessing)
        return;
    if(!bProcessing)
    {
        bProcessing = YES;
        
        AccessToken* token = sharedModel.accessToken;
        if(isSearching)
        {
            NSString *command = @"search";
            NSMutableDictionary *body = [[NSMutableDictionary alloc]init];
            [body setValue:self.timeStamp forKeyPath:@"last_modified"];
            [body setValue:self.postCount forKeyPath:@"post_count"];
            [body setValue:self.etag forKey:@"etag"];
            [body setValue:step forKeyPath:@"step"];

            [body setValue:searchString forKeyPath:@"text"];
            if(isFollowing)
                [body setValue:[NSNumber numberWithBool:YES] forKeyPath:@"favourites"];
            
            NSDictionary* postData = @{@"command": command,@"access_token": token.access_token,@"body":body};
            NSDictionary *userInfo = @{@"command": @"GetStreams"};
            
            NSString *urlAsString = [NSString stringWithFormat:@"%@posts",BASE_URL];
            [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];

        }
        else
        {
            NSMutableDictionary *body = [[NSMutableDictionary alloc]init];
            [body setValue:self.timeStamp forKeyPath:@"last_modified"];
            [body setValue:self.postCount forKeyPath:@"post_count"];
            [body setValue:self.etag forKey:@"etag"];
            [body setValue:step forKeyPath:@"step"];
            NSString *command = @"all";
            if(isFollowing)
            {
                [body setValue:@"favourites" forKeyPath:@"by"];
                command = @"filter";
            }
            else if(isUserProfilePosts)
            {
                [body setValue:userProfileId forKeyPath:@"key"];
                command = @"filter";
                
            }
            else if(isTag)
            {
                [body setValue:tagName forKeyPath:@"key"];
                [body setValue:@"tag" forKeyPath:@"by"];
                command = @"filter";
                
            }
            
            
            NSDictionary* postData = @{@"command": command,@"access_token": token.access_token,@"body":body};
            NSDictionary *userInfo = @{@"command": @"GetStreams"};
            
            NSString *urlAsString = [NSString stringWithFormat:@"%@posts",BASE_URL];
            [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];

        }
        
    }
}
-(void) didReceiveStreams:(NSDictionary *)recievedDict
{
    bProcessing = NO;
    
    NSArray *postArray = [recievedDict objectForKey:@"posts"];
    
    if([timeStamp length] == 0)
    {
        [self.storiesArray removeAllObjects];
    }
    
    if([postArray count] > 0)
    {
        
        if([storiesArray count] > 0)
        {
            
            [storiesArray addObjectsFromArray:postArray];
            
        }
        else
        {
            storiesArray = [postArray mutableCopy];
        }
        
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:storiesArray];
        storiesArray = [orderedSet.array mutableCopy];
        
        [streamTableView reloadData];
        
    }
    

    
    self.tagId = [[recievedDict objectForKey:@"tag"] objectForKey:@"uid"];
    [self.delegate tagImage:[[recievedDict objectForKey:@"tag"] objectForKey:@"image"]];
    [refreshControl endRefreshing];
    
    self.timeStamp = [recievedDict objectForKey:@"last_modified"];
    self.postCount = [recievedDict objectForKey:@"post_count"];
    self.etag = [recievedDict objectForKey:@"etag"];

    [self.delegate recievedData:[[recievedDict objectForKey:@"follows"] boolValue]];

}
-(void) streamsFailed
{
    bProcessing = NO;
    [refreshControl endRefreshing];
}

#pragma mark -
#pragma mark TableViewMethods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostDetails *postDetailsObject = [storiesArray objectAtIndex:indexPath.row];
    CGFloat height = 103;
    
    CGFloat descrHeight = [self cellHeight:postDetailsObject];
    height += descrHeight;
    
    if((isMostRecent || isFollowing) && indexPath.row == 0)
    {
        return height + 30;
    }
    else
    {
    return height;
    }
}
-(CGFloat)cellHeight:(PostDetails *)postDetailsObject
{
    //This default image height + 5 pixels up and 5 pixels down margin
    
    //Calculating content height
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:postDetailsObject.content attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Ubuntu-Light" size:14]}];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\::(.*?)\\::" options:NSRegularExpressionCaseInsensitive error:NULL];
    
    
    do{
        
        NSArray *myArray = [regex matchesInString:attributedString.string options:0 range:NSMakeRange(0, [attributedString.string length])] ;
        if(myArray.count > 0)
        {
            NSTextCheckingResult *match =  [myArray firstObject];
            UIImage  *image = [photoUtils squareImageWithImage:[UIImage imageNamed:@"placeHolder_wall.png"] scaledToSize:CGSizeMake(32, 32)];
            NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
            textAttachment.image = image;
            
            NSMutableAttributedString *attrStringWithImage = [[NSMutableAttributedString alloc] initWithString:@"\n" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Ubuntu-Light" size:1]}];
            [attrStringWithImage appendAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
            [attributedString replaceCharactersInRange:match.range withAttributedString:attrStringWithImage];
        }
        else
        {
            break;
        }
        
    }while (1);
    //This regex captures all items between []
    UITextView *textView = [UITextView new];
    textView.attributedText = attributedString;
    
    
    CGSize contentSize = [textView sizeThatFits:CGSizeMake(230, CGFLOAT_MAX)];
    
    if(contentSize.height > 80)
        contentSize.height = 80;
    return contentSize.height;
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
    
    cell.backgroundColor = [UIColor clearColor];
    [self buildCell:cell withDetails:postDetailsObject :indexPath];
    
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate tableDidSelect:(int)indexPath.row];
}
-(void)buildCell:(UITableViewCell *)cell withDetails:(PostDetails *)postDetailsObject :(NSIndexPath *)indexPath
{
    float yPosition = 3;
    
    CGSize size = [streamTableView rectForRowAtIndexPath:indexPath].size;
    UIView *backGround  = [[UIView alloc] initWithFrame:CGRectMake(10, 16, 300, size.height-16)];
    backGround.backgroundColor = [UIColor whiteColor];
    [cell.contentView addSubview:backGround];

    
    //Profile Image
    UIImageView *profileImage  = [[UIImageView alloc] initWithFrame:CGRectMake(17, yPosition, 40, 40)];
    if(!postDetailsObject.anonymous)
    {
        __weak UIImageView *weakSelf = profileImage;

    [profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[postDetailsObject.owner objectForKey:@"photo"]]] placeholderImage:[UIImage imageNamed:@"icon-profile-register.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(40, 40)] withRadious:0];
         
     }failure:nil];
    }
    else
    {
        
            __weak UIImageView *weakSelf = profileImage;
            
            [profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"anonymous_image"]]] placeholderImage:[UIImage imageNamed:@"icon-profile-register.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(40, 40)] withRadious:0];
                 
             }failure:nil];
        
    }
    
    [cell.contentView addSubview:profileImage];
    yPosition = 16;
    
    if((isMostRecent || isFollowing) && indexPath.row == 0)
    {
        CGRect frame = profileImage.frame;
        frame.origin.y += 30;
        profileImage.frame = frame;
        
        frame = backGround.frame;
        frame.origin.y += 30;
        frame.size.height -= 30;
        backGround.frame = frame;
        
         yPosition += 30;
    }
    backGround.layer.borderColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1.0].CGColor;
    backGround.layer.borderWidth = 1.0f;
    backGround.layer.cornerRadius = 5;
    backGround.layer.masksToBounds = YES;

    //Profile name
    if(!postDetailsObject.anonymous)
    {
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(60, yPosition, 150, 30)];
        if(([postDetailsObject.owner objectForKey:@"fname"] != (id)[NSNull null] && [[postDetailsObject.owner objectForKey:@"fname"] length] > 0) &&
           ([postDetailsObject.owner objectForKey:@"lname"] != (id)[NSNull null] && [[postDetailsObject.owner objectForKey:@"lname"] length] > 0)
           )
            [name setText:[NSString stringWithFormat:@"%@ %@",[postDetailsObject.owner objectForKey:@"fname"],[postDetailsObject.owner objectForKey:@"lname"]]];
        else
            [name setText:@""];
    name.textAlignment = NSTextAlignmentLeft;
    [name setFont:[UIFont fontWithName:@"Ubuntu" size:15]];
    [name setTextColor:[UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:1.0]];
    [cell.contentView addSubview:name];
    }
    
    UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [profileButton addTarget:self action:@selector(profileButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    profileButton.tag = [[streamTableView indexPathForRowAtPoint:cell.center] row];
    [profileButton setFrame:CGRectMake(60, yPosition, 150, 18)];
    [cell.contentView addSubview:profileButton];

    UIButton *profileButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    //    profileButton1.tag = [[streamTableView indexPathForRowAtPoint:cell.center] row];
    profileButton1.tag = indexPath.row;
    [profileButton1 setFrame:profileImage.frame];
    [profileButton1 addTarget:self action:@selector(profileButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:profileButton1];

    
    
    UIImageView *timeIcon  = [[UIImageView alloc] initWithFrame:CGRectMake(242, yPosition+8, 13, 13)];
    [timeIcon setImage:[UIImage imageNamed:@"time.png"]];
    [cell.contentView addSubview:timeIcon];
    
    //Time
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(256, yPosition+9, 55, 12)];
    [time setText:[profileDateUtils dailyLanguage:postDetailsObject.time]];
    [time setTextAlignment:NSTextAlignmentLeft];
    [time setTextColor:[UIColor colorWithRed:(153/255.f) green:(153/255.f) blue:(153/255.f) alpha:1]];
    [time setFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:10]];
    [cell.contentView addSubview:time];
    
    
    UIImageView *heartCntImage  = [[UIImageView alloc] initWithFrame:CGRectMake(209, yPosition+3, 18, 18)];
    [heartCntImage setImage:[UIImage imageNamed:@"icon-upvote-gray.png"]];
    [cell.contentView addSubview:heartCntImage];
    
    UILabel *heartCount = [[UILabel alloc] initWithFrame:CGRectMake(228, yPosition+9, 10, 10)];
    [heartCount setText:postDetailsObject.time];
    [heartCount setTextAlignment:NSTextAlignmentLeft];
    [heartCount setText:[NSString stringWithFormat:@"%i",postDetailsObject.upVoteCount]];
    [heartCount setTextColor:[UIColor colorWithRed:(153/255.f) green:(153/255.f) blue:(153/255.f) alpha:1]];
    [heartCount setFont:[UIFont fontWithName:@"Ubuntu-Light" size:10]];
    [cell.contentView addSubview:heartCount];
    
    [self addDescription:cell withDetails:postDetailsObject :indexPath];
    
}
-(void)addDescription:(UITableViewCell *)cell withDetails:(PostDetails *)postDetailsObject :(NSIndexPath *)indexPath
{
    float yPosition = 43;
    
    //Description
    //Description
    UITextView *textView = [[UITextView alloc] init];
    
    if(postDetailsObject.content == nil)
        postDetailsObject.content = @"";
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:postDetailsObject.content attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Ubuntu-Light" size:14],NSForegroundColorAttributeName:[UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:1.0]}];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\::(.*?)\\::" options:NSRegularExpressionCaseInsensitive error:NULL];
    
    
    do{
        
        NSArray *myArray = [regex matchesInString:attributedString.string options:0 range:NSMakeRange(0, [attributedString.string length])] ;
        if(myArray.count > 0)
        {
            NSTextCheckingResult *match =  [myArray firstObject];
            NSRange matchRange = [match rangeAtIndex:1];
            NSLog(@"%@", [attributedString.string substringWithRange:matchRange]);
            
            UIImage  *image = [photoUtils makeRoundedCornersWithBorder:[photoUtils squareImageWithImage:[UIImage imageNamed:@"placeHolder_wall.png"] scaledToSize:CGSizeMake(32, 32)] withRadious:3.0];
            NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];

            textAttachment.image = image;
            
            NSString *url = [postDetailsObject.images objectForKey:[attributedString.string substringWithRange:matchRange]];
            
            NSMutableAttributedString *attrStringWithImage = [[NSMutableAttributedString alloc] init];
                attrStringWithImage = [[NSMutableAttributedString alloc] initWithString:@"\n" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Ubuntu-Light" size:1]}];
            [attrStringWithImage appendAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
            [attributedString replaceCharactersInRange:match.range withAttributedString:attrStringWithImage];

            
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
           /* if(postDetailsObject.thumb_images != nil && postDetailsObject.thumb_images.count > 0)
            {
                [manager downloadImageWithURL:[NSURL URLWithString:[postDetailsObject.thumb_images objectForKey:[attributedString.string substringWithRange:matchRange]]] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    
                    textAttachment.image = [photoUtils makeRoundedCornersWithBorder:[image resizedImageByMagick:@"26x16#"] withRadious:3.0];
                    [textView setNeedsDisplay];
                    
                }];
            }
            else
            {*/
            [manager downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                
                if(cacheType == SDImageCacheTypeNone)
                {
                    NSArray* rowsToReload = [NSArray arrayWithObjects:indexPath, nil];
                    [streamTableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                }
                else
                {
                    textAttachment.image = [photoUtils makeRoundedCornersWithBorder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(32, 32)] withRadious:3.0];
                    image.accessibilityIdentifier = textAttachment.image.accessibilityIdentifier;
                    NSRange range = [attributedString.string rangeOfString:attrStringWithImage.string];
                    NSMutableAttributedString *attrStringWithImage = [[NSMutableAttributedString alloc] init];
                        attrStringWithImage = [[NSMutableAttributedString alloc] initWithString:@"\n" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Ubuntu-Light" size:1]}];
                    [attrStringWithImage appendAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
                    
                    [attributedString replaceCharactersInRange:range withAttributedString:attrStringWithImage];
                    
                    textView.attributedText = attributedString;
                }
                
                
            }];
            //}
        }
        else
        {
            break;
        }
        
    }while (1);
    //This regex captures all items between []
    
    textView.editable = NO;
    textView.scrollEnabled = NO;
    textView.attributedText = attributedString;
    textView.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:(85/255.f) green:(85/255.f) blue:(85/255.f) alpha:1]};
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedTextView:)];
    [textView setDataDetectorTypes:UIDataDetectorTypeLink];
    [textView addGestureRecognizer:tapRecognizer];
    textView.selectable = YES;
    textView.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:textView];
    

    CGSize contentSize = [textView sizeThatFits:CGSizeMake(230, CGFLOAT_MAX)];

    
    if((isMostRecent || isFollowing) && indexPath.row == 0)

    {
        if(contentSize .height > 80)
        {
            textView.frame = CGRectMake(60, yPosition+30, 230, 80);
            
        }
        else
            textView.frame = CGRectMake(60, yPosition+30, 230, contentSize.height);

    }
    else
    {
        if(contentSize .height > 80)
        {
            textView.frame = CGRectMake(60, yPosition, 230, 80);
            
        }
        else
            textView.frame = CGRectMake(60, yPosition, 230, contentSize.height);

    }
    

    yPosition += textView.frame.size.height;
    
    
    UIImageView *lineImage  =[[UIImageView alloc] initWithFrame:CGRectMake(10, yPosition, 300, 1)];
    lineImage.backgroundColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1.0];
    [cell.contentView addSubview:lineImage];
    
    
   /* STTweetLabel *tweetLabel;
    if([postDetailsObject.tags count] > 0)
    {
        tweetLabel = [[STTweetLabel alloc] initWithFrame:CGRectMake(15, yPosition, 290 , 30)];
        NSMutableArray *tagarray = [[NSMutableArray alloc] init];
        for(NSString *tag in postDetailsObject.tags)
            [tagarray addObject:[NSString stringWithFormat:@"%@",tag]];
        [tweetLabel setText:[tagarray componentsJoinedByString:@" "]];
        tweetLabel.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:tweetLabel];
        
        
        [tweetLabel setDetectionBlock:^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
            [self.delegate tagCicked:string];
            
        }];

        
        yPosition += 30;
    }
    */
    
        UIView *tagsView = [[UIView alloc] initWithFrame:CGRectMake(15, yPosition, 290, 30)];
        [cell.contentView addSubview:tagsView];
        NSArray *tagsArray = postDetailsObject.tags;
        int xPosition =0;
        for(int i=0; i <tagsArray.count ;i++)
        {
            NSString *tagNameStr = tagsArray[i];
            CGSize size = [tagNameStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
            
            if(size.width + xPosition >= 290)
               break;
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
            btn.layer.borderColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1.0].CGColor;
            btn.layer.borderWidth = 1.0f;
            btn.layer.cornerRadius = 5;
            btn.layer.masksToBounds = YES;
            [btn setTitle:tagNameStr forState:UIControlStateNormal];
            [btn.titleLabel setFont:[UIFont fontWithName:@"Ubuntu-Light" size:10]];
            [btn addTarget:self action:@selector(tagClicked:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitleColor:[UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1.0] forState:UIControlStateNormal];
            [tagsView addSubview:btn];
            btn.frame = CGRectMake(xPosition, 6, size.width, 20);
            
            xPosition += btn.frame.size.width + 3;
        }
        if(xPosition < 290)
        {
             CGRect frame = tagsView.frame;
            frame.size.width = xPosition-3;
            frame.origin.x = (320 - frame.size.width)/2.0;
            tagsView.frame = frame;
            
        }
        yPosition += 30;
    

    
        NSMutableArray *commenters = [NSMutableArray arrayWithArray:postDetailsObject.commenters];
    
        UIView *commentersView = [[UIView alloc] initWithFrame:CGRectMake(15, yPosition, 290, 30)];
        [cell.contentView addSubview:commentersView];
        
        long int x = 0;
        
        if(commenters.count < 6)
        x = (290 - (22*(commenters.count+1) + 3*(commenters.count) ))/2;
        for(int i = 0; i < commenters.count; i++)
            //for(id dict in array)
        {
            if(i >= 6 || i == commenters.count)
            {
                break;
            }

            NSString *url = [commenters objectAtIndex:i];
            UIImageView *imagVw = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, 22, 22)];
            [commentersView addSubview:imagVw];
            
            __weak UIImageView *weakSelf = imagVw;
            
            
            [imagVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:[photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:[UIImage imageNamed:@"icon-profile-register.pngg"] scaledToSize:CGSizeMake(22,22)] withRadious:0] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(22, 22)] withRadious:0];
                 
             }failure:nil];
            

            x+= 22 + 3;
            
        }
    UIImageView *imagVw = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, 22, 26)];
    [imagVw setImage:[UIImage imageNamed:@"comment_Count.png"]];
    [commentersView addSubview:imagVw];
    
    if(postDetailsObject.commentCount > 0)
    {
        UILabel *tag = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 22 , 22)];
        [tag setText:[NSString stringWithFormat:@"%i",postDetailsObject.commentCount]];
        [tag setTextColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0]];
        [tag setFont:[UIFont fontWithName:@"Ubuntu-Light" size:12]];
        [tag setTextAlignment:NSTextAlignmentCenter];
        [imagVw addSubview:tag];
    }

    if((isMostRecent || isFollowing) && indexPath.row == 0)
    {
        CGRect frame =  lineImage.frame;
        frame.origin.y += 30;
        lineImage.frame = frame;
        
        
         frame =  tagsView.frame;
        frame.origin.y += 30;
        tagsView.frame = frame;
        
         frame =  commentersView.frame;
        frame.origin.y += 30;
        commentersView.frame = frame;
        
    }
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
    
    if(indexPath.row == storiesArray.count - 2)
        [self callStreamsApi:@"next"];
}

-(void)profileButtonClicked:(id)sender
{
    // Resrict the anonymous users
    PostDetails *postObject = [storiesArray objectAtIndex:(int)[sender tag]];
    if (!postObject.anonymous)
    {
        [self.delegate userProifleClicked:(int)[sender tag]];
    }
}
-(void)tagClicked:(id)sender
{
    UIButton *btn = sender;
    [self.delegate tagCicked:[btn titleForState:UIControlStateNormal]];

}
- (void)tappedTextView:(UITapGestureRecognizer *)tapGesture {
    if (tapGesture.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    UITextView *textView = (UITextView *)tapGesture.view;
    CGPoint tapLocation = [tapGesture locationInView:textView];
    UITextPosition *textPosition = [textView closestPositionToPoint:tapLocation];
    NSDictionary *attributes = [textView textStylingAtPosition:textPosition inDirection:UITextStorageDirectionForward];
    
    NSURL *url = attributes[NSLinkAttributeName];
    
    if (url) {
        
        [[UIApplication sharedApplication] openURL:url];
        return;
    }
    else
    {
        NSIndexPath *indexPath = [streamTableView indexPathForCell:(UITableViewCell *)textView.superview.superview];

        [self.delegate tableDidSelect:(int)indexPath.row];
    }
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
    {
        [self.delegate tableScrolled:scrollView.contentOffset.y];
    }
@end