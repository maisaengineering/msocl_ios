//
//  Webservices.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "Webservices.h"
#import "Reachability.h"
#import "AccessToken.h"

@implementation Webservices
Webservices *sharedObj;
+(Webservices *)sharedInstance{
    
    /* Use this to make it a singleton class */
    if (sharedObj==Nil) {
        sharedObj=[[Webservices alloc]init];
    }
    return sharedObj;
    /**/
}

-(id)init{
    if (sharedObj) {
        return sharedObj;
    }
    else{
        if (self=[super init]) {
            //initialize the variables
            apiConnector=[APIConnector sharedInstance];
            apiConnector.delegate = self;
        }
        return self;
    }
}

#pragma mark check Internet Connectivity
-(BOOL)internetIsAvailable
{
    Reachability *reachibility=[Reachability reachabilityForInternetConnection];
    if([reachibility currentReachabilityStatus]==NotReachable)
    {
        //show an alertView stating that internet connection is unavailable
        // ShowAlert(@"iRant", @"Internet connection unavailable", @"OK");
        
        //raise a notification to stop all the activity indicators(all HUD classes should implement this)
        //[[NSNotificationCenter defaultCenter]postNotificationName:@"InternetConnectionUnavailable" object:nil];
        return FALSE;
    }
    return TRUE;
}

-(BOOL)checkForInternetConnectivity{
    Reachability *reachibility=[Reachability reachabilityForInternetConnection];
    if([reachibility currentReachabilityStatus]==NotReachable)
    {
        
        //show an alertView stating that internet connection is unavailable
        //   ShowAlert(NSLocalizedString(@"project.name", nil),NSLocalizedString(@"Internet.connection.unavailable", nil), NSLocalizedString(@"ok.button.text", nil));
        return FALSE;
    }
    return TRUE;
}

#pragma mark -
#pragma mark Api calls
-(void)getAccessToken:(NSDictionary *)postData
{
    NSString *urlAsString = [NSString stringWithFormat:@"%@clients/token",BASE_URL];
    [apiConnector fetchJSON:postData :urlAsString :@"GetAccessToken"];
}
-(void)getPromptImages:(NSDictionary *)postData
{
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    [apiConnector fetchJSON:postData :urlAsString :@"GetPromptImages"];

}
#pragma mark -
#pragma mark Call backs from api connector
-(void) handleConnectionSuccess:(NSDictionary *)recievedDict
{
    NSString *command = [recievedDict objectForKey:@"command"];
    NSDictionary *responseDict = [recievedDict objectForKey:@"response"];
    if([command isEqualToString:@"GetAccessToken"])
    {
        [self connectionSuccessGetAccessTokens:responseDict];
    }
    else if([command isEqualToString:@"GetPromptImages"])
    {
        [self connectionSuccessGetPromptImages:responseDict];
    }
}
-(void) handleConnectionFailure:(NSDictionary *)recievedDict
{
    NSString *command = [recievedDict objectForKey:@"command"];
    if([command isEqualToString:@"GetAccessToken"])
    {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:API_FAILED__GET_ACCESS_TOKEN object:nil userInfo:nil]];
    }
    else if([command isEqualToString:@"GetPromptImages"])
    {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:API_FAILED__GET_PROMPT_IMAGES object:nil userInfo:nil]];
    }
}

#pragma mark -
#pragma mark Connection Success Handlers 
-(void)connectionSuccessGetAccessTokens:(NSDictionary *)respDict
{
    NSMutableArray *tokens = [[NSMutableArray alloc] init];
    AccessToken *token = [[AccessToken alloc] init];
    
    for (NSString *key in respDict)
    {
        if ([token respondsToSelector:NSSelectorFromString(key)]) {
            
            [token setValue:[respDict valueForKey:key] forKey:key];
        }
    }
    
    [tokens addObject:token];
    [[NSUserDefaults standardUserDefaults] setObject:respDict forKey:@"tokens"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:API_SUCCESS_GET_ACCESS_TOKEN object:tokens userInfo:nil]];

}
-(void)connectionSuccessGetPromptImages:(NSDictionary *)respDict
{
    
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:API_SUCCESS_GET_PROMPT_IMAGES object:[respDict objectForKey:@"body"] userInfo:nil]];

    }
    
    else
    {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:API_FAILED__GET_PROMPT_IMAGES object:nil userInfo:nil]];

    }

}
@end
