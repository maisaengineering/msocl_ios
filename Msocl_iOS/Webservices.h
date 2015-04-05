//
//  Webservices.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StringConstants.h"
#import "APIConnector.h"
@interface Webservices : NSObject<webServicesProtocol>
{
    APIConnector *apiConnector;
}

+(Webservices *)sharedInstance;

-(void)getAccessToken:(NSDictionary *)postData;
-(void)getPromptImages:(NSDictionary *)postData;
@end
