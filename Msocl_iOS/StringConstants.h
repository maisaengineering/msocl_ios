//
//  StringConstants.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#ifndef Msocl_iOS_StringConstants_h
#define Msocl_iOS_StringConstants_h

//APP VERSION
#define APP_VERSION     @"1.3.0"

// Dev Credentials
#define CLIENT_ID        @"f3fd3bf7df0689b995ae1375284e1d5040a5944575e890f80887010be6142011"
#define CLIENT_SECRET    @"0aa3b89bf8fb4a9e052c34f0df438c06333f1ba7d0d58b59eaa3eaaa3a0c61d3"

//AVIARY
#define kAFAviaryAPIKey         @"e9d5541aa86c51c9"
#define kAFAviarySecret         @"ea86727d549f068d"


//Device Specifcs
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define Deviceheight  [UIScreen mainScreen].bounds.size.height
#define Devicewidth  [UIScreen mainScreen].bounds.size.width


//API URLS
#define kBASE_URL        @"https://kl-json.herokuapp.com"
#define BASE_URL         @"https://kl-json.herokuapp.com/api/"
#define kBaseURL         @"https://kl-json.herokuapp.com/api"

//CONTROLLER TEXT
#define LOADING                 @"Loading..."

#define PROJECT_NAME     @"Socl"

#ifdef DEBUG
#define DebugLog( s, ... ) NSLog( @"<%p %@:%d (%@)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__,  NSStringFromSelector(_cmd), [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DebugLog( s, ... )
#endif

#define ShowAlert(title,msg,cancelButtonName) UIAlertView *alert =[[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:cancelButtonName otherButtonTitles:nil];\
[alert show];

//VALIDATION MESSAGES AND MISC MESSAGES
#define NO_INTERNET_CONNECTION  @"No internet connection. Try again after connecting to internet"
#define FAILED_LOGIN            @"Username and Password didn't match."
#define PASSWORD_LENGTH_INVALID @"Password must be at least 6 characters."
#define EMAIL_INVALID           @"Please provide a valid email address."
#define EMAIL_PASS_REQUIRED     @"Please enter your email and password."
#define ALL_FIELDS_REQUIRED     @"All fields are required"
#define POST_CREATION_FAILED    @"Post creation failed"

////Strings for Api call backs
#define API_SUCCESS_GET_ACCESS_TOKEN @"connectionSuccessGetAccessToken"
#define API_FAILED__GET_ACCESS_TOKEN @"connectionFailedGetAccessToken"
#define API_SUCCESS_GET_PROMPT_IMAGES @"connectionSuccessGetPromptImages"
#define API_FAILED__GET_PROMPT_IMAGES @"connectionFailedGetPromptImages"
#define API_SUCCESS_UPLOAD_POST_IMAGES @"connectionSuccessUploadPostImages"
#define API_FAILED_UPLOAD_POST_IMAGES @"connectionFailedUploadPostImages"
#define API_SUCCESS_CREATE_POST @"connectionSuccessCreatePost"
#define API_FAILED_CREATE_POST @"connectionFailedCreatePost"
#define API_SUCCESS_LOGIN @"connectionSuccessLogin"
#define API_FAILED_LOGIN @"connectionFailedLogin"
#define API_SUCCESS_SIGN_UP @"connectionSuccessSignUp"
#define API_FAILED_SIGN_UP @"connectionFailedSignUp"



#endif
