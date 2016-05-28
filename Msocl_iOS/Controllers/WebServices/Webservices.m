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
#import "NotificationDetails.h"
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
    else if([command isEqualToString:@"GetFav"])
    {
        [self connectionSuccessGetFav:responseDict];
    }
    else if([command isEqualToString:@"ShowPost"])
    {
        [self connectionSuccessGetShowPost:responseDict];
    }
    else if([command isEqualToString:@"externalSignIn"])
    {
        [self connectionSuccessExternalSignIn:responseDict];
    }
    else if([command isEqualToString:@"signOut"])
    {
        [self connectionSuccessSignOut:responseDict];
    }
    else if([command isEqualToString:@"Comment"])
    {
        [self connectionSuccessComment:responseDict];
    }
    
    else if([command isEqualToString:@"time_reminders"])
    {
        [self connectionSuccessPageGuidePopUpImages:responseDict];
    }
    else if([command isEqualToString:@"visited_page_guides"])
    {
        [self connectionSuccessVisitedPageGuides:responseDict];
    }
    else if([command isEqualToString:@"updatePost"])
    {
        [self connectionSuccessUpdatePost:responseDict];
    }
    else if([command isEqualToString:@"hearting"])
    {
        [self connectionSuccessHearting:responseDict];
    }
    else if([command isEqualToString:@"deletePost"])
    {
        [self connectionSuccessDeletePost:responseDict];
    }
    else if([command isEqualToString:@"commentUpvote"])
    {
        [self connectionSuccessCommentUpVote:responseDict];
    }
    else if([command isEqualToString:@"changePassword"])
    {
        [self connectionSuccessChangePassword:responseDict];
    }
    else if([command isEqualToString:@"followUser"])
    {
        [self connectionSuccessFollowUser:responseDict];
    }
    else if([command isEqualToString:@"followGroup"])
    {
        [self connectionSuccessFollowGroup:responseDict];
    }
    else if([command isEqualToString:@"flag"])
    {
        [self connectionSuccessFlag:responseDict];
    }
    else if([command isEqualToString:@"flagComment"])
    {
        [self connectionSuccessFlagComment:responseDict];
    }
    else if([command isEqualToString:@"resetPassword"])
    {
        [self connectionSuccessResetPassword:responseDict];
    }
    else if([command isEqualToString:@"ProfileDetails"])
    {
        [self connectionSuccessProfile:responseDict];
    }
    else if([command isEqualToString:@"appConfig"])
    {
        [self connectionSuccessExternalSignInOptions:responseDict];
    }
    
    else if([command isEqualToString:@"emailNotify"])
    {
        [self connectionSuccessEmailNotification:responseDict];
    }
    
    else if([command isEqualToString:@"apnNotify"])
    {
        [self connectionSuccessPushNotification:responseDict];
    }
    else if([command isEqualToString:@"handle"])
    {
        [self connectionSuccessHandle:responseDict];
    }
    else if([command isEqualToString:@"GetNotifications"])
    {
        [self connectionSuccessNotifications:responseDict];
    }
    else if([command isEqualToString:@"newSession"])
    {
        [self  connectionSuccessNewSession:responseDict];
    }

    else if([command isEqualToString:@"shareUrl"])
    {
        [self  connectionSuccessShareUrl:responseDict];
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
        [self.delegate loginFailed:[recievedDict objectForKey:@"response"]];
    }
    else if([command isEqualToString:@"SignUp"])
    {
        [self.delegate signUpFailed:[recievedDict objectForKey:@"response"]];
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
    else if([command isEqualToString:@"externalSignIn"])
    {
        [self.delegate showExternalSignInFailed];
    }
    else if([command isEqualToString:@"signOut"])
    {
        [self.delegate signOutFailed];
    }
    else if([command isEqualToString:@"Comment"])
    {
        [self.delegate commentFailed];
    }
    else if([command isEqualToString:@"time_reminders"])
    {
        [self.delegate pageGuideImagesFailed];
    }
    else if([command isEqualToString:@"visited_page_guides"])
    {
        [self.delegate visitedPageGuidesFailed];
    }
    else if([command isEqualToString:@"updatePost"])
    {
        [self.delegate updatePostFailed:[recievedDict objectForKey:@"response"]];
    }
    else if([command isEqualToString:@"hearting"])
    {
        [self.delegate heartingFailed];
    }
    else if([command isEqualToString:@"deletePost"])
    {
        [self.delegate postDeleteFailed];
    }
    else if([command isEqualToString:@"commentUpvote"])
    {
        [self.delegate commentUpVoteFailed];
    }
    else if([command isEqualToString:@"changePassword"])
    {
        [self.delegate changePasswordFailed];
    }
    else if([command isEqualToString:@"followUser"])
    {
        [self.delegate followingUserFailed];
    }
    else if([command isEqualToString:@"followGroup"])
    {
        [self.delegate followingGroupFailed];
    }
    else if([command isEqualToString:@"flag"])
    {
        [self.delegate flagFailed];
    }
    else if([command isEqualToString:@"flagComment"])
    {
        [self.delegate flagCommentFailed];
    }
    else if([command isEqualToString:@"resetPassword"])
    {
        [self.delegate resetPasswordFailed];
    }
    else if([command isEqualToString:@"GetFav"])
    {
        [self.delegate FavPostFailed];
    }
    else if([command isEqualToString:@"ProfileDetails"])
    {
        [self.delegate profileDetailsFailed];
    }
    else if([command isEqualToString:@"appConfig"])
    {
        [self.delegate externalSigninOptionsFailed];
    }
    else if([command isEqualToString:@"emailNotify"])
    {
        [self.delegate emailNotificationFailed];
    }
    else if([command isEqualToString:@"apnNotify"])
    {
        [self.delegate pushNotificationFailed];
    }
    else if([command isEqualToString:@"handle"])
    {
        [self.delegate handleFailed];
    }
    else if([command isEqualToString:@"newSession"])
    {
        [self.delegate handleFailed];
    }
    else if([command isEqualToString:@"shareUrl"])
    {
        [self.delegate shareUrlFailed];
    }
}
#pragma mark -
#pragma mark Connection Success Handlers
-(void)connectionSuccessGetAccessTokens:(NSDictionary *)respDict
{
    [[NSUserDefaults standardUserDefaults] setObject:respDict forKey:@"tokens"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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
    NSDictionary *response = [respDict objectForKey:@"response"];
    NSNumber *validResponseStatus = [response valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate profileImageUploadSccess:[response objectForKey:@"body"]];
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
-(void)connectionSuccessUpdatePost:(NSDictionary *)respDict
{
    PostDetails *postObject = [[PostDetails alloc] initWithDictionary:[respDict objectForKey:@"body"]];
    
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate updatePostSccessfull:postObject];
        
    }
    
    else
    {
        [self.delegate updatePostFailed:respDict];
        
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
        [self.delegate loginFailed:respDict];
        
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
        [self.delegate signUpFailed:respDict];
        
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
-(void)connectionSuccessGetFav:(NSDictionary *)respDict
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
        [self.delegate didReceiveFavPost:dictCopty originalPosts:arrayPostDetails];
        
        
    }
    
    else
    {
        [self.delegate FavPostFailed];
        
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
        
        NSString *anonymousUrl = [[respDict objectForKey:@"body"] objectForKey:@"anonymous_image"];
        
        [[NSUserDefaults standardUserDefaults] setObject:anonymousUrl forKey:@"anonymous_image"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        [self.delegate didReceiveStreams:dictCopty originalPosts:arrayPostDetails];
        
        
    }
    
    else
    {
        [self.delegate streamsFailed];
        
    }
    
}
-(void)connectionSuccessNotifications:(NSDictionary *)respDict
{
    NSMutableDictionary *dictCopty = [[respDict objectForKey:@"body"] mutableCopy];
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        NSArray *arrayPostDetails = [[respDict objectForKey:@"body"] objectForKey:@"notifications"];
        NSMutableArray *arrayOfpostDetailsObjects=[NSMutableArray arrayWithCapacity:0];
        
        for(NSDictionary *postDict in arrayPostDetails)
        {
            NotificationDetails *postObject = [[NotificationDetails alloc] initWithDictionary:postDict];
            [arrayOfpostDetailsObjects addObject:postObject];
        }
        [dictCopty setObject:arrayOfpostDetailsObjects forKey:@"notifications"];
        
        [self.delegate didReceiveNotification:dictCopty];
        
    }
    
    else
    {
        [self.delegate notificationFailed];
        
    }
    
}
-(void)connectionSuccessGetShowPost:(NSDictionary *)respDict
{
    NSMutableDictionary *dictCopty = [[respDict objectForKey:@"body"] mutableCopy];
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        NSMutableArray *arrayOfpostDetailsObjects=[[NSMutableArray alloc] init];
        
        
        PostDetails *postObject = [[PostDetails alloc] initWithDictionary:dictCopty];
        [arrayOfpostDetailsObjects addObject:postObject];
        
        [self.delegate didReceiveShowPost:[NSDictionary dictionaryWithObject:arrayOfpostDetailsObjects forKey:@"posts"]];
    }
    
    else
    {
        [self.delegate showPostFailed];
        
    }
    
}

-(void)connectionSuccessExternalSignIn:(NSDictionary *)respDict
{
    NSMutableDictionary *dictCopty = [[respDict objectForKey:@"body"] mutableCopy];
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate didReceiveExternalSignIn:dictCopty];
    }
    
    else
    {
        [self.delegate showExternalSignInFailed];
        
    }
    
}
-(void)connectionSuccessNewSession:(NSDictionary *)respDict
{
    NSMutableDictionary *dictCopty = [[respDict objectForKey:@"body"] mutableCopy];
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate newSessionSuccessFull:dictCopty];
    }
    
    else
    {
        [self.delegate newSessionFailed];
        
    }
    
}
-(void)connectionSuccessShareUrl:(NSDictionary *)respDict
{
    NSMutableDictionary *dictCopty = [[respDict objectForKey:@"body"] mutableCopy];
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate shareUrlSuccessFull:dictCopty];
    }
    
    else
    {
        [self.delegate shareUrlFailed];
        
    }
    
}

-(void)connectionSuccessSignOut:(NSDictionary *)respDict
{
    NSMutableDictionary *dictCopty = [[respDict objectForKey:@"body"] mutableCopy];
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate signOutSccessfull:dictCopty];
    }
    
    else
    {
        [self.delegate signOutFailed];
        
    }
    
}
-(void)connectionSuccessComment:(NSDictionary *)respDict
{
    NSMutableDictionary *dictCopty = [[respDict objectForKey:@"body"] mutableCopy];
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate commentSuccessful:dictCopty];
    }
    
    else
    {
        [self.delegate signOutFailed];
        
    }
    
}
-(void)connectionSuccessExternalSignInOptions:(NSDictionary *)respDict
{
    NSMutableDictionary *dictCopty = [[respDict objectForKey:@"body"] mutableCopy];
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate externalSigninOptionsSuccessFull:dictCopty];
    }
    
    else
    {
        [self.delegate externalSigninOptionsFailed];
        
    }
    
}

-(void)connectionSuccessPageGuidePopUpImages:(NSDictionary *)respDict
{
    NSMutableArray *arrayCopty = [[respDict objectForKey:@"body"] mutableCopy];
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate didReceivePageGuideImagesSuccessful:arrayCopty];
    }
    
    else
    {
        [self.delegate pageGuideImagesFailed];
        
    }
}
-(void)connectionSuccessVisitedPageGuides:(NSDictionary *)respDict
{
    NSMutableArray *arrayCopty = [[respDict objectForKey:@"body"] mutableCopy];
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate didReceiveVisitedPageGuidesSuccessful:arrayCopty];
    }
    
    else
    {
        [self.delegate visitedPageGuidesFailed];
        
    }
}
-(void)connectionSuccessHearting:(NSDictionary *)respDict
{
    NSMutableDictionary *dictCopty = [[respDict objectForKey:@"body"] mutableCopy];
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate heartingSuccessFull:dictCopty];
    }
    
    else
    {
        [self.delegate heartingFailed];
        
    }
    
}
-(void)connectionSuccessDeletePost:(NSDictionary *)respDict
{
    NSMutableDictionary *dictCopty = [[respDict objectForKey:@"body"] mutableCopy];
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate postDeleteSuccessFull:dictCopty];
    }
    
    else
    {
        [self.delegate postDeleteFailed];
        
    }
}
-(void)connectionSuccessCommentUpVote:(NSDictionary *)respDict
{
    NSMutableDictionary *dictCopty = [[respDict objectForKey:@"body"] mutableCopy];
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate commentUpVoteSuccessFull:dictCopty];
    }
    
    else
    {
        [self.delegate commentUpVoteFailed];
        
    }
}
-(void)connectionSuccessFollowUser:(NSDictionary *)respDict
{
    NSMutableDictionary *dictCopty = [[respDict objectForKey:@"body"] mutableCopy];
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate followingUserSuccessFull:dictCopty];
    }
    
    else
    {
        [self.delegate followingUserFailed];
        
    }
}

-(void)connectionSuccessChangePassword:(NSDictionary *)respDict
{
    NSMutableDictionary *dictCopty = [[respDict objectForKey:@"body"] mutableCopy];
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate changePasswordSuccessFull:dictCopty];
    }
    
    else
    {
        [self.delegate changePasswordFailed];
        
    }
}

-(void)connectionSuccessFollowGroup:(NSDictionary *)respDict
{
    NSMutableDictionary *dictCopty = [[respDict objectForKey:@"body"] mutableCopy];
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate followingGroupSuccessFull:dictCopty];
    }
    
    else
    {
        [self.delegate followingGroupFailed];
        
    }
}

-(void)connectionSuccessFlag:(NSDictionary *)respDict
{
    NSMutableDictionary *dictCopty = [[respDict objectForKey:@"body"] mutableCopy];
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate flagSuccessFull:dictCopty];
    }
    
    else
    {
        [self.delegate flagFailed];
        
    }
}
-(void)connectionSuccessFlagComment:(NSDictionary *)respDict
{
    NSMutableDictionary *dictCopty = [[respDict objectForKey:@"body"] mutableCopy];
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate flagCommentSuccessFull:dictCopty];
    }
    
    else
    {
        [self.delegate flagCommentFailed];
        
    }
}
-(void)connectionSuccessResetPassword:(NSDictionary *)respDict
{
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate resetPasswordSuccessFull:respDict];
    }
    
    else
    {
        [self.delegate resetPasswordFailed];
        
    }
}
-(void)connectionSuccessProfile:(NSDictionary *)respDict
{
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate profileDetailsSuccessFull:respDict];
    }
    
    else
    {
        [self.delegate profileDetailsFailed];
        
    }
}
-(void)connectionSuccessEmailNotification:(NSDictionary *)respDict
{
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate emailNotificationSuccessFull:respDict];
    }
    
    else
    {
        [self.delegate emailNotificationFailed];
        
    }
}
-(void)connectionSuccessPushNotification:(NSDictionary *)respDict
{
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate pushNotificationSuccessFull:respDict];
    }
    
    else
    {
        [self.delegate pushNotificationFailed];
        
    }
}

-(void)connectionSuccessHandle:(NSDictionary *)respDict
{
    NSNumber *validResponseStatus = [respDict valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        [self.delegate handleSuccessFull:respDict];
    }
    
    else
    {
        [self.delegate handleFailed];
        
    }
}

@end
