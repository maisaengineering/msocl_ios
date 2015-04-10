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
@protocol webServiceProtocol<NSObject>
@optional
-(void) loginSccessfull:(NSDictionary *)recievedDict;
-(void) loginFailed;
-(void) signUpSccessfull:(NSDictionary *)recievedDict;
-(void) signUpFailed;
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
-(void) didReceiveTokens:(NSArray *)tokens;
-(void) fetchingTokensFailedWithError;
-(void) didReceiveShowPost:(NSDictionary *)recievedDict;
-(void) showPostFailed;
@end


@interface Webservices : NSObject<apiConnectorProtocol>
{
    APIConnector *apiConnector;
}
@property (nonatomic,weak) id <webServiceProtocol>delegate;
-(void)callApi:(NSDictionary *)postData :(NSString *)urlAsString;
@end
