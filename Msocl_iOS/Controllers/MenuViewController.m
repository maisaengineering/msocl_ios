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
#import "UpdateUserDetailsViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
//#import "Flurry.h"
#import "LoginViewController.h"
#import "NotificationUtils.h"
#import "NewLoginViewController.h"
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
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    sharedModel = [ModelManager sharedModel];
    photoUtils = [ProfilePhotoUtils alloc];
    appdelegate = [[UIApplication sharedApplication] delegate];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}
#pragma mark - UITableView Delegate & Datasrouce -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
        return 8;
    else
    return 4;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 0 && [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
        return 90;
    else return 44;

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
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    {
    if(indexPath.row == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leftTopCell"];
        cell.backgroundColor = [UIColor clearColor];
        
        UIImageView *profileImage = (UIImageView *)[cell viewWithTag:1];
        __weak UIImageView *weakSelf = profileImage;
        
        for(UIView *view in [profileImage subviews])
            [view removeFromSuperview];
        NSMutableString *parentFnameInitial = [[NSMutableString alloc] init];
        if( [sharedModel.userProfile.fname length] >0)
            [parentFnameInitial appendString:[[sharedModel.userProfile.fname substringToIndex:1] uppercaseString]];
        if( [sharedModel.userProfile.lname length] >0)
            [parentFnameInitial appendString:[[sharedModel.userProfile.lname substringToIndex:1] uppercaseString]];
        if(parentFnameInitial.length < 1)
        {
            if( [sharedModel.userProfile.handle length] >0)
                [parentFnameInitial appendString:[[sharedModel.userProfile.handle substringToIndex:1] uppercaseString]];
            if( [sharedModel.userProfile.handle length] >1)
                [parentFnameInitial appendString:[[sharedModel.userProfile.handle substringWithRange:NSMakeRange(1, 1)] uppercaseString]];

        }
        NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:parentFnameInitial
                                               attributes:nil];
        NSRange range;
        
        if(parentFnameInitial.length > 0)
        {
            range.location = 0;
            range.length = 1;
            [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoDisplay-Light" size:20]}
                                    range:range];
        }
        if(parentFnameInitial.length > 1)
        {
            range.location = 1;
            range.length = 1;
            [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoDisplay-Light" size:20]}
                                    range:range];
        }
        
        
        //add initials
        
        UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        initial.attributedText = attributedText;
        [initial setBackgroundColor:[UIColor clearColor]];
        initial.textAlignment = NSTextAlignmentCenter;
        [profileImage addSubview:initial];
        
        
        [profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:sharedModel.userProfile.image]] placeholderImage:[UIImage imageNamed:@"circle-80.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(35, 35)] withRadious:0];
             [initial removeFromSuperview];
             
         }failure:nil];
        if(sharedModel.userProfile.fname.length >0 || sharedModel.userProfile.lname.length > 0)
        [(UILabel *)[cell viewWithTag:2] setText:[NSString stringWithFormat:@"%@ %@",sharedModel.userProfile.fname,sharedModel.userProfile.lname]];
        else if(sharedModel.userProfile.handle.length > 0)
            [(UILabel *)[cell viewWithTag:2] setText:[NSString stringWithFormat:@"@%@",sharedModel.userProfile.handle]];
        else
            [(UILabel *)[cell viewWithTag:2] setText:@""];
        
        [(UILabel *)[cell viewWithTag:2] setTextColor:[UIColor whiteColor]];
        [(UILabel *)[cell viewWithTag:2] setFont:[UIFont fontWithName:@"SanFranciscoDisplay-Light" size:16]];
        
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 89.5, 320, 0.5)];
        [label setBackgroundColor:[UIColor lightGrayColor]];
        [cell.contentView addSubview:label];
        return cell;
        
    }
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leftMenuCell"];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"SanFranciscoDisplay-Light" size:16];
    
    for(UIView *view in [cell.contentView subviews])
        [view removeFromSuperview];

    
    switch (indexPath.row)
    {
        case 1:
            cell.textLabel.text = @"Wall";
            cell.imageView.image = [UIImage imageNamed:@"menu-home.png"];
            break;
            
        case 2:
            cell.textLabel.text = @" Create Post";
            cell.imageView.image = [UIImage imageNamed:@"icon-createpost.png"];
            break;
            
        case 3:
        {
            cell.textLabel.text = @"Notifications";
            cell.imageView.image = [UIImage imageNamed:@"menu-notifications.png"];
            
            NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
            int count = 0;
            count = [[userdefaults objectForKey:@"notificationcount"] intValue];
            if([userdefaults objectForKey:@"notificationcount"] && count > 0)
            {
            UIImageView *bubbleImage = [[UIImageView alloc] initWithFrame:CGRectMake(21, 4, 20, 20)];
            bubbleImage.backgroundColor = [UIColor colorWithRed:197/255.0 green:33/255.0 blue:40/255.0 alpha:1.0];
            bubbleImage.layer.cornerRadius = bubbleImage.frame.size.height /2;
            bubbleImage.layer.masksToBounds = YES;
            bubbleImage.layer.borderWidth = 0;
                
            [cell.contentView addSubview:bubbleImage];
                
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(21, 4, 20, 20)];
                if(count > 999)
                    [label setText:[NSString stringWithFormat:@"999"]];
                else
                    [label setText:[NSString stringWithFormat:@"%i",count]];
                label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:@"SanFranciscoDisplay-Light" size:10];
            [label setTextColor:[UIColor whiteColor]];
            [cell.contentView addSubview:label];

            }
        }

            break;

            
        case 4:
            cell.textLabel.text = @"Settings";
            cell.imageView.image = [UIImage imageNamed:@"menu-settings.png"];
            break;
            
        case 5:
            cell.textLabel.text = @"Manage Tags";
            cell.imageView.image = [UIImage imageNamed:@"icon-menu-mtags.png"];
            break;
            
            
        case 6:
            cell.textLabel.text = @"About";
            cell.imageView.image = [UIImage imageNamed:@"icon-menu-about.png"];
            break;
            
            
        case 7:
            cell.textLabel.text = @"Logout";
            cell.imageView.image = [UIImage imageNamed:@"menu-logout.png"];
            break;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 43.5, 320, 0.5)];
    [label setBackgroundColor:[UIColor lightGrayColor]];
    [cell.contentView addSubview:label];

    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leftMenuCell"];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont fontWithName:@"SanFranciscoDisplay-Light" size:16];
        
        for(UIView *view in [cell.contentView subviews])
            [view removeFromSuperview];
        
        
        switch (indexPath.row)
        {
            case 0:
                cell.textLabel.text = @"Wall";
                cell.imageView.image = [UIImage imageNamed:@"menu-home.png"];
                break;
                
            case 1:
            {
                cell.textLabel.text = @"Notifications";
                cell.imageView.image = [UIImage imageNamed:@"menu-notifications.png"];
                
                NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
                int count = 0;
                count = [[userdefaults objectForKey:@"notificationcount"] intValue];
                if([userdefaults objectForKey:@"notificationcount"] && count > 0)
                {
                    UIImageView *bubbleImage = [[UIImageView alloc] initWithFrame:CGRectMake(21, 4, 20, 20)];
                    bubbleImage.backgroundColor = [UIColor colorWithRed:197/255.0 green:33/255.0 blue:40/255.0 alpha:1.0];
                    bubbleImage.layer.cornerRadius = bubbleImage.frame.size.height /2;
                    bubbleImage.layer.masksToBounds = YES;
                    bubbleImage.layer.borderWidth = 0;
                    
                    [cell.contentView addSubview:bubbleImage];
                    
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(21, 4, 20, 20)];
                    if(count > 999)
                        [label setText:[NSString stringWithFormat:@"999"]];
                    else
                        [label setText:[NSString stringWithFormat:@"%i",count]];
                    label.textAlignment = NSTextAlignmentCenter;
                    label.font = [UIFont fontWithName:@"SanFranciscoDisplay-Light" size:10];
                    [label setTextColor:[UIColor whiteColor]];
                    [cell.contentView addSubview:label];
                }
            }
                
                break;
                
            case 2:
                cell.textLabel.text = @"About";
                cell.imageView.image = [UIImage imageNamed:@"icon-menu-about.png"];
                break;
                
                
            case 3:
                cell.textLabel.text = @"Login";
                cell.imageView.image = [UIImage imageNamed:@"lock_white.png"];
                break;
        }
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 43.5, 320, 0.5)];
        [label setBackgroundColor:[UIColor lightGrayColor]];
        [cell.contentView addSubview:label];
        
        cell.backgroundColor = [UIColor clearColor];
        
        return cell;

    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    {
    
    switch (indexPath.row)
    {
        case 0:
        {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];
            UserProfileViewCotroller *destViewController = (UserProfileViewCotroller*)[mainStoryboard
                                                                                       instantiateViewControllerWithIdentifier: @"UserProfileViewCotroller"];
            destViewController.photo = sharedModel.userProfile.image;
            destViewController.name = [NSString stringWithFormat:@"%@ %@",sharedModel.userProfile.fname,sharedModel.userProfile.lname];
            destViewController.imageUrl = sharedModel.userProfile.image;
            destViewController.handle = sharedModel.userProfile.handle;
            destViewController.profileId = sharedModel.userProfile.uid;
            [[SlideNavigationController sharedInstance] pushViewController:destViewController animated:YES];
            
        }
            
            break;
            
        case 1:
        {
            if([[[SlideNavigationController sharedInstance] topViewController] isKindOfClass:[MainStreamsViewController class]])
            {
                [(MainStreamsViewController *)[[SlideNavigationController sharedInstance] topViewController] resetFavoritesFromWall];
            }
        }
            break;
        case 2:
        {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];
            
            UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"AddPostViewController"];
            
            [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];
        }
            break;
            
            
        case 3:
        {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];
            
            UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"NotificationsViewController"];
            
            [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];
        }            break;
            
            break;

        case 4:
        {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];
            
            UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
            
            [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];
        }            break;
            
            break;
            
        case 5:
        {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];
            UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ManageTagsViewController"];
            [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];
            
        }
            break;
            
        case 6:
        {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];
            
            UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
            
            [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];
        }
            break;
            
            
        case 7:
            [self logOut];
            break;
            
            
        default:
            break;
    }
    }
    else
    {
        
        switch (indexPath.row)
        {
                
            case 0:
            {
                if([[[SlideNavigationController sharedInstance] topViewController] isKindOfClass:[MainStreamsViewController class]])
                {
                    [(MainStreamsViewController *)[[SlideNavigationController sharedInstance] topViewController] resetFavoritesFromWall];
                }
            }
                break;
                
            case 1:
            {
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                         bundle: nil];
                
                UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"NotificationsViewController"];
                
                [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];
            }            break;
                
                break;
                
            case 2:
            {
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                         bundle: nil];
                
                UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
                
                [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];
            }
                break;
                
                
            case 3:
            {
                [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];

                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                NewLoginViewController *login = [mainStoryboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
                
                CGRect screenRect = [[UIScreen mainScreen] bounds];
                CGFloat screenWidth = screenRect.size.width;
                CGFloat screenHeight = screenRect.size.height;
                
                login.view.frame = CGRectMake(0,-screenHeight,screenWidth,screenHeight);
                
                [[[[UIApplication sharedApplication] delegate] window] addSubview:login.view];
                
                
                [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    login.view.frame = CGRectMake(0,0,screenWidth,screenHeight);
                    
                }
                                 completion:^(BOOL finished){
                                     [login.view removeFromSuperview];
                                     
                                     [[SlideNavigationController sharedInstance] pushViewController:login animated:NO];
                                 }
                 ];
                

            }
                break;
                
                
            default:
                break;
        }
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
    if([[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN_KEY] != nil)
        [postDetails setObject:[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN_KEY] forKey:@"device_token"];
    [postDetails setObject:@"iOS" forKey:@"platform"];
    
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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO forKey:@"isLogedIn"];
    [userDefaults setBool:NO forKey:@"HAS_REGISTERED_KLID"];
    [userDefaults removeObjectForKey:@"notificationcount"];
    [userDefaults setBool:NO forKey:@"externalSignIn"];
    [userDefaults removeObjectForKey:@"favStreamArray"];
    
    [userDefaults synchronize];
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]
                                  initWithSuiteName:@"group.com.maisasolutions.msocl"];
    [myDefaults  removeObjectForKey:@"userprofile"];
    [myDefaults removeObjectForKey:@"access_token"];
    [myDefaults removeObjectForKey:@"tokens"];
    
    [myDefaults synchronize];

    [sharedModel clear];
    
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
    //invalidate current facebook session
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession.activeSession close];
    [FBSession setActiveSession:nil];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"share"];

    
    [appdelegate showOrhideIndicator:NO];
    sharedModel.accessToken = [tokens objectAtIndex:0];
    
    if([[[SlideNavigationController sharedInstance] topViewController] isKindOfClass:[MainStreamsViewController class]])
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:RELOAD_ON_LOG_OUT object:nil];
    }
    
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.channels = [[NSArray alloc] init];
    [currentInstallation saveEventually];

//    [Flurry setUserID:DEVICE_UUID];
    
    [[PageGuidePopUps sharedInstance] getAppConfig];
    [NotificationUtils resetParseChannels];
    
}

- (void)fetchingTokensFailedWithError
{
    [appdelegate showOrhideIndicator:NO];
}

@end
