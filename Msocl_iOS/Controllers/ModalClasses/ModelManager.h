//
//  ModelManager.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccessToken.h"
#import "UserProfile.h"
@interface ModelManager : NSObject

@property (nonatomic, strong) AccessToken *accessToken;
@property (nonatomic, strong) UserProfile *userProfile;

+ (id)sharedModel;
- (void) clear;
-(void)setUserDetails:(NSDictionary *)detailsDict;
@end
