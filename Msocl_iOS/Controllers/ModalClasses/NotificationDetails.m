//
//  NotificationDetails.m
//  Msocl_iOS
//
//  Created by Maisa Pride on 5/13/16.
//  Copyright © 2016 Maisa Solutions. All rights reserved.
//

#import "NotificationDetails.h"

@implementation NotificationDetails

@synthesize  viewed;
@synthesize uid;
@synthesize url;
@synthesize source;
@synthesize message;
@synthesize sourceId;

-(id)initWithDictionary:(NSDictionary *)response{
    
    if (self=[super init]) {
        for (NSString *key in response.allKeys) {
            if ([key isEqualToString:@"uid"]) {
                self.uid=[response objectForKey:key];
            }
            else if ([key isEqualToString:@"sourceId"]) {
                self.sourceId=[response objectForKey:key];
            }
            else if ([key isEqualToString:@"message"]) {
                self.message = [response objectForKey:key];
            }
            else if ([key isEqualToString:@"source"]) {
                self.source = [response objectForKey:key];
            }
            else if ([key isEqualToString:@"viewed"]) {
                self.viewed = [[response objectForKey:key] boolValue];
            }
            else if ([key isEqualToString:@"url"]) {
                self.url = [response objectForKey:key];
            }
        }
    }
    return self;
}
@end

