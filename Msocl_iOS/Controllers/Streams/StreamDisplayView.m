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

@implementation StreamDisplayView
{
    ProfilePhotoUtils *photoUtils;
    ProfileDateUtils *profileDateUtils;
    UIRefreshControl *refreshControl;
    BOOL isMoreAvailabel;
    BOOL isPrevious;
    ModelManager *sharedModel;
    
    Webservices *webServices;
    
    NSNumber *feedCount;
    NSNumber *postCount;
    BOOL bProcessing;
    BOOL isDragging;

}
@synthesize storiesArray;
@synthesize streamTableView;
@synthesize delegate;
@synthesize profileID;
@synthesize isMostRecent;
@synthesize isFollowing;
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
    postCount = 0;
    feedCount = 0;
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
    [streamTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
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

      
            NSDictionary* postData = @{@"command": @"all"};
            NSDictionary *userInfo = @{@"command": @"GetStreams"};
            
            NSString *urlAsString = [NSString stringWithFormat:@"%@posts",BASE_URL];
            [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];

            
    }
}
-(void) didReceiveStreams:(NSDictionary *)recievedDict
{
    NSArray *postArray = [recievedDict objectForKey:@"posts"];
    
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
        
        bProcessing = NO;
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:storiesArray];
        storiesArray = [orderedSet.array mutableCopy];
        
        //test if prompt is there yet
        NSDictionary *dict1 = [[NSDictionary alloc]init];
        
        if ([storiesArray count]>1)
        {
            dict1 = [storiesArray objectAtIndex:1];
        }
        
        [streamTableView reloadData];
        
    }
    [refreshControl endRefreshing];

}
-(void) streamsFailed
{
    [refreshControl endRefreshing];

}

#pragma mark -
#pragma mark TableViewMethods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
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
    
    
    NSDictionary *storyDict  = [storiesArray objectAtIndex:indexPath.row];
    
    //removes any subviews from the cell
    for(UIView *viw in [[cell contentView] subviews])
    {
        [viw removeFromSuperview];
    }
    
    [self buildCell:cell withDetails:storyDict];
    
    
    return cell;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(void)buildCell:(UITableViewCell *)cell withDetails:(NSDictionary *)storyDict
{
    float yPosition = 15;
    
    //Back Ground Image
    UIImageView *backGroundImage  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
    [backGroundImage setBackgroundColor:[UIColor lightGrayColor]];
    [cell.contentView addSubview:backGroundImage];
    
    //Profile Image
    UIImageView *profileImage  = [[UIImageView alloc] initWithFrame:CGRectMake(10, yPosition, 100, 100)];
    [profileImage setImageWithURL:[NSURL URLWithString:[storyDict objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"EmptyProfilePic.jpg"]];
    [cell.contentView addSubview:profileImage];
    
    //Profile name
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(120, yPosition, 140, 21)];
    [name setText:[storyDict objectForKey:@"name"]];
    [name setFont:[UIFont systemFontOfSize:16]];
    [cell.contentView addSubview:name];
    
    //Time
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(260, yPosition, 50, 21)];
    [time setText:[storyDict objectForKey:@"time"]];
    [time setTextAlignment:NSTextAlignmentRight];
    [time setText:@"5 min ago"];
    [time setFont:[UIFont systemFontOfSize:12]];
    [cell.contentView addSubview:time];
    
    
    //Start of Description Text and Upvote
    yPosition += 21 + 5;
    
    //Upvote
    UIButton *upVote = [UIButton buttonWithType:UIButtonTypeCustom];
    [upVote setTitle:@"Up vote" forState:UIControlStateNormal];
    [upVote setFrame:CGRectMake(160, yPosition, 50, 40)];
    [cell.contentView addSubview:upVote];
    
    [self addDescription:cell withDetails:storyDict];

    
    
}
-(void)addDescription:(UITableViewCell *)cell withDetails:(NSDictionary *)storyDict
{
    float yPosition = 15;
    
    //Start of Description Text
    yPosition += 21 + 5;
    
    //Time
    UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(115, yPosition, 140, 65)];
    [description setText:[storyDict objectForKey:@"content"]];
    [description setTextAlignment:NSTextAlignmentRight];
    [description setFont:[UIFont systemFontOfSize:12]];
    [description setNumberOfLines:0];
    [cell.contentView addSubview:description];
    
    
    if([[storyDict objectForKey:@"tags"] count] > 0)
    {
        UIView *tagsView = [[UIView alloc] initWithFrame:CGRectMake(115, yPosition+65, 140, 15)];
        [cell.contentView addSubview:tagsView];
        NSArray *tagsArray = [storyDict objectForKey:@"tags"];
        //Time
        UILabel *time = [[UILabel alloc] initWithFrame:tagsView.bounds];
        [time setText:[tagsArray componentsJoinedByString:@" "]];
        [time setFont:[UIFont systemFontOfSize:12]];
        [tagsView addSubview:time];
    }
    
    //Time
    UILabel *comments = [[UILabel alloc] initWithFrame:CGRectMake(115, yPosition+65+15, 140, 15)];
    [comments setText:[storyDict objectForKey:@"time"]];
    [comments setTextAlignment:NSTextAlignmentRight];
    [comments setText:[NSString stringWithFormat:@"Comments(22) Upvotes(21)"]];
    [comments setFont:[UIFont systemFontOfSize:12]];
    [cell.contentView addSubview:comments];
    
    if([[storyDict objectForKey:@"commenters"] count] > 0)
    {
        UIView *commentersView = [[UIView alloc] initWithFrame:CGRectMake(115, yPosition+65+15+15, 140, 15)];
        [cell.contentView addSubview:commentersView];
    }
    
    if([[storyDict objectForKey:@"tags"] count] == 0 && [[storyDict objectForKey:@"commenters"] count] == 0)
    {
        
    }
    else
    {
        
    }
}
@end