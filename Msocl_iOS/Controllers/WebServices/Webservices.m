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
#import "PostDetails.h"
@implementation Webservices
@synthesize delegate;
-(id)init{
    
    if (self=[super init]) {
        //initialize the variables
        apiConnector=[[APIConnector alloc] init];
        apiConnector.delegate = self;
    }
    return self;
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
-(void)callApi:(NSDictionary *)postData :(NSString *)urlAsString
{
    [apiConnector fetchJSON:[postData objectForKey:@"postData"] :urlAsString :[postData objectForKey:@"userInfo"]];
}
#pragma mark -
#pragma mark Call backs from api connector
-(void) handleConnectionSuccess:(NSDictionary *)recievedDict
{
    NSDictionary *userInfo = [recievedDict objectForKey:@"userInfo"];
    NSString *command = [userInfo objectForKey:@"command"];
    NSDictionary *responseDict = [recievedDict objectForKey:@"response"];
    if([command isEqualToString:@"GetAccessToken"])
    {
        [self connectionSuccessGetAccessTokens:responseDict];
    }
    else if([command isEqualToString:@"GetPromptImages"])
    {
        [self connectionSuccessGetPromptImages:responseDict];
    }
    else if([command isEqualToString:@"upload_to_s3"])
    {
        [self connectionSuccessUploadPostImages:recievedDict];
    }
    else if([command isEqualToString:@"upload_Profile_Image"])
    {
        [self connectionSuccessUploadProfileImages:recievedDict];
    }
    else if([command isEqualToString:@"createPost"])
    {
        [self connectionSuccessCreatePost:responseDict];
    }
    else if([command isEqualToString:@"Login"])
    {
        [self connectionSuccessLogin:responseDict];
    }
    else if([command isEqualToString:@"SignUp"])
    {
        [self connectionSuccessSignUp:responseDict];
    }
    else if([command isEqualToString:@"GetAllGroups"])
    {
        [self connectionSuccessGetAllGroups:responseDict];
    }
    else if([command isEqualToString:@"GetStreams"])
    {
        [self connectionSuccessGetStreams:responseDict];
    }
    else if([command isEqualToString:@"ShowPost"])
    {
        [self connectionSuccessGetShowPost:responseDict];
    }
}
-(void) handleConnectionFailure:(NSDictionary *)recievedDict
{
    NSString *command = [recievedDict objectForKey:@"command"];
    if([command isEqualToString:@"GetAccessToken"])
    {
        [self.delegate fetchingTokensFailedWithError];
    }
    else if([command isEqualToString:@"GetPromptImages"])
    {
        [self.delegate fetchingPromptImagesFailedWithError];
    }
    else if([command isEqualToString:@"upload_to_s3"])
    {
        [self.delegate uploadImageFailed];
    }
    else if([command isEqualToString:@"upload_Profile_Image"])
    {
        [self.delegate profileImageUploadFailed];
    }
    else if([command isEqualToString:@"createPost"])
    {
        [self.delegate postCreationFailed];
    }
    else if([command isEqualToString:@"Login"])
    {
        [self.delegate loginFailed];
    }
    else if([command isEqualToString:@"SignUp"])
    {
        [self.delegate signUpFailed];
    }
    else if([command isEqualToString:@"GetAllGroups"])
    {
        [self.delegate fetchingGroupsFailedWithError];
    }
    else if([command isEqualToString:@"GetStreams"])
    {
        [self.delegate streamsFailed];
    }
    else if([command isEqualToString:@"ShowPost"])
    {
        [self.delegate showPostFailed];
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
    
    [self.delegate didReceiveTokens:tokens];
}
-(void)connectionSuccessGetPromptImages:(NSDictionary *)respDict
{
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate didReceivePromptImages:[respDict objectForKey:@"body"]];
        
    }
    
    else
    {
        [self.delegate fetchingPromptImagesFailedWithError];
        
    }
    
}
-(void)connectionSuccessUploadPostImages:(NSDictionary *)respDict
{
    NSDictionary *userInfo = [respDict objectForKey:@"userInfo"];
    NSDictionary *response = [respDict objectForKey:@"response"];
    NSString *identifier = [userInfo objectForKey:@"identifier"];
    
    
    NSNumber *validResponseStatus = [response valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate uploadImageSccess:[NSDictionary dictionaryWithObjectsAndKeys:[response objectForKey:@"body"],@"response",identifier,@"identifier", nil]];
        
    }
    
    else
    {
        [self.delegate uploadImageFailed];
        
    }
    
}
-(void)connectionSuccessUploadProfileImages:(NSDictionary *)respDict
{
    NSDictionary *userInfo = [respDict objectForKey:@"userInfo"];
    NSDictionary *response = [respDict objectForKey:@"response"];
    NSString *identifier = [userInfo objectForKey:@"identifier"];
    
    
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate profileImageUploadSccess:[NSDictionary dictionaryWithObjectsAndKeys:[response objectForKey:@"body"],@"response",identifier,@"identifier", nil]];
    }
    
    else
    {
        [self.delegate profileImageUploadFailed];
        
    }
    
}
-(void)connectionSuccessCreatePost:(NSDictionary *)respDict
{
    
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate postCreationSccessfull:[respDict objectForKey:@"body"]];
        
    }
    
    else
    {
        [self.delegate postCreationFailed];
        
    }
    
}

-(void)connectionSuccessLogin:(NSDictionary *)respDict
{
    
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate loginSccessfull:[respDict objectForKey:@"body"]];
        
    }
    
    else
    {
        [self.delegate loginFailed];
        
    }
    
}

-(void)connectionSuccessSignUp:(NSDictionary *)respDict
{
    
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate signUpSccessfull:[respDict objectForKey:@"body"]];
        
    }
    
    else
    {
        [self.delegate signUpFailed];
        
    }
    
}
-(void)connectionSuccessGetAllGroups:(NSDictionary *)respDict
{
    
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate didReceiveGroups:[respDict objectForKey:@"body"]];
        
    }
    
    else
    {
        [self.delegate fetchingGroupsFailedWithError];
        
    }
    
}
-(void)connectionSuccessGetStreams:(NSDictionary *)respDict
{
    NSMutableDictionary *dictCopty = [[respDict objectForKey:@"body"] mutableCopy];
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        NSArray *arrayPostDetails = [[respDict objectForKey:@"body"] objectForKey:@"posts"];
        NSMutableArray *arrayOfpostDetailsObjects=[NSMutableArray arrayWithCapacity:0];
        
        for(NSDictionary *postDict in arrayPostDetails)
        {
            PostDetails *postObject = [[PostDetails alloc] initWithDictionary:postDict];
            [arrayOfpostDetailsObjects addObject:postObject];
        }
        [dictCopty setObject:arrayOfpostDetailsObjects forKey:@"posts"];
        [self.delegate didReceiveStreams:dictCopty];
        
        
    }
    
    else
    {
        [self.delegate streamsFailed];
        
    }
    
}
-(void)connectionSuccessGetShowPost:(NSDictionary *)respDict
{
    NSMutableDictionary *dictCopty = [[respDict objectForKey:@"body"] mutableCopy];
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        NSArray *arrayPostDetails = [[respDict objectForKey:@"body"] objectForKey:@"posts"];
        NSMutableArray *arrayOfpostDetailsObjects=[NSMutableArray arrayWithCapacity:0];
        
        for(NSDictionary *postDict in arrayPostDetails)
        {
            PostDetails *postObject = [[PostDetails alloc] initWithDictionary:postDict];
            [arrayOfpostDetailsObjects addObject:postObject];
        }
        [dictCopty setObject:arrayOfpostDetailsObjects forKey:@"posts"];
        [self.delegate didReceiveShowPost:dictCopty];
        
    }
    
    else
    {
        [self.delegate showPostFailed];
        
    }
    
}
@end
