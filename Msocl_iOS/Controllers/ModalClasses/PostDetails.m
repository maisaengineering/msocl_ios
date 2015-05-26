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
@synthesize postImage;
@synthesize time;
@synthesize owner;
@synthesize upVoteCount;
@synthesize comments;
@synthesize upvoted;
@synthesize flagged;
@synthesize commentCount;
@synthesize large_images;
@synthesize can;
@synthesize viewsCount;
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
            else if ([key isEqualToString:@"large_images"]) {
                self.large_images = [response objectForKey:key];
            }
            else if ([key isEqualToString:@"tags"]) {
                self.tags = [response objectForKey:key];
            }
            else if ([key isEqualToString:@"image"]) {
                self.postImage = [response objectForKey:key];
            }
            else if ([key isEqualToString:@"time"]) {
                self.time = [response objectForKey:key];
            }
            else if ([key isEqualToString:@"comments"]) {
                self.comments = [[response objectForKey:key] mutableCopy];
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
            else if ([key isEqualToString:@"can"]) {
                self.can = [[response objectForKey:key] mutableCopy];
            }
            else if ([key isEqualToString:@"createdAt"]) {
                self.time = [response objectForKey:key];
            }
            else if ([key isEqualToString:@"upvoted"]) {
                self.upvoted = [[response objectForKey:key] boolValue];
            }
            else if ([key isEqualToString:@"flagged"]) {
                self.flagged = [[response objectForKey:key] boolValue];
            }
            else if ([key isEqualToString:@"comment_count"]) {
                self.commentCount = [[response objectForKey:key] intValue];
            }
            else if ([key isEqualToString:@"views"]) {
                self.viewsCount = [[response objectForKey:key] intValue];
            }
        }
    }
    return self;
}

@end
