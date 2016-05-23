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
#import "SlideNavigationController.h"
#import "PostDetailDescriptionViewController.h"
#import "UserProfileViewCotroller.h"
#import "TagViewController.h"
#import "LoginViewController.h"
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
    notificationsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    notificationsTableView.tableHeaderView = nil;
    notificationsTableView.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
    [self.view addSubview:notificationsTableView];
    
    refreshControl = [[UIRefreshControl alloc] init];
    // refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    refreshControl.backgroundColor= [UIColor clearColor];
    
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [notificationsTableView addSubview:refreshControl];
    
    self.title = @"Notifications";
    
    [self callNotificationsApi:@"next"];
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
        NSString *command = @"all";
        NSMutableDictionary *body = [[NSMutableDictionary alloc]init];
        [body setValue:self.timeStamp forKeyPath:@"last_modified"];
        [body setValue:self.notificationCount forKeyPath:@"notification_count"];
        [body setValue:self.etag forKey:@"etag"];
        [body setValue:step forKeyPath:@"step"];
        
        NSDictionary* postData = @{@"command": command,@"access_token": token.access_token,@"body":body};
        NSDictionary *userInfo = @{@"command": @"GetNotifications"};
        
        NSString *urlAsString = [NSString stringWithFormat:@"%@notifications",BASE_URL];
        [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
    }
}
-(void) didReceiveNotification:(NSDictionary *)recievedDict
{
    bProcessing = NO;
    
    NSArray *notifiArray = [recievedDict objectForKey:@"notifications"];
    
    if([timeStamp length] == 0)
    {
        [notificationsArray removeAllObjects];
        [notificationsTableView reloadData];
        
    }
    
    if([notifiArray count] > 0)
    {
        
        if([notificationsArray count] > 0)
        {
            [notificationsArray addObjectsFromArray:notifiArray];
            
        }
        else
        {
            notificationsArray = [notifiArray mutableCopy];
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
-(void) notificationFailed
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
    if(notificationDetailsObject.viewed)
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
    if(notificationDetailsObject.viewed)
    {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:notificationDetailsObject.message attributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14], NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
        
        textView.attributedText = attributedString;
        
        
        contentSize = [textView sizeThatFits:CGSizeMake(270-profileImage.frame.size.width, CGFLOAT_MAX)];
        
    }
    else
    {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:notificationDetailsObject.message attributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:14], NSForegroundColorAttributeName:[UIColor blackColor]}];
        
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
          
            CGRect rect = bubbleImage.frame;
            rect.origin.y = textView.center.y;
            bubbleImage.frame = rect;

            rect = profileImage.frame;
            rect.origin.y = textView.center.y;
            profileImage.frame = rect;
            
        }
        else
        {
            textView.frame = CGRectMake(profileImage.frame.size.width+20, 10, contentSize.width, contentSize.height);
            
            CGRect rect = bubbleImage.frame;
            rect.origin.y = profileImage.center.y;
            bubbleImage.frame = rect;
            
            rect = profileImage.frame;
            rect.origin.y = profileImage.center.y;
            textView.frame = rect;
        }
    }
    else
    {
        textView.frame = CGRectMake(profileImage.frame.size.width+20, 10, contentSize.width, contentSize.height);
        CGRect rect = bubbleImage.frame;
        rect.origin.y = textView.center.y;
        bubbleImage.frame = rect;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationDetails *notificationDetailsObject = [notificationsArray objectAtIndex:indexPath.row];
    if(!notificationDetailsObject.viewed)
    {
        notificationDetailsObject.viewed = YES;
        [tableView reloadData];

        AccessToken* token = sharedModel.accessToken;
        NSString *command = @"update";
        NSMutableDictionary *body = [[NSMutableDictionary alloc]init];
        
        NSDictionary* postData = @{@"command": command,@"access_token": token.access_token,@"body":body};
        NSDictionary *userInfo = @{@"command": @"NotificationUpdate"};
        
        NSString *urlAsString = [NSString stringWithFormat:@"%@notifications/%@",BASE_URL,notificationDetailsObject.uid];
        [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];

    }
    [self addMessageFromRemoteNotification:notificationDetailsObject];


}
- (void)addMessageFromRemoteNotification:(NotificationDetails *)notificationDetailsObject
{
    
    
    
   
        NSString *type = [notificationDetailsObject.source lowercaseString];
        NSString *uid = notificationDetailsObject.sourceId;
        
        
        if([type isEqualToString:@"post"] || [type isEqualToString:@"comment"] || [type isEqualToString:@"vote"])
        {
            
            if(uid != nil && uid.length > 0)
            {
                [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
                
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                         bundle: nil];
                PostDetailDescriptionViewController *postDetailDescriptionViewController = (PostDetailDescriptionViewController*)[mainStoryboard
                                                                                                                                  instantiateViewControllerWithIdentifier: @"PostDetailDescriptionViewController"];
                postDetailDescriptionViewController.postID = uid;
                SlideNavigationController *slide = [SlideNavigationController sharedInstance];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [slide pushViewController:postDetailDescriptionViewController animated:YES];
                });
            }
        }
        else if([type isEqualToString:@"follower"])
        {
            
            if(uid != nil && uid.length > 0)
            {
                [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
                
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                         bundle: nil];
                UserProfileViewCotroller *postDetailDescriptionViewController = (UserProfileViewCotroller*)[mainStoryboard
                                                                                                            instantiateViewControllerWithIdentifier: @"UserProfileViewCotroller"];
                postDetailDescriptionViewController.profileId = uid;
                SlideNavigationController *slide = [SlideNavigationController sharedInstance];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [slide pushViewController:postDetailDescriptionViewController animated:YES];
                });
            }
        }
        else if([type isEqualToString:@"group"])
        {
            if(uid != nil && uid.length > 0)
            {
                
                [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
                
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                         bundle: nil];
                
                TagViewController *postDetailDescriptionViewController = (TagViewController*)[mainStoryboard
                                                                                              instantiateViewControllerWithIdentifier: @"TagViewController"];
                postDetailDescriptionViewController.tagId = uid;
                SlideNavigationController *slide = [SlideNavigationController sharedInstance];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [slide pushViewController:postDetailDescriptionViewController animated:YES];
                });
            }
            
            
        }
        else if([type isEqualToString:@"addpost"])
        {
            
            if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
            {
                [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
                
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                         bundle: nil];
                
                AddPostViewController *postDetailDescriptionViewController = (AddPostViewController*)[mainStoryboard
                                                                                                      instantiateViewControllerWithIdentifier: @"AddPostViewController"];
                SlideNavigationController *slide = [SlideNavigationController sharedInstance];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [slide pushViewController:postDetailDescriptionViewController animated:YES];
                });
                
            }
            else
            {
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                LoginViewController *login = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
                
                CGRect screenRect = [[UIScreen mainScreen] bounds];
                CGFloat screenWidth = screenRect.size.width;
                CGFloat screenHeight = screenRect.size.height;
                
                login.view.frame = CGRectMake(0,-screenHeight,screenWidth,screenHeight);
                
                [[[[UIApplication sharedApplication] delegate] window] addSubview:login.view];
                
                SlideNavigationController *slide = [SlideNavigationController sharedInstance];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        login.view.frame = CGRectMake(0,0,screenWidth,screenHeight);
                        
                    }
                                     completion:^(BOOL finished){
                                         [login.view removeFromSuperview];
                                         
                                         [slide pushViewController:login animated:NO];
                                     }
                     ];
                    
                    
                    
                });
                
                
                
                
            }
            
            
        }
        else if([type isEqualToString:@"share"])
        {
            if(uid != nil && uid.length > 0)
            {
                
                [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
                
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                         bundle: nil];
                PostDetailDescriptionViewController *postDetailDescriptionViewController = (PostDetailDescriptionViewController*)[mainStoryboard
                                                                                                                                  instantiateViewControllerWithIdentifier: @"PostDetailDescriptionViewController"];
                postDetailDescriptionViewController.postID = uid;
                postDetailDescriptionViewController.showShareDialog = YES;
                SlideNavigationController *slide = [SlideNavigationController sharedInstance];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [slide pushViewController:postDetailDescriptionViewController animated:YES];
                });
            }
        }


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
