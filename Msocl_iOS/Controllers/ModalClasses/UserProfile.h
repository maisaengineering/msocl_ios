//
//  UserProfile.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/6/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserProfile : NSObject
{
    NSString *auth_token;
    NSString *uid;
    NSString *fname;
    NSString *mname;
    NSString *lname;
    NSString *email;
    NSArray  *phone_numbers;

    BOOL     onboarding;
    NSString *country_code;
    
}

@property (strong, nonatomic) NSString *auth_token;
@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *fname;
@property (strong, nonatomic) NSString *mname;
@property (strong, nonatomic) NSString *lname;
@property (strong, nonatomic) NSString *email;
@property (nonatomic)         BOOL      onboarding;
@property (strong, nonatomic) NSString *country_code;
@property (nonatomic, assign) BOOL isKidsLinkPersonality;
@end
