//
//  Follower.h
//  Msocl_iOS
//
//  Created by Maisa Pride on 6/6/16.
//  Copyright © 2016 Maisa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Follower : NSObject

@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *fname;
@property (strong, nonatomic) NSString *lname;
@property (strong, nonatomic) NSString *photo;
@property (strong, nonatomic) NSString *photo_thumb;

- (id)initWithDictionary:(NSDictionary*)response;

@end
