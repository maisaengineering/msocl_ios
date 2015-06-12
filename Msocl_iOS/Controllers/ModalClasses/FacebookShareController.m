//
//  FacebookShareController.m
//  KidsLink
//
//  Created by Dale McIntyre on 8/20/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import "FacebookShareController.h"
#import "StringConstants.h"
#import "ModelManager.h"

@implementation FacebookShareController

@synthesize postedConfirmationDelegate;
// To avoid the memory leaks declare a global alert
@synthesize globalAlert;

-(void)PostToFacebookViaAPI:(NSString *)imageURL : (NSString *)title : (NSString *)description : (NSString *)postType //milestone or moment
{
    //permissions we need
    NSArray *permissions = [NSArray arrayWithObjects:@"publish_actions", nil];
    
    [FBSession openActiveSessionWithPublishPermissions:permissions defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:YES
                                     completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         
         __block NSString *alertTitle;
         if (!error){
             
             if (state == FBSessionStateOpen)
             {
                 // instantiate a Facebook Open Graph object
                 NSMutableDictionary<FBOpenGraphObject> *object = [FBGraphObject openGraphObjectForPost];
                 object.provisionedForPost = YES;
                 object[@"title"] = @"";
                 object[@"type"] = [NSString stringWithFormat:@"%@:%@",FACEBOOK_NAME_SPACE, postType];
                 
                 
                
//                     object[@"image"] = @[
//                                          @{@"url": @"http://www.mykidslink.com/kl_icon_big.png", @"user_generated" : @"false" }
//                                          ];
//                     object[@"description"] = @"SamePinch";

                 object[@"url"] = imageURL;

                 // Make the object request
                 [FBRequestConnection startForPostOpenGraphObject:object completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                     
                     if(!error) {
                         // get the object ID for the Open Graph object that is now stored in the Object API
                         NSString *objectId = [result objectForKey:@"id"];
                         //NSLog([NSString stringWithFormat:@"object id: %@", objectId]);
  
                         // create an Open Graph action
                         id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
                         [action setObject:objectId forKey:postType];
                         [action setObject: @"true" forKey: @"fb:explicitly_shared"];
                         
 
                         [action setMessage:description];
            
                         
                         // create action referencing user owned object
                         NSString *graphPath = [NSString stringWithFormat:@"me/%@:share",FACEBOOK_NAME_SPACE];
                         [FBRequestConnection startForPostWithGraphPath:graphPath graphObject:action completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                             
                             if(!error)
                             {

                                  [[NSNotificationCenter defaultCenter]postNotificationName:@"FACEBOOK_SUCCESS" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"Success"]];
                                 
                                //NSLog([NSString stringWithFormat:@"OG story posted, story id: %@", [result objectForKey:@"id"]]);
                                NSLog(@"See the story at: https://www.facebook.com/dmcin1/activity/%@", [result objectForKey:@"id"]);
                                 
                             }
                             else
                             {
                                 [[NSNotificationCenter defaultCenter]postNotificationName:@"FACEBOOK_SUCCESS" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"Success"]];
                                 // An error occurred
                                 NSLog(@"Encountered an error posting to Open Graph: %@", error);
                                 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Facebook Error"
                                                                                message:@"There was an error posting to Facebook. Please try again later."
                                                                               delegate:self cancelButtonTitle:@"Ok"
                                                       
                                                                      otherButtonTitles:nil,nil];
                                 self.globalAlert = alert;
                                 [alert show];
                             }
                         }];
                         
                     } else {
                         // An error occurred
                         [[NSNotificationCenter defaultCenter]postNotificationName:@"FACEBOOK_SUCCESS" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"Success"]];
                         NSLog(@"Error posting the Open Graph object to the Object API: %@", error);
                         NSLog(@"Error Code: %@", error.userInfo);
                         
                         NSString *errorString = [NSString stringWithFormat:@"%@",error.userInfo];
                         if ([errorString rangeOfString:@"#332"].location == NSNotFound)
                         {
                             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Facebook Error"
                                                                            message:@"There was an error posting to Facebook. Please try again later."
                                                                           delegate:self cancelButtonTitle:@"Ok"
                                                   
                                                                  otherButtonTitles:nil,nil];
                             self.globalAlert = alert;
                             [alert show];

                         }
                         else
                         {
                             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Facebook Error"
                                                                            message:@"Cropped image is too small for Facebook"
                                                                           delegate:self cancelButtonTitle:@"Ok"
                                                   
                                                                  otherButtonTitles:nil,nil];
                             self.globalAlert = alert;
                             [alert show];
                         }

                         
                                              }
                 }];
                 
                 //end posting
                 
             }
             else
             {
                 // There was an error, handle it
                 if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
                     // Error requires people using an app to make an action outside of the app to recover
                     // The SDK will provide an error message that we have to show the user
                     alertTitle = @"Something went wrong";

                     
                 }
                 else {
                     // If the user cancelled login
                     if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {

                         
                     }
                 }
                 
             }
         }
     }];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSLog(@"Invite");
        [[NSNotificationCenter defaultCenter]postNotificationName:@"GoToFriends" object:nil];

        
    }
    
    if (buttonIndex == 2)
    {
        NSLog(@"Cancel");
        
    }
}

/*
-(void) PostToFacebook: (NSString *)imageURL : (NSString *)title : (NSString *)description : (NSString *)postType //milestone or moment
{
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs  canPresentShareDialog])
    {
        [self PostToFacebookShareDialogOpenGraphURLImageOnAction: imageURL: title: description:postType];
    }
    else
    {
        [self PostToFacebookFeedDialog: imageURL: title: description: postType];
    }
}
*/





// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

-(void)checkFacebookPermissions
{
    //permissions we need
    NSArray *permissions = [NSArray arrayWithObjects:@"publish_actions", nil];
    
    NSMutableDictionary *fbData = [[NSMutableDictionary alloc] init];
    [fbData setValue:@"FALSE" forKey:@"SHOW_FACEBOOK"];
    
    [FBSession openActiveSessionWithPublishPermissions:permissions defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:YES
                                     completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error)
    {

         if (!error)
         {
             
             if (state == FBSessionStateOpen)
             {
                 
                 [fbData setValue:@"TRUE" forKey:@"SHOW_FACEBOOK"];
                 [[NSNotificationCenter defaultCenter]postNotificationName:FACEBOOK_CHECK object:nil userInfo:fbData];
                 
             }
             
         } else
         {
             // There was an error, handle it
             if ([FBErrorUtility shouldNotifyUserForError:error] == YES)
             {
                 // Error requires people using an app to make an action outside of the app to recover
                 // The SDK will provide an error message that we have to show the user
                 
                 
             } else
             {
                 // If the user cancelled login
                 if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled)
                 {
                     
                     
                 
                 }
             }
             [[NSNotificationCenter defaultCenter]postNotificationName:FACEBOOK_CHECK object:nil userInfo:fbData];
         }
     }];
    
    
}
- (void)dealloc
{
    self.globalAlert = nil;
}

@end
