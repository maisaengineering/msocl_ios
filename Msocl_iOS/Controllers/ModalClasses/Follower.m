//
//  Follower.m
//  Msocl_iOS
//
//  Created by Maisa Pride on 6/6/16.
//  Copyright © 2016 Maisa Solutions. All rights reserved.
//

#import "Follower.h"

@implementation Follower

@synthesize fname;
@synthesize lname;
@synthesize uid;
@synthesize photo;
@synthesize photo_thumb;

-(id)initWithDictionary:(NSDictionary *)response{
    
    if (self=[super init]) {
        for (NSString *key in response.allKeys) {
            if ([key isEqualToString:@"uid"]) {
                self.uid=[response objectForKey:key];
            }
            else if ([key isEqualToString:@"fname"]) {
                self.fname=[response objectForKey:key];
            }
            else if ([key isEqualToString:@"lname"]) {
                self.lname = [response objectForKey:key];
            }
            else if ([key isEqualToString:@"photo"]) {
                self.photo = [response objectForKey:key];
            }
            else if ([key isEqualToString:@"photo_thumb"]) {
                self.photo_thumb = [response objectForKey:key];
            }
        }
    }
    return self;
}

@end
