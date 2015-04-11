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

-(void)setDetailsFromUserDefaults
{
    [self clear];
    
    NSDictionary *tokenDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"tokens"];
//    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"userprofile"];
//    [self setUserDetails:userDict];
    
    AccessToken *token = [[AccessToken alloc] init];
    for (NSString *key in tokenDict)
    {
        if ([token respondsToSelector:NSSelectorFromString(key)]) {
            
            [token setValue:[tokenDict valueForKey:key] forKey:key];
        }
    }
    self.accessToken = token;
    
}
@end
