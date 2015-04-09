//
//  APIConnector.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol apiConnectorProtocol<NSObject>
-(void) handleConnectionSuccess:(NSDictionary *)recievedDict;
-(void) handleConnectionFailure:(NSDictionary *)recievedDict;
@end

@interface APIConnector : NSObject

@property (nonatomic,weak) id <apiConnectorProtocol>delegate;

- (void)fetchJSON:(NSDictionary *)postData :(NSString *)urlAsString :(NSString *)command;

@end
