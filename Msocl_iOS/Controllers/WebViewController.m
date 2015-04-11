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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appdelegate = [[UIApplication sharedApplication] delegate];
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;

    
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320 , Deviceheight)];
    NSURL *url = [[NSURL alloc]initWithString:FACEBOOK_URL];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
    
    [webView loadRequest:urlRequest];
    [webView setDelegate:self];
    [self.view addSubview:webView];
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
