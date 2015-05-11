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
    streamTableView.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg-blur.png"]];
    streamTableView.backgroundColor = [UIColor clearColor];
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
    self.tagId = [recievedDict objectForKey:@"tag_id"];
    
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
    [self.delegate tagImage:[recievedDict objectForKey:@"tag_picture"]];
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
    if((isMostRecent || isFollowing) && indexPath.row == 0)
        return 171;
    else
    return 141;
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
    float yPosition = 5;
    
    
    UIImageView *backGroundImg  = [[UIImageView alloc] initWithFrame:CGRectMake(10, 17, 300, 124)];
    [backGroundImg setImage:[UIImage imageNamed:@"post-bg-wall.png"]];
    [cell.contentView addSubview:backGroundImg];

    
    //Profile Image
    UIImageView *profileImage  = [[UIImageView alloc] initWithFrame:CGRectMake(10, yPosition, 40, 40)];
    if(!postDetailsObject.anonymous)
    {
        __weak UIImageView *weakSelf = profileImage;

    [profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[postDetailsObject.owner objectForKey:@"photo"]]] placeholderImage:[UIImage imageNamed:@"icon-profile-register.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(40, 40)] withRadious:0];
         
     }failure:nil];
    }
    else
        [profileImage setImage:[UIImage imageNamed:@"icon-profile-register.png"]];

    
    [cell.contentView addSubview:profileImage];
    yPosition = 22;
    
    if((isMostRecent || isFollowing) && indexPath.row == 0)
    {
        profileImage.frame = CGRectMake(10, 35, 40, 40);
        backGroundImg.frame = CGRectMake(10, 47, 300, 124);
         yPosition = 50;
    }

    
    //Profile name
    if(!postDetailsObject.anonymous)
    {
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(55, yPosition, 150, 18)];
    [name setText:[NSString stringWithFormat:@"%@ %@",[postDetailsObject.owner objectForKey:@"fname"],[postDetailsObject.owner objectForKey:@"lname"]]];
    name.textAlignment = NSTextAlignmentLeft;
    [name setFont:[UIFont fontWithName:@"Ubuntu-Medium" size:14]];
    [name setTextColor:[UIColor blackColor]];
    [cell.contentView addSubview:name];
    }
    
    UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [profileButton addTarget:self action:@selector(profileButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    profileButton.tag = [[streamTableView indexPathForRowAtPoint:cell.center] row];
    [profileButton setFrame:CGRectMake(52, yPosition, 150, 18)];
    [cell.contentView addSubview:profileButton];

    UIButton *profileButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [profileButton1 addTarget:self action:@selector(profileButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    profileButton1.tag = [[streamTableView indexPathForRowAtPoint:cell.center] row];
    [profileButton1 setFrame:profileImage.frame];
    [cell.contentView addSubview:profileButton1];

    
    
    UIImageView *timeIcon  = [[UIImageView alloc] initWithFrame:CGRectMake(242, yPosition+5, 10, 10)];
    [timeIcon setImage:[UIImage imageNamed:@"time.png"]];
    [cell.contentView addSubview:timeIcon];

    //Time
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(254, yPosition+5, 55, 12)];
    [time setText:[profileDateUtils dailyLanguage:postDetailsObject.time]];
    [time setTextAlignment:NSTextAlignmentLeft];
    [time setTextColor:[UIColor colorWithRed:(153/255.f) green:(153/255.f) blue:(153/255.f) alpha:1]];
    [time setFont:[UIFont fontWithName:@"Ubuntu-Light" size:10]];
    [cell.contentView addSubview:time];

    
    UIImageView *heartCntImage  = [[UIImageView alloc] initWithFrame:CGRectMake(209, yPosition, 20, 20)];
    [heartCntImage setImage:[UIImage imageNamed:@"icon-upvote-gray.png"]];
    [cell.contentView addSubview:heartCntImage];
    
    UILabel *heartCount = [[UILabel alloc] initWithFrame:CGRectMake(229, yPosition+7, 10, 10)];
    [heartCount setText:postDetailsObject.time];
    [heartCount setTextAlignment:NSTextAlignmentLeft];
    [heartCount setText:[NSString stringWithFormat:@"%i",postDetailsObject.upVoteCount]];
    [heartCount setTextColor:[UIColor colorWithRed:(85/255.f) green:(85/255.f) blue:(85/255.f) alpha:1]];
    [heartCount setFont:[UIFont fontWithName:@"Ubuntu-Light" size:10]];
    [cell.contentView addSubview:heartCount];

    
    [self addDescription:cell withDetails:postDetailsObject :indexPath];
    
}
-(void)addDescription:(UITableViewCell *)cell withDetails:(PostDetails *)postDetailsObject :(NSIndexPath *)indexPath
{
    float yPosition = 45;
    
    //Description
    //Description
    UITextView *textView = [[UITextView alloc] init];
    
    if(postDetailsObject.content == nil)
        postDetailsObject.content = @"";
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:postDetailsObject.content attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Ubuntu-Light" size:15],NSForegroundColorAttributeName:[UIColor colorWithRed:(85/255.f) green:(85/255.f) blue:(85/255.f) alpha:1]}];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\::(.*?)\\::" options:NSRegularExpressionCaseInsensitive error:NULL];
    
    
    do{
        
        NSArray *myArray = [regex matchesInString:attributedString.string options:0 range:NSMakeRange(0, [attributedString.string length])] ;
        if(myArray.count > 0)
        {
            NSTextCheckingResult *match =  [myArray firstObject];
            NSRange matchRange = [match rangeAtIndex:1];
            NSLog(@"%@", [attributedString.string substringWithRange:matchRange]);
            
            UIImage  *image = [photoUtils makeRoundedCornersWithBorder:[UIImage imageNamed:@"placeHolder_wall.png"] withRadious:3.0];
            NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];

            textAttachment.image = image;
            
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
            [manager downloadImageWithURL:[NSURL URLWithString:[postDetailsObject.images objectForKey:[attributedString.string substringWithRange:matchRange]]] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                
                textAttachment.image = [photoUtils makeRoundedCornersWithBorder:[image resizedImageByMagick:@"26x16#"] withRadious:3.0];
                [textView setNeedsDisplay];
                
            }];
            //}
            NSMutableAttributedString *attrStringWithImage = [[NSMutableAttributedString alloc] init];
            if(attributedString.length >0 && ([attributedString.string characterAtIndex:attributedString.string.length-1] != '\n'))
            attrStringWithImage = [[NSMutableAttributedString alloc] initWithString:@"\n" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Ubuntu-Light" size:1]}];
            [attrStringWithImage appendAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
            [attributedString replaceCharactersInRange:match.range withAttributedString:attrStringWithImage];
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
    
    [cell.contentView addSubview:textView];
    

        textView.frame = CGRectMake(16, yPosition, 282, 45);
    
    CGSize size = [textView sizeThatFits:CGSizeMake(282, MAXFLOAT)];
    int numLines = size.height / [[UIFont fontWithName:@"Ubuntu-Light" size:15] lineHeight];

    
    if(numLines > 1)
        [textView setTextAlignment:NSTextAlignmentLeft];
    else
        [textView setTextAlignment:NSTextAlignmentCenter];

    yPosition += 45;
    
    STTweetLabel *tweetLabel;
    if([postDetailsObject.tags count] > 0)
    {
        tweetLabel = [[STTweetLabel alloc] initWithFrame:CGRectMake(15, 95, 290 , 15)];
        NSMutableArray *tagarray = [[NSMutableArray alloc] init];
        for(NSString *tag in postDetailsObject.tags)
            [tagarray addObject:[NSString stringWithFormat:@"%@",tag]];
        [tweetLabel setText:[tagarray componentsJoinedByString:@" "]];
        tweetLabel.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:tweetLabel];
        
        
        [tweetLabel setDetectionBlock:^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
            [self.delegate tagCicked:string];
            
        }];

        
        yPosition += 15;
    }
    

    
        NSMutableArray *commenters = [NSMutableArray arrayWithArray:postDetailsObject.commenters];
    
        UIView *commentersView = [[UIView alloc] initWithFrame:CGRectMake(15, 113, 290, 19)];
        [cell.contentView addSubview:commentersView];
        
        long int x = 0;
        
        if(commenters.count < 6)
        x = (290 - (19*(commenters.count+1) + 3*(commenters.count) ))/2;
        for(int i = 0; i < commenters.count; i++)
            //for(id dict in array)
        {
            if(i >= 6 || i == commenters.count)
            {
                break;
            }

            NSString *url = [commenters objectAtIndex:i];
            UIImageView *imagVw = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, 19, 19)];
            [commentersView addSubview:imagVw];
            
            __weak UIImageView *weakSelf = imagVw;
            
            
            [imagVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:[photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:[UIImage imageNamed:@"icon-profile-register.pngg"] scaledToSize:CGSizeMake(19,19)] withRadious:0] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(19, 19)] withRadious:0];
                 
             }failure:nil];
            

            x+= 19 + 3;
            
        }
    UIImageView *imagVw = [[UIImageView alloc] initWithFrame:CGRectMake(x, 3, 19, 19)];
    [imagVw setImage:[UIImage imageNamed:@"comment_Count.png"]];
    [commentersView addSubview:imagVw];
    
    if(postDetailsObject.commentCount > 0)
    {
        UILabel *tag = [[UILabel alloc] initWithFrame:CGRectMake(2, 3, 15 , 10)];
        [tag setText:[NSString stringWithFormat:@"%i",postDetailsObject.commentCount]];
        [tag setFont:[UIFont fontWithName:@"Ubuntu-Light" size:10]];
        [tag setTextAlignment:NSTextAlignmentCenter];
        [imagVw addSubview:tag];
    }

    if((isMostRecent || isFollowing) && indexPath.row == 0)
    {
        textView.frame = CGRectMake(16, 75, 282, 45);
        tweetLabel.frame = CGRectMake(15, 90+35, 290 , 16);
        commentersView.frame = CGRectMake(15, 108+35, 290, 19);
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