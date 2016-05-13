//
//  NotificationsViewController.m
//  Msocl_iOS
//
//  Created by Maisa Pride on 5/13/16.
//  Copyright © 2016 Maisa Solutions. All rights reserved.
//

#import "NotificationsViewController.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "StringConstants.h"
#import "ProfilePhotoUtils.h"
#import "ProfileDateUtils.h"
#import "ModelManager.h"
#import "NotificationDetails.h"
#import "SDWebImageManager.h"
#import "STTweetLabel.h"
#import "AppDelegate.h"


@interface NotificationsViewController ()

@end

@implementation NotificationsViewController
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
    AppDelegate *appDelegate;

}
@synthesize notificationsArray;
@synthesize notificationsTableView;
@synthesize bProcessing;
@synthesize isSearching;
@synthesize timeStamp;
@synthesize etag;
@synthesize notificationCount;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    sharedModel   = [ModelManager sharedModel];
    appDelegate = [[UIApplication sharedApplication] delegate];
    notificationsArray = [[NSMutableArray alloc] init];
    notificationsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, Deviceheight-65)];
    notificationsTableView.delegate = self;
    notificationsTableView.dataSource = self;
    notificationsTableView.tableFooterView = nil;
    notificationsTableView.tableHeaderView = nil;
    notificationsTableView.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
    [self.view addSubview:notificationsTableView];
    
    refreshControl = [[UIRefreshControl alloc] init];
    // refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    refreshControl.backgroundColor= [UIColor clearColor];
    
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [notificationsTableView addSubview:refreshControl];
    
    // Do any additional setup after loading the view.
}

-(void)handleRefresh:(id)sender
{
    //    UIRefreshControl *refresh = sender;
    //     refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    if (bProcessing) return;
    // Released above the header
    [self resetData];
    
    [self performSelectorInBackground:@selector(callNotificationsApi:) withObject:@"next"];
    
}

-(void)resetData
{
    self.notificationCount = 0;
    self.timeStamp = @"";
    self.etag = @"";
    
}

#pragma mark -
#pragma mark API Methods

-(void)callNotificationsApi:(NSString *)step
{
    if(bProcessing)
        return;
    else
    {
        bProcessing = YES;
        
        AccessToken* token = sharedModel.accessToken;
        NSString *command = @"filter";
        NSMutableDictionary *body = [[NSMutableDictionary alloc]init];
        [body setValue:self.timeStamp forKeyPath:@"last_modified"];
        [body setValue:self.notificationCount forKeyPath:@"notification_count"];
        [body setValue:self.etag forKey:@"etag"];
        [body setValue:step forKeyPath:@"step"];
        
        NSDictionary* postData = @{@"command": command,@"access_token": token.access_token,@"body":body};
        NSDictionary *userInfo = @{@"command": @"GetNotifications"};
        
        NSString *urlAsString = [NSString stringWithFormat:@"%@v2/posts",BASE_URL];
        [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
    }
}
-(void) didReceiveNotification:(NSDictionary *)recievedDict
{
    bProcessing = NO;
    
    NSArray *postArray = [recievedDict objectForKey:@"posts"];
    
    if([timeStamp length] == 0)
    {
        [notificationsArray removeAllObjects];
        [notificationsTableView reloadData];
        
    }
    
    if([postArray count] > 0)
    {
        
        if([notificationsArray count] > 0)
        {
            [notificationsArray addObjectsFromArray:postArray];
            
        }
        else
        {
            notificationsArray = [postArray mutableCopy];
        }
        
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:notificationsArray];
        notificationsArray = [orderedSet.array mutableCopy];
        
        [notificationsTableView reloadData];
        
    }
    
    
    
    [refreshControl endRefreshing];
    
    self.timeStamp = [recievedDict objectForKey:@"last_modified"];
    self.notificationCount = [recievedDict objectForKey:@"post_count"];
    self.etag = [recievedDict objectForKey:@"etag"];
    
    
    //  [streamTableView reloadData];
    [appDelegate showOrhideIndicator:NO];
    
}
-(void) streamsFailed
{
    [appDelegate showOrhideIndicator:NO];
    
    bProcessing = NO;
    [refreshControl endRefreshing];
}

#pragma mark -
#pragma mark Tableview methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationDetails *notificationDetailsObject = [notificationsArray objectAtIndex:indexPath.row];
    
    NIAttributedLabel *textView = [NIAttributedLabel new];
    textView.font = [UIFont fontWithName:@"SanFranciscoText-Light" size:14];
    textView.numberOfLines = 0;
    
    float imageWidth = 0;
    if(notificationDetailsObject.url.length > 0)
    {
        imageWidth = 50;
    }
    
    CGSize contentSize;
    if(notificationDetailsObject.isRead)
    {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:notificationDetailsObject.message attributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14]}];
        
        textView.attributedText = attributedString;
        
        
         contentSize = [textView sizeThatFits:CGSizeMake(270-imageWidth, CGFLOAT_MAX)];

    }
    else
    {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:notificationDetailsObject.message attributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:14]}];
        
        textView.attributedText = attributedString;
        
        
         contentSize = [textView sizeThatFits:CGSizeMake(270-imageWidth, CGFLOAT_MAX)];

    }
    //Calculating content height

    if(notificationDetailsObject.url.length > 0)
    {
        if(contentSize.height+20 > 60)
            return contentSize.height+20;
        else
            return 60;
        
    }
    else
    {
        return contentSize.height+20;
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [notificationsArray count];
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
    
    NotificationDetails *notificationDetailsObject = [notificationsArray objectAtIndex:indexPath.row];
    
    //removes any subviews from the cell
    for(UIView *viw in [[cell contentView] subviews])
    {
        [viw removeFromSuperview];
    }
    cell.backgroundColor = [UIColor clearColor];
    
    [self buildCell:cell withDetails:notificationDetailsObject :indexPath];
    
    
    return cell;
    
}
-(void)buildCell:(UITableViewCell *)cell withDetails:(NotificationDetails *)notificationDetailsObject :(NSIndexPath *)indexPath
{

    UIImageView *profileImage;
    if(notificationDetailsObject.url.length > 0)
    {
         profileImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];

        __weak UIImageView *weakSelf = profileImage;
        
        
        [profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:notificationDetailsObject.url]] placeholderImage:[UIImage imageNamed:@"circle-80.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             weakSelf.image = [photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(40, 40)];
             
         }failure:nil];
        [cell.contentView addSubview:profileImage];

    }
    
    
    
    NIAttributedLabel *textView = [NIAttributedLabel new];
    textView.font = [UIFont fontWithName:@"SanFranciscoText-Light" size:14];
    textView.numberOfLines = 0;
    
    UIImageView *bubbleImage;

    CGSize contentSize;
    if(notificationDetailsObject.isRead)
    {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:notificationDetailsObject.message attributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14], NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
        
        textView.attributedText = attributedString;
        
        
        contentSize = [textView sizeThatFits:CGSizeMake(270-profileImage.frame.size.width, CGFLOAT_MAX)];
        
    }
    else
    {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:notificationDetailsObject.message attributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:14], NSForegroundColorAttributeName:[UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:1.0]}];
        
        textView.attributedText = attributedString;
        
        
        contentSize = [textView sizeThatFits:CGSizeMake(270-profileImage.frame.size.width, CGFLOAT_MAX)];
        
        bubbleImage = [[UIImageView alloc] initWithFrame:CGRectMake(290, 10, 10, 10)];
        bubbleImage.backgroundColor = [UIColor redColor];
        bubbleImage.layer.cornerRadius = 5;
        [cell.contentView addSubview:bubbleImage];
        
    }
    [cell.contentView addSubview:textView];


    textView.frame = CGRectMake(10, 10, contentSize.width, contentSize.height);
    
    
    if(notificationDetailsObject.url.length > 0)
    {
        if(contentSize.height+20 > 60)
        {
            textView.frame = CGRectMake(profileImage.frame.size.width+20, 10, contentSize.width, contentSize.height);
            bubbleImage.center = textView.center;
            profileImage.center = textView.center;
            
        }
        else
        {
            textView.frame = CGRectMake(profileImage.frame.size.width+20, 10, contentSize.width, contentSize.height);
            bubbleImage.center = profileImage.center;
            textView.center = profileImage.center;
        }
    }
    else
    {
        textView.frame = CGRectMake(profileImage.frame.size.width+20, 10, contentSize.width, contentSize.height);
        bubbleImage.center = textView.center;
    }
    
    
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

  
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
            [self callNotificationsApi:@"next"];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
