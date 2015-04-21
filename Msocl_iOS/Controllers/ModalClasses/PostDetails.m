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
@synthesize owner;
@synthesize upVoteCount;
@synthesize comments;
@synthesize upvoted;

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
            else if ([key isEqualToString:@"comments"]) {
                self.comments = [response objectForKey:key];
            }
            else if ([key isEqualToString:@"owner"]) {
                self.owner = [response objectForKey:key];
            }
            else if ([key isEqualToString:@"anonymous"]) {
                self.anonymous = [[response objectForKey:key] boolValue];
            }
            else if ([key isEqualToString:@"upvote_count"]) {
                self.upVoteCount = [[response objectForKey:key] intValue];
            }
            else if ([key isEqualToString:@"editable"]) {
                self.editable = [[response objectForKey:key] intValue];
            }
            else if ([key isEqualToString:@"createdAt"]) {
                self.time = [response objectForKey:key];
            }
            else if ([key isEqualToString:@"upvoted"]) {
                self.upvoted = [[response objectForKey:key] intValue];
            }
        }
    }
    return self;
}

@end
