//
//  FacebookShareController.h
//  KidsLink
//
//  Created by Dale McIntyre on 8/20/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@protocol FacebookPostedConfirmationDelegate <NSObject>

- (void)showFacebookSuccessPopup;

@end

@interface FacebookShareController : NSObject<FBLoginViewDelegate>

@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (strong, nonatomic) IBOutlet FBLoginView *fbLoginView;
@property (strong, nonatomic) NSString *objectID;

@property (nonatomic, assign) id<FacebookPostedConfirmationDelegate> postedConfirmationDelegate;

// To avoid the memory leaks declare a global alert
@property (nonatomic, strong) UIAlertView *globalAlert;

//-(void) PostToFacebook: (NSString *)imageURL : (NSString *)title : (NSString *)description : (NSString *)postType;

-(void)PostToFacebookViaAPI:(NSString *)imageURL : (NSString *)title : (NSString *)description : (NSString *)postType;
-(void)checkFacebookPermissions;

@end
