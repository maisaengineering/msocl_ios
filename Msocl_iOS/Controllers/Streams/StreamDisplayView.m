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
#import "UIImage+GIF.h"

@implementation StreamDisplayView
{
    ProfilePhotoUtils *photoUtils;
    ProfileDateUtils *profileDateUtils;
    UIRefreshControl *refreshControl;
    BOOL isMoreAvailabel;
    BOOL isPrevious;
    ModelManager *sharedModel;
    
    Webservices *webServices;
    
    
    BOOL isDragging;
    float lastContentOffset;
    
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
@synthesize bProcessing;
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
    
    
    if(isFollowing &&  [[NSUserDefaults standardUserDefaults] objectForKey:@"favStreamArray"] != nil)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *encodedObject = [defaults objectForKey:@"favStreamArray"];
        NSArray *arrayPostDetails = [[NSKeyedUnarchiver unarchiveObjectWithData:encodedObject] mutableCopy];
        
        NSMutableArray *arrayOfpostDetailsObjects=[NSMutableArray arrayWithCapacity:0];
        
        for(NSDictionary *postDict in arrayPostDetails)
        {
            PostDetails *postObject = [[PostDetails alloc] initWithDictionary:postDict];
            [arrayOfpostDetailsObjects addObject:postObject];
        }
        
        storiesArray = arrayOfpostDetailsObjects;
    }
    else if(isMostRecent &&  [[NSUserDefaults standardUserDefaults] objectForKey:@"mostRecentStreamArray"] != nil)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *encodedObject = [defaults objectForKey:@"mostRecentStreamArray"];
        NSArray *arrayPostDetails = [[NSKeyedUnarchiver unarchiveObjectWithData:encodedObject] mutableCopy];
        
        NSMutableArray *arrayOfpostDetailsObjects=[NSMutableArray arrayWithCapacity:0];
        
        for(NSDictionary *postDict in arrayPostDetails)
        {
            PostDetails *postObject = [[PostDetails alloc] initWithDictionary:postDict];
            [arrayOfpostDetailsObjects addObject:postObject];
        }
        
        storiesArray = arrayOfpostDetailsObjects;
        
    }
    
    
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
            
            NSString *urlAsString = [NSString stringWithFormat:@"%@v2/posts",BASE_URL];
            [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
            
        }
        else
        {
            NSMutableDictionary *body = [[NSMutableDictionary alloc]init];
            [body setValue:self.timeStamp forKeyPath:@"last_modified"];
            [body setValue:self.postCount forKeyPath:@"post_count"];
            [body setValue:self.etag forKey:@"etag"];
            [body setValue:step forKeyPath:@"step"];
            NSString *command = @"filter";
            if(isFollowing)
            {
                [body setValue:@"favourites" forKeyPath:@"by"];
            }
            else if(isUserProfilePosts)
            {
                [body setValue:userProfileId forKeyPath:@"key"];
                [body setValue:@"user" forKeyPath:@"by"];
                
            }
            else if(isTag)
            {
                [body setValue:tagName forKeyPath:@"key"];
                [body setValue:@"tag" forKeyPath:@"by"];
                
            }
            
            
            NSDictionary* postData = @{@"command": command,@"access_token": token.access_token,@"body":body};
            NSDictionary *userInfo = @{@"command": @"GetStreams"};
            
            NSString *urlAsString = [NSString stringWithFormat:@"%@v2/posts",BASE_URL];
            [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
            
        }
        
    }
}
-(void) didReceiveStreams:(NSDictionary *)recievedDict originalPosts:(NSArray *)posts
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
    
    
    
    [refreshControl endRefreshing];
    
    self.timeStamp = [recievedDict objectForKey:@"last_modified"];
    self.postCount = [recievedDict objectForKey:@"post_count"];
    self.etag = [recievedDict objectForKey:@"etag"];
    
    [self.delegate recievedData:[[recievedDict objectForKey:@"follows"] boolValue]];
    
  //  [streamTableView reloadData];
    
    if(isMostRecent)
    {
        if(posts.count > 0)
        {
            NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:posts];
            [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:@"mostRecentStreamArray"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    else if(isFollowing)
    {
        if(posts.count > 0)
        {
            NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:posts];
            [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:@"favStreamArray"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    
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
    
    if(postDetailsObject.postImage != nil && postDetailsObject.postImage.length > 0)
        height += 100+8;
    else
        height += 3;
    if(!postDetailsObject.anonymous && [postDetailsObject.owner objectForKey:@"pinch_handle"] != nil && [[postDetailsObject.owner objectForKey:@"pinch_handle"] length] > 0 && ([[postDetailsObject.owner objectForKey:@"fname"] length] >0 || [[postDetailsObject.owner objectForKey:@"lname"] length] > 0)  )
    {
        height += 20;
    }
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
    
    
    NIAttributedLabel *textView = [NIAttributedLabel new];
    textView.font = [UIFont fontWithName:@"SanFranciscoText-Light" size:14];
    textView.numberOfLines = 0;
    
    //Calculating content height
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:postDetailsObject.content attributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14]}];
    
    textView.attributedText = attributedString;
    
    
    CGSize contentSize = [textView sizeThatFits:CGSizeMake(230, CGFLOAT_MAX)];
    
    
    
    if(contentSize.height > 53)
        contentSize.height = 53;
    
    return contentSize.height+5;
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
        
        NSMutableString *parentFnameInitial = [[NSMutableString alloc] init];
        if([postDetailsObject.owner valueForKey:@"fname"] != (id)[NSNull null] && [[postDetailsObject.owner valueForKey:@"fname"] length] >0)
            [parentFnameInitial appendString:[[[postDetailsObject.owner valueForKey:@"fname"] substringToIndex:1] uppercaseString]];
        if([postDetailsObject.owner valueForKey:@"lname"] != (id)[NSNull null] && [[postDetailsObject.owner valueForKey:@"lname"] length]>0)
            [parentFnameInitial appendString:[[[postDetailsObject.owner valueForKey:@"lname"] substringToIndex:1] uppercaseString]];
        
        if(parentFnameInitial.length < 1)
        {
            if( [[postDetailsObject.owner valueForKey:@"pinch_handle"] length] >0)
                [parentFnameInitial appendString:[[[postDetailsObject.owner valueForKey:@"pinch_handle"] substringToIndex:1] uppercaseString]];
            if( [[postDetailsObject.owner valueForKey:@"pinch_handle"] length] >1)
                [parentFnameInitial appendString:[[[postDetailsObject.owner valueForKey:@"pinch_handle"] substringWithRange:NSMakeRange(1, 1)] uppercaseString]];
            
        }

        NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:parentFnameInitial
                                               attributes:nil];
        NSRange range;
        if(parentFnameInitial.length > 0)
        {
            range.location = 0;
            range.length = 1;
            [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:16]}
                                    range:range];
        }
        if(parentFnameInitial.length > 1)
        {
            range.location = 1;
            range.length = 1;
            [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:16]}
                                    range:range];
        }
        
        
        //add initials
        
        UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        initial.attributedText = attributedText;
        [initial setBackgroundColor:[UIColor clearColor]];
        initial.textAlignment = NSTextAlignmentCenter;
        [profileImage addSubview:initial];
        
        
        [profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[postDetailsObject.owner objectForKey:@"photo"]]] placeholderImage:[UIImage imageNamed:@"circle-80.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(40, 40)] withRadious:0];
             [initial removeFromSuperview];
             
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
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(60, yPosition, 110, 30)];
        if(([postDetailsObject.owner objectForKey:@"fname"] != (id)[NSNull null] && [[postDetailsObject.owner objectForKey:@"fname"] length] > 0) ||
           ([postDetailsObject.owner objectForKey:@"lname"] != (id)[NSNull null] && [[postDetailsObject.owner objectForKey:@"lname"] length] > 0)
           )
            [name setText:[NSString stringWithFormat:@"%@ %@",[postDetailsObject.owner objectForKey:@"fname"],[postDetailsObject.owner objectForKey:@"lname"]]];
        else
            [name setText:@""];
        name.textAlignment = NSTextAlignmentLeft;
        [name setFont:[UIFont fontWithName:@"SanFranciscoText-Regular" size:15]];
        [name setTextColor:[UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:1.0]];
        [cell.contentView addSubview:name];
        if([postDetailsObject.owner objectForKey:@"pinch_handle"] != nil && [[postDetailsObject.owner objectForKey:@"pinch_handle"] length] > 0 )
        {
            UILabel * handle = [[UILabel alloc] initWithFrame:CGRectMake(60, yPosition+25, 200, 20)];
            [handle setText:[NSString stringWithFormat:@"@%@",[postDetailsObject.owner objectForKey:@"pinch_handle"]]];
            
            [handle setTextColor:[UIColor lightGrayColor]];
            [handle setFont:[UIFont fontWithName:@"SanFranciscoText-Light" size:14]];
            [cell.contentView addSubview:handle];
            
            
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [btn addTarget:self action:@selector(profileButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [cell.contentView addSubview:btn];
            if(([[postDetailsObject.owner objectForKey:@"fname"] length] >0 || [[postDetailsObject.owner objectForKey:@"lname"] length]) )
            {
                btn.frame = CGRectMake(60, yPosition+25, 200, 20);
            }
            else
            {
                handle.frame = CGRectMake(60, yPosition, 110, 30);
                btn.frame = CGRectMake(60, yPosition, 110, 30);
            }
        }
    }
    else
    {
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(60, yPosition, 110, 30)];
        [name setText:@"anonymous"];
        name.textAlignment = NSTextAlignmentLeft;
        [name setFont:[UIFont fontWithName:@"SanFranciscoText-Regular" size:15]];
        [name setTextColor:[UIColor grayColor]];
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
    
    
    UIImageView *heartCntImage  = [[UIImageView alloc] initWithFrame:CGRectMake(211, yPosition+3, 18, 18)];
    [heartCntImage setImage:[UIImage imageNamed:@"icon-upvote-gray.png"]];
    [cell.contentView addSubview:heartCntImage];
    
    UILabel *heartCount = [[UILabel alloc] initWithFrame:CGRectMake(230, yPosition+9, 10, 10)];
    [heartCount setText:postDetailsObject.time];
    [heartCount setTextAlignment:NSTextAlignmentLeft];
    [heartCount setText:[NSString stringWithFormat:@"%i",postDetailsObject.upVoteCount]];
    [heartCount setTextColor:[UIColor colorWithRed:(153/255.f) green:(153/255.f) blue:(153/255.f) alpha:1]];
    [heartCount setFont:[UIFont fontWithName:@"SanFranciscoText-Light" size:8]];
    [cell.contentView addSubview:heartCount];
    
    UIImageView *viewsCntImage  = [[UIImageView alloc] initWithFrame:CGRectMake(173, yPosition+7.5, 22, 13)];
    [viewsCntImage setImage:[UIImage imageNamed:@"icon-view-count.png"]];
    [cell.contentView addSubview:viewsCntImage];
    
    UILabel *viewsCount = [[UILabel alloc] initWithFrame:CGRectMake(195.5f, yPosition+9, 20, 10)];
    [viewsCount setText:postDetailsObject.time];
    [viewsCount setTextAlignment:NSTextAlignmentLeft];
    [viewsCount setText:[NSString stringWithFormat:@"%i",postDetailsObject.viewsCount]];
    [viewsCount setTextColor:[UIColor colorWithRed:(153/255.f) green:(153/255.f) blue:(153/255.f) alpha:1]];
    [viewsCount setFont:[UIFont fontWithName:@"SanFranciscoText-Light" size:8]];
    [cell.contentView addSubview:viewsCount];
    
    
    [self addDescription:cell withDetails:postDetailsObject :indexPath];
    
}
-(void)addDescription:(UITableViewCell *)cell withDetails:(PostDetails *)postDetailsObject :(NSIndexPath *)indexPath
{
    float yPosition = 43;
    
    if([postDetailsObject.owner objectForKey:@"pinch_handle"] != nil && [[postDetailsObject.owner objectForKey:@"pinch_handle"] length] > 0 && (([[postDetailsObject.owner objectForKey:@"fname"] length] >0 || [[postDetailsObject.owner objectForKey:@"lname"] length] > 0) || postDetailsObject.anonymous))
        yPosition += 20;
    NIAttributedLabel *textView = [NIAttributedLabel new];
    
    if(postDetailsObject.content == nil)
        postDetailsObject.content = @"";
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:postDetailsObject.content attributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14],NSForegroundColorAttributeName:[UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:1.0]}];
    
    
    textView.numberOfLines = 0;
    textView.delegate = self;
    textView.autoDetectLinks = YES;
    textView.attributedText = attributedString;
    textView.font = [UIFont fontWithName:@"SanFranciscoText-Light" size:14];
    [cell.contentView addSubview:textView];
    
    
    CGSize contentSize = [textView sizeThatFits:CGSizeMake(230, CGFLOAT_MAX)];
    
    
    if((isMostRecent || isFollowing) && indexPath.row == 0)
        
    {
        if(contentSize .height > 53)
        {
            textView.frame = CGRectMake(61, yPosition+30, 230, 53);
            
        }
        else
            textView.frame = CGRectMake(61, yPosition+30, 230, contentSize.height);
        
    }
    else
    {
        if(contentSize .height > 53)
        {
            textView.frame = CGRectMake(61, yPosition, 230, 53);
            
        }
        else
            textView.frame = CGRectMake(61, yPosition, 230, contentSize.height);
        
    }
    
    yPosition += textView.frame.size.height+5;
    UIImageView *postImage;
    if(postDetailsObject.postImage != nil && postDetailsObject.postImage.length > 0)
    {
        postImage = [[UIImageView alloc] initWithFrame:CGRectMake(144, yPosition+34, 32, 32)];
        UIImage  *image = [UIImage sd_animatedGIFNamed:@"Preloader_2"];
        
        __weak UIImageView *weakSelf = postImage;
        
        [postImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:postDetailsObject.postImage]] placeholderImage:image success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             weakSelf.image = [photoUtils makeRoundedCornersWithBorder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)] withRadious:10.0];
             CGRect frame = weakSelf.frame;
             weakSelf.frame = CGRectMake(110, frame.origin.y-34, 100, 100);
             CATransition *transition = [CATransition animation];
             transition.duration = 1.0f;
             transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
             transition.type = kCATransitionFade;
             [weakSelf.layer addAnimation:transition forKey:nil];

             
         }failure:nil];
        
        yPosition += 100+8;
        
        [cell.contentView addSubview:postImage];
    }
    else
        yPosition += 3;
    
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
        [btn.titleLabel setFont:[UIFont fontWithName:@"SanFranciscoText-Light" size:10]];
        [btn addTarget:self action:@selector(tagClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
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
    else
        x = (290 - (22*(7) + 3*6 ))/2;
    for(int i = 0; i < commenters.count; i++)
        //for(id dict in array)
    {
        if(i >= 6 || i == commenters.count)
        {
            break;
        }
        
        NSDictionary *dict = [commenters objectAtIndex:i];
        UIImageView *imagVw = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, 22, 22)];
        [commentersView addSubview:imagVw];
        
        if([dict objectForKey:@"photo"] != nil && [[dict objectForKey:@"photo"] length] >0 )
        {
        __weak UIImageView *weakSelf = imagVw;
        
        
        [imagVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[dict objectForKey:@"photo"]]] placeholderImage:[photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:[UIImage imageNamed:@"icon-profile-register.pngg"] scaledToSize:CGSizeMake(22,22)] withRadious:0] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
                 weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(22, 22)] withRadious:0];
             
         }failure:nil];
        }
        else if([dict objectForKey:@"fname"] != nil || [dict objectForKey:@"lname"] != nil)
        {
            [imagVw setImage:[UIImage imageNamed:@"circle-56.png"]];
            NSMutableString *parentFnameInitial = [[NSMutableString alloc] init];
            if([dict objectForKey:@"fname"] != (id)[NSNull null] && [[dict objectForKey:@"fname"] length] >0)
                [parentFnameInitial appendString:[[[dict objectForKey:@"fname"] substringToIndex:1] uppercaseString]];
            if([dict objectForKey:@"lname"] != (id)[NSNull null] && [[dict objectForKey:@"lname"] length]>0)
                [parentFnameInitial appendString:[[[dict objectForKey:@"lname"] substringToIndex:1] uppercaseString]];
            NSMutableAttributedString *attributedText =
            [[NSMutableAttributedString alloc] initWithString:parentFnameInitial
                                                   attributes:nil];
            NSRange range;
            if(parentFnameInitial.length > 0)
            {
                range.location = 0;
                range.length = 1;
                [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:12]}
                                        range:range];
            }
            if(parentFnameInitial.length > 1)
            {
                range.location = 1;
                range.length = 1;
                [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:12]}
                                        range:range];
            }
            
            
            //add initials
            
            UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
            initial.attributedText = attributedText;
            [initial setBackgroundColor:[UIColor clearColor]];
            initial.textAlignment = NSTextAlignmentCenter;
            [imagVw addSubview:initial];
            

            
        }
        else if([dict objectForKey:@"anonymous"] != nil && [[dict objectForKey:@"anonymous"] boolValue] )
        {
            __weak UIImageView *weakSelf = imagVw;
            
            
            [imagVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"anonymous_image"]]] placeholderImage:[photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:[UIImage imageNamed:@"icon-profile-register.pngg"] scaledToSize:CGSizeMake(22,22)] withRadious:0] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                     weakSelf.image = image;

             }failure:nil];
        }
        
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
        [tag setFont:[UIFont fontWithName:@"SanFranciscoText-Light" size:12]];
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
        
        frame =  postImage.frame;
        frame.origin.y += 30;
        postImage.frame = frame;
        
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

- (void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point {
    if (result.resultType == NSTextCheckingTypeLink) {
        [[UIApplication sharedApplication] openURL:result.URL];
    }
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
        
        [self.delegate tableDidSelect:(int)textView.tag];
    }
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.delegate tableScrolledForTopView:scrollView.contentOffset.y];
    
    if (lastContentOffset > scrollView.contentOffset.y)
    {
    }
    else if (lastContentOffset < scrollView.contentOffset.y)
    {
        [self.delegate tableScrolled:scrollView.contentOffset.y];
    }
    lastContentOffset = scrollView.contentOffset.y;
    
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = -100;
    if(y > h + reload_distance)
    {
        if(!bProcessing)
        [self callStreamsApi:@"next"];

    }
}
@end