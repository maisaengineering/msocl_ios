//
//  SettingsMenuViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/13/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "MenuViewController.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"
#import "ModelManager.h"
#import "MainStreamsViewController.h"
#import "ProfilePhotoUtils.h"
#import "UserProfileViewCotroller.h"
@implementation MenuViewController
{
    ModelManager *sharedModel;
    ProfilePhotoUtils *photoUtils;
}
#pragma mark - UIViewController Methods -

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self.slideOutAnimationEnabled = YES;
    
    return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor lightGrayColor];

    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    sharedModel = [ModelManager sharedModel];
    photoUtils = [ProfilePhotoUtils alloc];
   appdelegate = [[UIApplication sharedApplication] delegate];
    self.tableView.tableFooterView = [[UIView alloc] init];

    
}
#pragma mark - UITableView Delegate & Datasrouce -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
        return 75;
    else return 35;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 20)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leftTopCell"];
        cell.backgroundColor = [UIColor clearColor];
        
        UIImageView *profileImage = (UIImageView *)[cell viewWithTag:1];
            __weak UIImageView *weakSelf = profileImage;
            
            [profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:sharedModel.userProfile.image]] placeholderImage:[UIImage imageNamed:@"icon-profile-register.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(35, 35)] withRadious:0];
                 
             }failure:nil];
        [(UILabel *)[cell viewWithTag:2] setText:[NSString stringWithFormat:@"%@ %@",sharedModel.userProfile.fname,sharedModel.userProfile.lname]];
        
        return cell;

    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leftMenuCell"];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];

    switch (indexPath.row)
    {
        case 1:
            cell.textLabel.text = @"Wall";
            cell.imageView.image = [UIImage imageNamed:@"menu-home.png"];
            break;
            
        case 2:
            cell.textLabel.text = @"Create Post";
            cell.imageView.image = [UIImage imageNamed:@"menu-createpost.png"];
            break;
            
        case 3:
            cell.textLabel.text = @"Profile";
            cell.imageView.image = [UIImage imageNamed:@"menu-profile.png"];
            break;

        case 4:
            cell.textLabel.text = @"Settings";
            cell.imageView.image = [UIImage imageNamed:@"menu-settings.png"];
            break;


        case 5:
            cell.textLabel.text = @"Logout";
            cell.imageView.image = [UIImage imageNamed:@"menu-logout.png"];
            break;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.row)
    {
        case 0:
            break;
            
        case 2:
        {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];
            
            UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"AddPostViewController"];

            [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];
        }
            break;
            
        case 5:
            [self logOut];
            break;
            
        case 4:
        {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];
            
            UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
            
            [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];
        }            break;
            
        case 3:
        {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];
            
            UserProfileViewCotroller *destViewController = (UserProfileViewCotroller *)[mainStoryboard instantiateViewControllerWithIdentifier:@"UserProfileViewCotroller"];
            UserProfile *userProfile = sharedModel.userProfile;
            destViewController.photo = userProfile.image;
            destViewController.name = [NSString stringWithFormat:@"%@ %@",sharedModel.userProfile.fname,sharedModel.userProfile.lname];
            destViewController.profileId = userProfile.uid;
            [[SlideNavigationController sharedInstance] pushViewController:destViewController animated:YES];

        }return;
            break;
    }
    
//    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
//                                                             withSlideOutAnimation:self.slideOutAnimationEnabled
//                                                                     andCompletion:nil];
    [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
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
- (void)clearFBCookiesFromWebview
{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"facebook"];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookie];
        }
    }
}

- (void)clearTwitterCookiesFromWebview
{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"twitter"];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookie];
        }
    }
}

- (void)clearGMAILCookiesFromWebview
{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"google"];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookie];
        }
    }
}


-(void)logOut
{
    // call clearCookiesFromWebview
    [self clearFBCookiesFromWebview];
    [self clearTwitterCookiesFromWebview];
    [self clearGMAILCookiesFromWebview];
    
    [appdelegate showOrhideIndicator:YES];
    
    NSMutableDictionary *postDetails  = [NSMutableDictionary dictionary];
    
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": @"signOut",
                               @"body": postDetails};
    NSDictionary *userInfo = @{@"command": @"signOut"};
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}
-(void) signOutSccessfull:(NSDictionary *)recievedDict
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLogedIn"];
    [self callAccessTokenApi];
}
-(void) signOutFailed
{
    [appdelegate showOrhideIndicator:NO];
}


-(void)callAccessTokenApi
{
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"grant_type": @"client_credentials",
                               @"client_id": CLIENT_ID,
                               @"client_secret": CLIENT_SECRET,
                               @"scope": @"imsocl"};
    
    NSDictionary *userInfo = @{@"command": @"GetAccessToken"};
    NSString *urlAsString = [NSString stringWithFormat:@"%@clients/token",BASE_URL];
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}
#pragma mark- AccessToken Api callback Methods
#pragma mark-
- (void)didReceiveTokens:(NSArray *)tokens
{
    [appdelegate showOrhideIndicator:NO];
    ModelManager *sharedModel = [ModelManager sharedModel];
    sharedModel.accessToken = [tokens objectAtIndex:0];
    
    if([[[SlideNavigationController sharedInstance] topViewController] isKindOfClass:[MainStreamsViewController class]])
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:RELOAD_ON_LOG_OUT object:nil];
    }
        
}

- (void)fetchingTokensFailedWithError
{
    [appdelegate showOrhideIndicator:NO];
}

@end