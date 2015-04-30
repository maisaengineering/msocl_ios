//
//  JTSSimpleImageDownloader.m
//
//
//  Created by Jared Sinclair on 3/2/14.
//  Copyright (c) 2014 Nice Boy LLC. All rights reserved.
//

#import "JTSSimpleImageDownloader.h"

#import "JTSAnimatedGIFUtility.h"
#import "AFNetworking.h"
@implementation JTSSimpleImageDownloader

+ (NSURLSessionDataTask *)downloadImageForURL:(NSURL *)imageURL canonicalURL:(NSURL *)canonicalURL completion:(void (^)(UIImage *))completion {
    
    NSURLSessionDataTask *dataTask = nil;
    
    if (imageURL.absoluteString.length) {
        
        
        NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
        AFURLConnectionOperation *operation =   [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Latest_Image"];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
        
        [operation setCompletionBlock:^{
            
            UIImage *image;
            
            image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:filePath]];
            dispatch_async(dispatch_get_main_queue(), ^{
  completion(image);
            });
            
            NSLog(@"downloadComplete!");
            
        }];
        [operation start];
        
        
    }
    
    return dataTask;
}

+ (UIImage *)imageFromData:(NSData *)data forURL:(NSURL *)imageURL canonicalURL:(NSURL *)canonicalURL {
    UIImage *image = nil;
    
    if (data) {
        NSString *referenceURL = (canonicalURL.absoluteString.length) ? canonicalURL.absoluteString : imageURL.absoluteString;
        if ([JTSAnimatedGIFUtility imageURLIsAGIF:referenceURL]) {
            image = [JTSAnimatedGIFUtility animatedImageWithAnimatedGIFData:data];
        }
        if (image == nil) {
            image = [[UIImage alloc] initWithData:data];
        }
    }
    
    return image;
}

@end






