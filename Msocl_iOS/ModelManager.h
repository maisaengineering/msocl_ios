//
//  ModelManager.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccessToken.h"

@interface ModelManager : NSObject

@property (nonatomic, retain) AccessToken *accessToken;

+ (id)sharedModel;
- (void) clear;

@end
