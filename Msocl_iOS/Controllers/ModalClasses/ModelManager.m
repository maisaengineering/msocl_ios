//
//  ModelManager.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "ModelManager.h"

@implementation ModelManager

@synthesize accessToken;
@synthesize userProfile;
+ (id)sharedModel
{
    static ModelManager *sharedAppModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAppModel = [[self alloc] init];
    });
    return sharedAppModel;
}

- (id)init {
    
    if (self = [super init])
    {
        [self clear];
    }
    return self;
}

- (void) clear
{
    accessToken         = NULL;
    
    userProfile = NULL;
}
-(void)setUserDetails:(NSDictionary *)detailsDict
{
    userProfile = [[UserProfile alloc] init];
   
        for (NSString *key in detailsDict.allKeys) {
                if ([key isEqualToString:@"uid"]) {
                    userProfile.uid=[detailsDict objectForKey:key];
                }
                else if ([key isEqualToString:@"fname"]) {
                    userProfile.fname=[detailsDict objectForKey:key];
                }
                else if ([key isEqualToString:@"lname"]) {
                    userProfile.lname = [detailsDict objectForKey:key];
                }
                else if ([key isEqualToString:@"photo"]) {
                    userProfile.image = [detailsDict objectForKey:key];
                }
                
            }
}


@end
