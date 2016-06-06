//
//  APIConnector.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "APIConnector.h"
#import "AFNetworking.h"
#import "StringConstants.h"
#import "PromptImages.h"
@implementation APIConnector
@synthesize delegate;

- (void)fetchJSON:(NSDictionary *)postData :(NSString *)urlAsString :(NSDictionary *)userInfo
{
    NSError* error;
    
   
            //convert object to data
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:postData options:0  error:&error];
        
        //convert data to string
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        DebugLog(@"----Request-URL: %@",urlAsString);
    
        NSURL *url = [[NSURL alloc] initWithString:urlAsString];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        NSData *requestData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody: requestData];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         if([responseObject objectForKey:@"status"] && [[responseObject objectForKey:@"status"] intValue] == 401)
         {
             [[PromptImages sharedInstance] ClearOnAuhorisationError];
         }
         else
         {
             NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:userInfo,@"userInfo",responseObject,@"response", nil];
             [self.delegate handleConnectionSuccess:dict];

         }
        
         
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error, id responseObject)
     {
         if([responseObject objectForKey:@"status"] && [[responseObject objectForKey:@"status"] intValue] == 401)
         {
             [[PromptImages sharedInstance] ClearOnAuhorisationError];
         }
         else
         {
         [self.delegate handleConnectionFailure:[NSDictionary dictionaryWithObjectsAndKeys:[userInfo objectForKey:@"command"],@"command", responseObject,@"response",nil]];
         }
         
     }];
    [operation start];

}

@end
