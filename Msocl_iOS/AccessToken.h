//
//  AccessToken.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccessToken : NSObject
{
    NSString* access_token;
    NSString* token_type;
    NSString* expires_in;
    NSString* scope;
}

@property (strong, nonatomic) NSString *access_token;
@property (strong, nonatomic) NSString *token_type;
@property (strong, nonatomic) NSString *expires_in;
@property (strong, nonatomic) NSString *scope;

@end
