//
//  StringConstants.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#ifndef Msocl_iOS_StringConstants_h
#define Msocl_iOS_StringConstants_h

#define APP_VERSION     @"1.2"

// Dev Credentials
#define CLIENT_ID               @"07b71e492ccb9de623cfa8d151157b5452ad52eae7197fe85689a07876960f8f"
#define CLIENT_SECRET           @"2e716b657cd8d0a85ea632a915d0a3c699bd7bc2be326ecec167d26bba159a9b"

//AVIARY
#define kAFAviaryAPIKey         @"e9d5541aa86c51c9"
#define kAFAviarySecret         @"ea86727d549f068d"

//FLURRY
#define FLURRY_KEY              @"NXH4VDMB242THB6Y48CT"

// PARSE
#define PARSE_APPLICATION_KEY   @"7aRj7WVidMmPN5RpMzzUXVbCyG3edtVozRK2kBKu"
#define PARSE_CLIENT_KEY        @"09oD7RgPSdqY7zwkDPNnGeDcq3dQu5T3HCcJSuyg"

//Device Specifcs
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define Deviceheight  [UIScreen mainScreen].bounds.size.height
#define Devicewidth  [UIScreen mainScreen].bounds.size.width

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


#define DEVICE_UUID [[[UIDevice currentDevice] identifierForVendor] UUIDString]

//API URLS
#define kBASE_URL               @"https://samepinch.herokuapp.com/"
#define BASE_URL                @"https://samepinch.herokuapp.com/api/"

#define APP_BASE_URL @"http://www.samepinch.co/"

// OAUTH URL
#define OAUTH_URL                @"https://samepinch.herokuapp.com/users/auth/"
#define OAUTH_URL2                @"https://samepinch.herokuapp.com/users/auth/"

//CONTROLLER TEXT
#define LOADING                 @"Loading..."

#define PROJECT_NAME            @"SamePinch"

#define FACEBOOK_NAME_SPACE       @"miossamepinch"
#define FACEBOOK_CHECK          @"FACEBOOK_CHECK"

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
