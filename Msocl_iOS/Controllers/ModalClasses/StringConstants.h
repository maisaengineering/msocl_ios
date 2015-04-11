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
#define APP_VERSION             @"1.3.0"

// Dev Credentials
#define CLIENT_ID               @"3e0786a2f258e6f9b08250dbd7f35010480988e0d3d1ef373b79e07884be79f9"
#define CLIENT_SECRET           @"813c95cc2eb6c0cf4f49d30d0add0c6fc3ea82863d30507beb6733c0e643927c"

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


//API URLS
#define kBASE_URL               @"https://msocl.herokuapp.com"
#define BASE_URL                @"https://msocl.herokuapp.com/api/"

// FACEBOOK URL
#define FACEBOOK_URL                @"https://msocl.herokuapp.com/users/auth/facebook"

//CONTROLLER TEXT
#define LOADING                 @"Loading..."

#define PROJECT_NAME            @"Socl"

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


#endif
