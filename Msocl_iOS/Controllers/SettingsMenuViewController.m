//
//  SettingsMenuViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/13/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "SettingsMenuViewController.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"
#import "ModelManager.h"
#import "MainStreamsViewController.h"
@implementation SettingsMenuViewController

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

   appdelegate = [[UIApplication sharedApplication] delegate];

    
}
#pragma mark - UITableView Delegate & Datasrouce -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leftMenuCell"];
    
    cell.textLabel.textColor = [UIColor blackColor];
    switch (indexPath.row)
    {
        case 0:
            cell.textLabel.text = @"Home";
            break;
            
        case 1:
            cell.textLabel.text = @"Profile";
            break;
            
        case 2:
            cell.textLabel.text = @"Sign Out";
            break;
            
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    UIViewController *vc ;
    
    switch (indexPath.row)
    {
        case 0:
            break;
            
        case 1:
            break;
            
        case 2:
            if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
            [self logOut];
            ;
            break;
            
        case 3:
           // [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
            //[[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
            return;
            break;
    }
    
//    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
//                                                             withSlideOutAnimation:self.slideOutAnimationEnabled
//                                                                     andCompletion:nil];
    [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
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

-(void)logOut
{
    // call clearFBCookiesFromWebview 
    [self clearFBCookiesFromWebview];
    
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
    [appdelegate showOrhideIndicator:YES];
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
