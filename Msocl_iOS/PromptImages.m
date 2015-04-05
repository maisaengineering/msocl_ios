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

@implementation PromptImages

+ (id)sharedInstance
{
    static PromptImages *romptImagesObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        romptImagesObject = [[self alloc] init];
    });
    return romptImagesObject;
    
}

#pragma mark -
#pragma mark Prompt Images Api
-(void)getPrompImages
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceivePromptImages:) name:API_SUCCESS_GET_PROMPT_IMAGES object:Nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fetchingPromptImagesFailedWithError) name:API_FAILED__GET_PROMPT_IMAGES object:Nil];
    NSDictionary* postData = @{@"command": @"categorized_images",@"body":@""};
    [[Webservices sharedInstance] getPromptImages:postData];
}
-(void)didReceivePromptImages:(NSNotification *)notificationObject
{
   NSDictionary *responseDict =  notificationObject.object;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:API_SUCCESS_GET_PROMPT_IMAGES object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:API_FAILED__GET_PROMPT_IMAGES object:nil];

    
    [[NSUserDefaults standardUserDefaults] setObject:responseDict forKey:@"PromptImages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // downtime
    [[NSUserDefaults standardUserDefaults] setObject:[responseDict objectForKey:@"downtime"] forKey:@"bottomtime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //New Kid have the EMPTY STREAMS asset (Pumpkin)
    NSString *stringAssetsBaseURL = @"";
    NSString *kidEmptyStremsPopUp = @"";
    if([responseDict objectForKey:@"asset_base_url"] != (id)[NSNull null] && [[responseDict objectForKey:@"asset_base_url"] length] >0)
    {
        stringAssetsBaseURL = [NSString stringWithFormat:@"%@",[responseDict objectForKey:@"asset_base_url"]];
    }
    if([responseDict objectForKey:@"season_popup"] != (id)[NSNull null] && [[responseDict objectForKey:@"season_popup"] length] >0)
    {
        kidEmptyStremsPopUp = [NSString stringWithFormat:@"%@%@",stringAssetsBaseURL,[responseDict objectForKey:@"season_popup"]];
    }
    DebugLog(@"%@",kidEmptyStremsPopUp);
    [[NSUserDefaults standardUserDefaults] setObject:kidEmptyStremsPopUp forKey:@"NewKidStreamsEmptyPopup"];
    
    //show_friends_graphic with 0 or 1 friends
    
    NSString *show_friends_graphic = @"";
    if([responseDict objectForKey:@"friends_prompt"] != (id)[NSNull null] && [[responseDict objectForKey:@"friends_prompt"] length] >0)
    {
        
        show_friends_graphic = [NSString stringWithFormat:@"%@%@",stringAssetsBaseURL,[responseDict objectForKey:@"friends_prompt"]];
        [[NSUserDefaults standardUserDefaults] setObject:show_friends_graphic forKey:@"show_friends_graphic"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        photoUtils = [ProfilePhotoUtils alloc];
        
        UIImage *thumb = [photoUtils getImageFromCache:show_friends_graphic];
        if (thumb == nil)
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^(void)
                           {
                               NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:show_friends_graphic]];
                               UIImage* image = [[UIImage alloc] initWithData:imageData];
                               if (image) {
                                   [photoUtils saveImageToCache:show_friends_graphic :image];
                               }
                           });
        }
    }
    
    NSArray *priority = [responseDict objectForKey:@"priority"];
    for(NSString *key in priority)
    {
        if([key isEqualToString:@"welcome_tour"])
            [self getAllTourImagesFromList:[[responseDict objectForKey:@"welcome_tour"] objectForKey:@"assets"]];
        
    }
}
-(void)fetchingPromptImagesFailedWithError
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:API_SUCCESS_GET_PROMPT_IMAGES object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:API_FAILED__GET_PROMPT_IMAGES object:nil];

}

-(void)getAllTourImagesFromList:(NSArray *)imageUrlsArray
{
    photoUtils = [ProfilePhotoUtils alloc];
    NSString *baseUrl = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PromptImages"] objectForKey:@"asset_base_url"];
    for(NSDictionary *dict in imageUrlsArray)
    {
        NSString *url = [NSString stringWithFormat:@"%@%@",baseUrl,[dict objectForKey:@"url"]];
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
@end
