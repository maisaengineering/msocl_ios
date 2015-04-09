//
//  PostDetails.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/9/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "PostDetails.h"

@implementation PostDetails

@synthesize commenters;
@synthesize name;
@synthesize content;
@synthesize uid;
@synthesize images;
@synthesize tags;
@synthesize profileImage;
@synthesize time;

-(id)initWithDictionary:(NSDictionary *)response{
    
    if (self=[super init]) {
        for (NSString *key in response.allKeys) {
            if ([key isEqualToString:@"uid"]) {
                self.uid=[response objectForKey:key];
            }
            else if ([key isEqualToString:@"name"]) {
                self.name=[response objectForKey:key];
            }
            else if ([key isEqualToString:@"content"]) {
                self.content = [response objectForKey:key];
            }
            else if ([key isEqualToString:@"commenters"]) {
                self.commenters = [response objectForKey:key];
            }
            else if ([key isEqualToString:@"images"]) {
                self.images = [response objectForKey:key];
            }
            else if ([key isEqualToString:@"tags"]) {
                self.tags = [response objectForKey:key];
            }
            else if ([key isEqualToString:@"profileImage"]) {
                self.profileImage = [response objectForKey:key];
            }
            else if ([key isEqualToString:@"time"]) {
                self.time = [response objectForKey:key];
            }
            
        }
    }
    return self;
}

@end
