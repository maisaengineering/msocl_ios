//
//  PostDetails.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/9/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostDetails : NSObject

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *uid;
@property (nonatomic,strong) NSString *time;
@property (nonatomic,strong) NSString *content;
@property (nonatomic, strong) NSString * profileImage;
@property (nonatomic,strong) NSMutableDictionary *images;
@property (nonatomic,strong) NSMutableDictionary *owner;
@property (nonatomic,strong) NSMutableArray *commenters;
@property (nonatomic,strong) NSMutableArray *tags;
@property (nonatomic,strong) NSMutableArray *comments;
@property (nonatomic, assign) BOOL anonymous;

- (id)initWithDictionary:(NSDictionary*)response;

@end
