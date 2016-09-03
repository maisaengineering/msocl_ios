//
//  StringConstants.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#ifndef Msocl_iOS_StringConstants_h
#define Msocl_iOS_StringConstants_h

#define APP_VERSION     @"2.0.1"

// Dev Credentials
//#define CLIENT_ID               @"3e0786a2f258e6f9b08250dbd7f35010480988e0d3d1ef373b79e07884be79f9"
//#define CLIENT_SECRET           @"813c95cc2eb6c0cf4f49d30d0add0c6fc3ea82863d30507beb6733c0e643927c"

// Prod Credentials
#define CLIENT_ID               @"52a9fa5f4532ffc37da93a6f99f4b075dcb0932631224c21f297a268a25d6b68"
#define CLIENT_SECRET           @"966a87c43bab9ae27f2d21b240428b2a1b347f3b220462ab8edb22a1449af79c"


//AVIARY
#define kAFAviaryAPIKey         @"e9d5541aa86c51c9"
#define kAFAviarySecret         @"ea86727d549f068d"

//FLURRY
#define FLURRY_KEY       @"XV2DBVXPD5JTJ2NSKGKM"

// PARSE
#define PARSE_APPLICATION_KEY   @"Kk6uWSLLnGCp6xEOPYQq5iGbIz0NiBj5DtH7qdY5"
#define PARSE_CLIENT_KEY        @"vdj0zlO0cmgeZwoKvSZ8EfwVz7OEVZbrgs73OeQy"

//Device Specifcs
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define Deviceheight  [UIScreen mainScreen].bounds.size.height
#define Devicewidth  [UIScreen mainScreen].bounds.size.width

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


#define DEVICE_UUID [[[UIDevice currentDevice] identifierForVendor] UUIDString]

//DEV
/*//API URLS
#define kBASE_URL               @"https://msocl.herokuapp.com/"
#define BASE_URL                @"https://msocl.herokuapp.com/api/"

#define APP_BASE_URL @"http://www.samepinch.co/"

// OAUTH URL
#define OAUTH_URL                @"https://msocl.herokuapp.com/users/auth/"
#define OAUTH_URL2                @"https://msocl.herokuapp.com/users/auth/"
*/
///PROD

#define kBASE_URL               @"https://www.samepinch.co/"
#define BASE_URL                @"https://www.samepinch.co/api/"

#define APP_BASE_URL @"http://www.samepinch.co/"

// OAUTH URL
#define OAUTH_URL                @"https://www.samepinch.co/users/auth/"
#define OAUTH_URL2                @"https://www.samepinch.co/users/auth/"


//CONTROLLER TEXT
#define LOADING                 @"Loading..."

#define PROJECT_NAME            @"SamePinch"

#define FACEBOOK_NAME_SPACE       @"miossamepinch"
#define FACEBOOK_CHECK          @"FACEBOOK_CHECK"
#define FACEBOOK_SCHEME  @"fb1636478616583615"



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
#define RELOAD_ON_LOG_OUT       @"TokenCreatedOnLogOut"
#define DEVICE_TOKEN_KEY        @"Device_token_key"
#endif
