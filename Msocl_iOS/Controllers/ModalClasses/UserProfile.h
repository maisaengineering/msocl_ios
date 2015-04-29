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
    NSString *uid;
    NSString *fname;
    NSString *lname;
    NSString *email;
    NSArray  *phone_numbers;
    NSString *post_code;
    NSString *image;
    
}

@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *fname;
@property (strong, nonatomic) NSString *lname;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *post_code;
@property (strong, nonatomic) NSString *blog;

@property (strong, nonatomic) NSString *image;
@end
