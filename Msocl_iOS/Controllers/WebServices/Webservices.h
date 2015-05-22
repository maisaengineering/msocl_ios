//
//  Webservices.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StringConstants.h"
#import "APIConnector.h"
#import "PostDetails.h"
@protocol webServiceProtocol<NSObject>
@optional
-(void) loginSccessfull:(NSDictionary *)recievedDict;
-(void) loginFailed;
-(void) signUpSccessfull:(NSDictionary *)recievedDict;
-(void) signUpFailed;
-(void) signOutSccessfull:(NSDictionary *)recievedDict;
-(void) signOutFailed;
-(void) didReceivePromptImages:(NSDictionary *)recievedDict;
-(void) fetchingPromptImagesFailedWithError;
-(void) didReceiveGroups:(NSDictionary *)recievedDict;
-(void) fetchingGroupsFailedWithError;
-(void) uploadImageSccess:(NSDictionary *)recievedDict;
-(void) uploadImageFailed;
-(void) profileImageUploadSccess:(NSDictionary *)recievedDict;
-(void) profileImageUploadFailed;
-(void) postCreationSccessfull:(NSDictionary *)recievedDict;
-(void) postCreationFailed;
-(void) didReceiveStreams:(NSDictionary *)recievedDict;
-(void) streamsFailed;
-(void) didReceiveFavPost:(NSDictionary *)recievedDict;
-(void) FavPostFailed;
-(void) didReceiveTokens:(NSArray *)tokens;
-(void) fetchingTokensFailedWithError;
-(void) didReceiveShowPost:(NSDictionary *)recievedDict;
-(void) showPostFailed;
-(void) didReceiveExternalSignIn:(NSDictionary *)recievedDict;
-(void) showExternalSignInFailed;
-(void) commentSuccessful:(NSDictionary *)recievedDict;
-(void) commentFailed;
-(void) didReceivePageGuideImagesSuccessful:(NSMutableArray *)recievedArray;
-(void) pageGuideImagesFailed;
-(void) didReceiveVisitedPageGuidesSuccessful:(NSMutableArray *)recievedArray;
-(void) visitedPageGuidesFailed;
-(void) updatePostSccessfull:(PostDetails *)postDetails;
-(void) updatePostFailed;
-(void) heartingSuccessFull:(NSDictionary *)recievedDict;
-(void) heartingFailed;
-(void) postDeleteSuccessFull:(NSDictionary *)recievedDict;
-(void) postDeleteFailed;
-(void) commentUpVoteSuccessFull:(NSDictionary *)recievedDict;
-(void) commentUpVoteFailed;
-(void) changePasswordSuccessFull:(NSDictionary *)recievedDict;
-(void) changePasswordFailed;
-(void) followingUserSuccessFull:(NSDictionary *)recievedDict;
-(void) followingUserFailed;
-(void) followingGroupSuccessFull:(NSDictionary *)recievedDict;
-(void) followingGroupFailed;
-(void) flagSuccessFull:(NSDictionary *)recievedDict;
-(void) flagFailed;
-(void) flagCommentSuccessFull:(NSDictionary *)recievedDict;
-(void) flagCommentFailed;
-(void) resetPasswordSuccessFull:(NSDictionary *)recievedDict;
-(void) resetPasswordFailed;
-(void) profileDetailsSuccessFull:(NSDictionary *)recievedDict;
-(void) profileDetailsFailed;
-(void) externalSigninOptionsSuccessFull:(NSDictionary *)recievedDict;
-(void) externalSigninOptionsFailed;

@end


@interface Webservices : NSObject<apiConnectorProtocol>
{
    APIConnector *apiConnector;
}
@property (nonatomic,weak) id <webServiceProtocol>delegate;
-(void)callApi:(NSDictionary *)postData :(NSString *)urlAsString;
@end
