//
//  WebViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions Pvt Ltd on 11/04/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "WebViewController.h"
#import "StringConstants.h"
#import "ModelManager.h"
#import "AppDelegate.h"
#import "PromptImages.h"

@interface WebViewController ()

@end

@implementation WebViewController
@synthesize tagValue;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appdelegate = [[UIApplication sharedApplication] delegate];
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;

    
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320 , Deviceheight)];
    NSURL *url;
    if (tagValue == 1)
    {
        // FACEBOOK
        url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@facebook",OAUTH_URL]];
    }
    else if (tagValue == 2)
    {
        // TWITTER
        url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@twitter",OAUTH_URL2]];
    }
    else if (tagValue == 3)
    {
        // GMAIL
        url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@google_oauth2",OAUTH_URL2]];
    }
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
    
    [webView loadRequest:urlRequest];
    [webView setDelegate:self];
    [self.view addSubview:webView];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
}
#pragma mark -
#pragma mark - UIWebViewDelegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSString *url = [[request URL] absoluteString];
    
    static NSString *kidsLinkPrefix = @"socl://fb_success";
    
    if([url hasPrefix:kidsLinkPrefix])
    {
        // socl://fb_success/uid=c2e872f7-58ac-4f19-bd95-5137f5d8a355.
        
        NSString *uid = [url substringFromIndex:22];
        [self callExternalSignInAPIWithUserUId:uid];
        }
    return YES;
}

#pragma mark -
#pragma mark - callExternalSignInAPI method

-(void)callExternalSignInAPIWithUserUId:(NSString *)user_uid
{
    [appdelegate showOrhideIndicator:YES];
    
    NSMutableDictionary *postDetails  = [NSMutableDictionary dictionary];
    [postDetails setObject:user_uid forKey:@"uid"];
    [postDetails setObject:DEVICE_UUID forKey:@"device_token"];
    [postDetails setObject:@"iOS" forKey:@"platform"];
    
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    
    NSString *command = @"externalSignIn";
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": command,
                               @"body": postDetails};
    NSDictionary *userInfo = @{@"command": command};
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}
#pragma mark -
#pragma mark - webServiceProtocol method

-(void) didReceiveExternalSignIn:(NSDictionary *)recievedDict
{
    [appdelegate showOrhideIndicator:NO];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLogedIn"];
    
    [[NSUserDefaults standardUserDefaults] setObject:recievedDict forKey:@"userprofile"];
    
    NSMutableDictionary *tokenDict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"tokens"] mutableCopy];
    [tokenDict setObject:[recievedDict objectForKey:@"access_token"] forKey:@"access_token"];
    [[NSUserDefaults standardUserDefaults] setObject:tokenDict forKey:@"tokens"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[[ModelManager sharedModel] accessToken] setAccess_token:[recievedDict objectForKey:@"access_token"]];
    [[ModelManager sharedModel] setUserDetails:recievedDict];
    [[PromptImages sharedInstance] getAllGroups];
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    [self.navigationController popToViewController:viewControllers[viewControllers.count - 3] animated:YES];
}
-(void) showExternalSignInFailed
{
    [appdelegate showOrhideIndicator:NO];
    ShowAlert(@"Error", @"ExternalSignIn Failed", @"OK");
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
