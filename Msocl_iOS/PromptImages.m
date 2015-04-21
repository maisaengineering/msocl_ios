//
//  PromptImages.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "PromptImages.h"
#import "StringConstants.h"
#import "Webservices.h"
#import "ModelManager.h"

@implementation PromptImages
static PromptImages *romptImagesObject = nil;

+ (id)sharedInstance
{
    /* Use this to make it a singleton class */
    if (romptImagesObject==Nil) {
        romptImagesObject=[[PromptImages alloc]init];
    }
    return romptImagesObject;
    /**/
    
}
-(id)init{
    if (romptImagesObject) {
        return romptImagesObject;
    }
    else{
        if (self=[super init]) {
            //initialize the variables
            webServices = [[Webservices alloc] init];
            webServices.delegate = self;
        }
        return self;
    }
}

#pragma mark -
#pragma mark Prompt Images Api
-(void)getPrompImages
{
    NSDictionary* postData = @{@"command": @"tour"};
    NSDictionary *userInfo = @{@"command": @"GetPromptImages"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}
-(void)didReceivePromptImages:(NSDictionary *)responseDict
{
    
    [[NSUserDefaults standardUserDefaults] setObject:[responseDict objectForKey:@"tour"] forKey:@"PromptImages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self getAllTourImagesFromList:[responseDict objectForKey:@"tour"]];

}
-(void)fetchingPromptImagesFailedWithError
{

}

-(void)getAllTourImagesFromList:(NSArray *)imageUrlsArray
{
    photoUtils = [ProfilePhotoUtils alloc];
    for(NSString *url in imageUrlsArray)
    {
        UIImage *thumb = [photoUtils getImageFromCache:url];
        if (thumb == nil)
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^(void)
                           {
                               NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                               UIImage* image = [[UIImage alloc] initWithData:imageData];
                               if (image) {
                                   [photoUtils saveImageToCache:url :image];
                               }
                           });
        }
    }
}

#pragma mark -
#pragma mark Groups
-(void)getAllGroups
{
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;

    NSDictionary* postData = @{@"command": @"favourites",@"access_token": token.access_token};
    NSDictionary *userInfo = @{@"command": @"GetAllGroups"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@groups",BASE_URL];
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}
-(void)didReceiveGroups:(NSDictionary *)responseDict
{
    [[NSUserDefaults standardUserDefaults] setObject:[responseDict objectForKey:@"groups"] forKey:@"Groups"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
-(void)fetchingGroupsFailedWithError
{
    
}
@end
