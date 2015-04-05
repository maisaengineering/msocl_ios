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

#ifdef DEBUG
#define DebugLog( s, ... ) NSLog( @"<%p %@:%d (%@)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__,  NSStringFromSelector(_cmd), [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DebugLog( s, ... )
#endif

////Strings for Api call backs
#define API_SUCCESS_GET_ACCESS_TOKEN @"connectionSuccessGetAccessToken"
#define API_FAILED__GET_ACCESS_TOKEN @"connectionFailedGetAccessToken"
#define API_SUCCESS_GET_PROMPT_IMAGES @"connectionSuccessGetPromptImages"
#define API_FAILED__GET_PROMPT_IMAGES @"connectionFailedGetPromptImages"





#endif
