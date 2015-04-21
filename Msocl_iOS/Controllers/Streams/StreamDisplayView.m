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
@synthesize timeStamp;

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
    streamTableView.backgroundColor = [UIColor colorWithRed:(229/255.f) green:(225/255.f) blue:(221/255.f) alpha:1];
    [streamTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self addSubview:streamTableView];
    
    refreshControl = [[UIRefreshControl alloc] init];
    // refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    refreshControl.backgroundColor= [UIColor colorWithRed:(229/255.f) green:(225/255.f) blue:(221/255.f) alpha:1];
    
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
        
        NSMutableDictionary *body = [[NSMutableDictionary alloc]init];
        [body setValue:self.timeStamp forKeyPath:@"last_modified"];
        [body setValue:self.postCount forKeyPath:@"post_count"];
        [body setValue:self.etag forKey:@"etag"];
        [body setValue:step forKeyPath:@"step"];

        
        NSDictionary* postData = @{@"command": @"all",@"access_token": token.access_token,@"body":body};
        NSDictionary *userInfo = @{@"command": @"GetStreams"};
        
        NSString *urlAsString = [NSString stringWithFormat:@"%@posts",BASE_URL];
        [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
        
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
    
    [refreshControl endRefreshing];
    
    self.timeStamp = [recievedDict objectForKey:@"last_modified"];
    self.postCount = [recievedDict objectForKey:@"post_count"];
    self.etag = [recievedDict objectForKey:@"etag"];

    
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
    return 126;
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
    [self.delegate tableDidSelect:(int)indexPath.row];
}
-(void)buildCell:(UITableViewCell *)cell withDetails:(PostDetails *)postDetailsObject
{
    float yPosition = 14;
    
    
    //Profile Image
    UIImageView *profileImage  = [[UIImageView alloc] initWithFrame:CGRectMake(10, yPosition, 36, 36)];
    if(!postDetailsObject.anonymous)
    {
        __weak UIImageView *weakSelf = profileImage;

    [profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[postDetailsObject.owner objectForKey:@"photo"]]] placeholderImage:[UIImage imageNamed:@"icon-profile-register.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(36, 36)] withRadious:0];
         
     }failure:nil];
    }
    else
        [profileImage setImage:[UIImage imageNamed:@"icon-profile-register.png"]];

    
    [cell.contentView addSubview:profileImage];
    
    //Profile name
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(57, yPosition, 200, 18)];
    [name setText:[postDetailsObject.owner objectForKey:@"fname"]];
    [name setFont:[UIFont fontWithName:@"HelveticaNeue-Thick" size:13]];
    [cell.contentView addSubview:name];
    
    
    UIImageView *timeIcon  = [[UIImageView alloc] initWithFrame:CGRectMake(257, yPosition, 8, 8)];
    [timeIcon setImage:[UIImage imageNamed:@"time.png"]];
    [cell.contentView addSubview:timeIcon];

    //Time
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(267, yPosition, 51, 8)];
    [time setText:[profileDateUtils dailyLanguage:postDetailsObject.time]];
    [time setTextAlignment:NSTextAlignmentLeft];
    [time setTextColor:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]];
    [time setFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:10]];
    [cell.contentView addSubview:time];
    
    [self addDescription:cell withDetails:postDetailsObject];
    
    
    
}
-(void)addDescription:(UITableViewCell *)cell withDetails:(PostDetails *)postDetailsObject
{
    float yPosition = 32;
    
    //Description
    UILabel *description = [[UILabel alloc] init];
    
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:postDetailsObject.content attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:11],NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]}];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\::(.*?)\\::" options:NSRegularExpressionCaseInsensitive error:NULL];
    
    
    do{
        
        NSArray *myArray = [regex matchesInString:attributedString.string options:0 range:NSMakeRange(0, [attributedString.string length])] ;
        if(myArray.count > 0)
        {
            NSTextCheckingResult *match =  [myArray firstObject];
            NSRange matchRange = [match rangeAtIndex:1];
            NSLog(@"%@", [attributedString.string substringWithRange:matchRange]);
            
            UIImage  *image = [photoUtils imageWithImage:[UIImage imageNamed:@"EmptyProfilePic.jpg"] scaledToSize:CGSizeMake(26, 16) withRadious:3.0];
            NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];

            textAttachment.image = image;
            
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:[NSURL URLWithString:[postDetailsObject.images objectForKey:[attributedString.string substringWithRange:matchRange]]] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                
                textAttachment.image = [photoUtils imageWithImage:image scaledToSize:CGSizeMake(26, 16) withRadious:3.0];
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
    
    [description setAttributedText:attributedString];
    [description setTextAlignment:NSTextAlignmentLeft];
    [description setNumberOfLines:0];
    [cell.contentView addSubview:description];
    
    CGSize size = [description sizeThatFits:CGSizeMake(232, 50)];
    
    if(size.height < 50)
        description.frame = CGRectMake(57, yPosition+4, 232, size.height);
    else
        description.frame = CGRectMake(57, yPosition+4, 232, 50);
    yPosition += 50;
    
    if([postDetailsObject.tags count] > 0)
    {
        NSMutableArray *tagsArray = [[NSMutableArray alloc] init];
        for(NSString *tag in postDetailsObject.tags)
        {
            [tagsArray addObject:[NSString stringWithFormat:@"#%@",tag]];
        }
        STTweetLabel *tweetLabel = [[STTweetLabel alloc] initWithFrame:CGRectMake(57, yPosition, 232 , 15)];
        [tweetLabel setText:[tagsArray componentsJoinedByString:@" "]];
        tweetLabel.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:tweetLabel];
        
        
        [tweetLabel setDetectionBlock:^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {

            
        }];

        
        yPosition += 15;
    }
    
    UIImageView *heartCntImage  = [[UIImageView alloc] initWithFrame:CGRectMake(287, 106, 11, 10)];
    [heartCntImage setImage:[UIImage imageNamed:@"icon-heart-count.png"]];
    [cell.contentView addSubview:heartCntImage];

    UILabel *heartCount = [[UILabel alloc] initWithFrame:CGRectMake(299, 106, 20, 10)];
    [heartCount setText:postDetailsObject.time];
    [heartCount setTextAlignment:NSTextAlignmentLeft];
    [heartCount setText:[NSString stringWithFormat:@"%i",postDetailsObject.upVoteCount]];
    [heartCount setTextColor:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]];
    [heartCount setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10]];
    [cell.contentView addSubview:heartCount];

    
    if([postDetailsObject.commenters count] > 0)
    {
        NSMutableArray *commenters = [NSMutableArray arrayWithArray:postDetailsObject.commenters];
        UIView *commentersView = [[UIView alloc] initWithFrame:CGRectMake(57, yPosition+4, 232, 19)];
        [cell.contentView addSubview:commentersView];
        
        int x = 0;
        for(int i = 0; i < commenters.count; i++)
            //for(id dict in array)
        {
            
            NSString *url = [commenters objectAtIndex:i];
            UIImageView *imagVw = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, 19, 19)];
            [commentersView addSubview:imagVw];
            
            __weak UIImageView *weakSelf = imagVw;
            
            
            [imagVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:[photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:[UIImage imageNamed:@"EmptyProfilePic.jpg"] scaledToSize:CGSizeMake(19,19)] withRadious:0] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(19, 19)] withRadious:0];
                 
             }failure:nil];
            

            x+= 19 + 3;
            
            if(i >= 9)
            {
                UIImageView *imagVw = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, 19, 19)];
                [imagVw setImage:[UIImage imageNamed:@"comment_Count.png"]];
                [commentersView addSubview:imagVw];
                
                UILabel *tag = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, 19 , 19)];
                [tag setText:[NSString stringWithFormat:@"+20"]];
                [tag setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
                [tag setBackgroundColor:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]];
                [imagVw addSubview:tag];

                break;
            }
        }
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
    
    if(indexPath.row == storiesArray.count - 1)
        [self callStreamsApi:@"next"];
}


@end