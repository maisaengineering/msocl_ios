//
//  PageGuidePopUps.m
//  Msocl_iOS
//
//  Created by Maisa Solutions Pvt Ltd on 18/04/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "PageGuidePopUps.h"
#import "ModelManager.h"
#import "StringConstants.h"
#import <sys/utsname.h>

@implementation PageGuidePopUps

@synthesize timer;
@synthesize dicVisitedPage;
@synthesize arrVisitedPages;
@synthesize grphicsArray;

static PageGuidePopUps *pageGuidePopUpsObject = nil;
+ (id)sharedInstance
{
    /* Use this to make it a singleton class */
    if (pageGuidePopUpsObject == Nil) {
        pageGuidePopUpsObject = [[PageGuidePopUps alloc]init];
    }
    return pageGuidePopUpsObject;
    /**/
    
}
-(id)init
{
    if (pageGuidePopUpsObject) {
        return pageGuidePopUpsObject;
    }
    else{
        if (self=[super init]) {
            //initialize the variables
            webServices = [[Webservices alloc] init];
            webServices.delegate = self;
            dicVisitedPage = [[NSMutableDictionary alloc]init];
            arrVisitedPages = [[NSMutableArray alloc] init];
        }
        return self;
    }
}
#pragma mark -
#pragma mark PageGuidePopUpData Api
- (void)getPageGuidePopUpData
{
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    NSString *command = @"time_reminders";
    
    NSString *deviceModel = [self deviceName];
    
    NSMutableDictionary *bodyDetails  = [NSMutableDictionary dictionary];
    [bodyDetails setValue:DEVICE_UUID      forKey:@"device_token"];
    [bodyDetails setValue:[[deviceModel componentsSeparatedByString:@" "] firstObject]      forKey:@"mobile_pattern"];
    [bodyDetails setValue:[[deviceModel componentsSeparatedByString:@" "] lastObject]      forKey:@"version"];

    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": command,
                               @"body": bodyDetails};
    NSLog(@"%@",postData);
    NSDictionary *userInfo = @{@"command": command};
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
    
}
-(void)didReceivePageGuideImagesSuccessful:(NSMutableArray *)pageGuidesArray
{
    if (pageGuidesArray != (id)[NSNull null] && [pageGuidesArray count] > 0)
    {
        [self getAllTimedReminderImagesWithURLS:[pageGuidesArray mutableCopy]];
    }
}
-(void)pageGuideImagesFailed
{
    //ShowAlert(@"Error", @"page_guides api Failed", @"OK");
}

- (void)getAllTimedReminderImagesWithURLS:(NSMutableArray *) pageGuidesArray
{
    photoUtils = [ProfilePhotoUtils alloc];
    
    NSMutableArray *updatedTimedReminderArray = [[NSMutableArray alloc]init];
    
    for(int index = 0; index < [pageGuidesArray count]; index++)
    {
        // Context
        NSMutableDictionary *mainContext = [[NSMutableDictionary alloc] init];
        
        //Main context name
        [mainContext setObject:[[pageGuidesArray objectAtIndex:index] objectForKey:@"context"] forKey:@"context"];
        
        //Main context uid
        [mainContext setObject:[[pageGuidesArray objectAtIndex:index] objectForKey:@"uid"] forKey:@"uid"];
        
        grphicsArray = [[NSMutableArray alloc]init];
        NSMutableArray *newGraphicsArray = [[NSMutableArray alloc]init];
        grphicsArray = [[pageGuidesArray objectAtIndex:index] valueForKey:@"graphics"];
        for(int i=0;i<[grphicsArray count];i++)
        {
            NSMutableDictionary *objectDict=[[NSMutableDictionary alloc] initWithDictionary:[grphicsArray objectAtIndex:i]];
            
            // add a bool
            [objectDict setObject:[NSNumber numberWithBool:NO] forKey:@"isViewed"];
            
            NSString *url = [objectDict objectForKey:@"asset"];
            
            UIImage *thumb = [photoUtils getImageFromCache:url];
            if (thumb == nil)
            {
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                dispatch_async(queue, ^(void)
                               {
                                   NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                                   UIImage* image = [[UIImage alloc] initWithData:imageData];
                                   if (image) {
                                       [photoUtils saveImageToCacheWithOutCompression:url :image];
                                   }
                               });
            }
            [newGraphicsArray addObject:objectDict];
        }
        
        //Main context graphics
        [mainContext setObject:newGraphicsArray forKey:@"graphics"];
        [updatedTimedReminderArray addObject:mainContext];
        
        
    }
    [[NSUserDefaults standardUserDefaults] setObject:updatedTimedReminderArray forKey:@"PageGuidePopUpImages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setUpTimerWithStartIn
{
    NSTimeInterval timeInterval = [[dicVisitedPage objectForKey:@"start"] doubleValue];
    
    if (!timer) {
        
        timer = [NSTimer scheduledTimerWithTimeInterval: timeInterval
                                                 target: self
                                               selector: @selector(displayPromptForNewKidWhenStreamDataEmpty)
                                               userInfo: nil
                                                repeats: NO];
    }
    else
    {
        
        [timer invalidate];
        timer = nil;
        timer = [NSTimer scheduledTimerWithTimeInterval: timeInterval
                                                 target: self
                                               selector: @selector(displayPromptForNewKidWhenStreamDataEmpty)
                                               userInfo: nil
                                                repeats: NO];
    }
}


/// Display the pop up
-(void)displayPromptForNewKidWhenStreamDataEmpty
{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    addPopUpView = [[UIView alloc] initWithFrame:CGRectMake(0,0,screenWidth,screenHeight)];
    [addPopUpView setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *myWhiteBack = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,screenWidth,screenHeight)];
    [myWhiteBack setBackgroundColor:[UIColor blackColor]];
    [addPopUpView addSubview:myWhiteBack];
    
    //MARK:POP Up image
    UIImageView *popUpContent = [[UIImageView alloc] init];
    [popUpContent setFrame:CGRectMake(19, screenHeight, 283, 377)];
    
    NSString *imageURL = [dicVisitedPage objectForKey:@"asset"];
    UIImage *thumb;
    if (imageURL.length >0)
    {
        photoUtils = [ProfilePhotoUtils alloc];
        thumb = [photoUtils getImageFromCache:imageURL];
        
        if (thumb == nil)
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^(void)
                           {
                               NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
                               UIImage* image = [[UIImage alloc] initWithData:imageData];
                               if (image) {
                                   [photoUtils saveImageToCache:imageURL :image];
                                   
                               }
                           });
        }
        else
        {
            [popUpContent setImage:thumb];
        }
    }
    else
    {
        //[popUpContent setImage:[UIImage imageNamed:@"New_Child_Stream_Empty.png"]];
    }
    [popUpContent setImage:thumb];
    popUpContent.frame = CGRectMake(50, 50,
                                    thumb.size.width, thumb.size.height);
    
    [addPopUpView addSubview:popUpContent];
    
    // MARK:Got it button
    UIButton *gotItButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [gotItButton setTitle:@"Got it" forState:UIControlStateNormal];
    [gotItButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    if (Deviceheight <568)
    {
        gotItButton.frame = CGRectMake(180,417,100,50);
    }
    else
    {
        gotItButton.frame = CGRectMake(120,440,80,30);
    }
    [gotItButton setBackgroundColor:[UIColor redColor]];
    
    gotItButton.tag = 1;
    [addPopUpView addSubview:gotItButton];
    
    if (thumb)
    {
        [[[[UIApplication sharedApplication] delegate] window] addSubview:addPopUpView];
    }
    
    myWhiteBack.alpha = 0.0f;
    [UIView animateWithDuration:1.0f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         myWhiteBack.alpha = 0.65f;
                         if (Deviceheight <568)
                         {
                             gotItButton.frame = CGRectMake(180,417,100,50);
                             [popUpContent setFrame:CGRectMake(50, 50,
                                                               thumb.size.width, thumb.size.height)];
                         }
                         else
                         {
                             gotItButton.frame = CGRectMake(120,440,80,30);
                             [popUpContent setFrame:CGRectMake(100, Deviceheight-325,
                                                               thumb.size.width, thumb.size.height)];
                         }
                         
                     }
                     completion:nil];
    
}
- (void)buttonClicked:(UIButton *)sender
{
    [addPopUpView removeFromSuperview];
    if (![arrVisitedPages containsObject:dicVisitedPage])
    {
        [arrVisitedPages addObject:[dicVisitedPage objectForKey:@"uid"]];
    }
    
}

-(void)sendVisitedPageGuides
{
    //TODO:FIRST DOUBLE CHECK WITH THE UPENDHAR REGARDING THE COMMAND AND BODY
    //TODO: THEN UNCOMMENT BELOW TO SEND THE VISITED PAGES TO THE SERVER WHEN USER MINIMIZE THE APP.
    
    
    
    NSMutableArray *userDefaulstArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"PageGuidePopUpImages"];
    
    NSMutableArray *visited_reminders = [[NSMutableArray alloc]init];
    
    for (int i = 0; i<[userDefaulstArray count]; i++)
    {
        NSMutableDictionary *userDefaultsMainContextDic = [userDefaulstArray objectAtIndexedSubscript:i];
        NSMutableArray *graphicArray = [userDefaultsMainContextDic objectForKey:@"graphics"];
        NSMutableArray *arr = [[graphicArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isViewed = 1"]] mutableCopy];
        
        if ([arr count]>0)
        {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            
            NSMutableArray *graphic_uids = [[NSMutableArray alloc]init];
            
            for (int i = 0; i<[arr count]; i++)
            {
                NSMutableDictionary *dic1 = [[NSMutableDictionary alloc]init];
                dic1 = [arr objectAtIndex:i];
                [graphic_uids addObject:[dic1 objectForKey:@"uid"]];
            }
            
            // graphic_uids
            [dic setObject:graphic_uids forKey:@"graphic_uids"];
            
            // reminder_uid
            [dic setObject:[userDefaultsMainContextDic objectForKey:@"uid"] forKey:@"reminder_uid"];
            
            [visited_reminders addObject:dic];
        }
        else
        {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            
            NSMutableArray *graphic_uids = [[NSMutableArray alloc]init];
            // graphic_uids
            [dic setObject:graphic_uids forKey:@"graphic_uids"];
            
            // reminder_uid
            [dic setObject:[userDefaultsMainContextDic objectForKey:@"uid"] forKey:@"reminder_uid"];
            
            [visited_reminders addObject:dic];
        }
    }
    
    
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    
    NSString *command = @"time_reminder_visits";
    
    NSMutableDictionary *bodyDetails  = [NSMutableDictionary dictionary];
    [bodyDetails setValue:DEVICE_UUID      forKey:@"device_token"];
    [bodyDetails setValue:visited_reminders      forKey:@"visited_reminders"];
    
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": command,
                               @"body": bodyDetails};
    
    DebugLog(@"%@",postData);
    NSDictionary *userInfo = @{@"command": command};
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
    
    NSMutableArray *pageGuidesArray = [[NSMutableArray alloc]init];
    [[NSUserDefaults standardUserDefaults] setObject:pageGuidesArray forKey:@"PageGuidePopUpImages"];
}
-(void)didReceiveVisitedPageGuidesSuccessful:(NSMutableArray *)recievedArray
{
    
}
-(void)visitedPageGuidesFailed
{
    
}

- (NSString*) deviceName
{
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
    
    static NSDictionary* deviceNamesByCode = nil;
    
    if (!deviceNamesByCode) {
        
        deviceNamesByCode = @{@"i386"      :@"iPhone 4",
                              @"x86_64"    :@"iPhone 4",
                              @"iPod1,1"   :@"iPhone 4",      // (Original)
                              @"iPod2,1"   :@"iPhone 4",      // (Second Generation)
                              @"iPod3,1"   :@"iPhone 4",      // (Third Generation)
                              @"iPod4,1"   :@"iPhone 4",      // (Fourth Generation)
                              @"iPhone1,1" :@"iPhone 4",          // (Original)
                              @"iPhone1,2" :@"iPhone 4",          // (3G)
                              @"iPhone2,1" :@"iPhone 4",          // (3GS)
                              @"iPad1,1"   :@"iPhone 4",            // (Original)
                              @"iPad2,1"   :@"iPhone 4",          //
                              @"iPad3,1"   :@"iPhone 4",            // (3rd Generation)
                              @"iPhone3,1" :@"iPhone 4",        // (GSM)
                              @"iPhone3,3" :@"iPhone 4",        // (CDMA/Verizon/Sprint)
                              @"iPhone4,1" :@"iPhone 4",       //
                              @"iPhone5,1" :@"iPhone 5",        // (model A1428, AT&T/Canada)
                              @"iPhone5,2" :@"iPhone 5",        // (model A1429, everything else)
                              @"iPad3,4"   :@"iPhone 4",            // (4th Generation)
                              @"iPad2,5"   :@"iPhone 4",       // (Original)
                              @"iPhone5,3" :@"iPhone 5",       // (model A1456, A1532 | GSM)
                              @"iPhone5,4" :@"iPhone 5",       // (model A1507, A1516, A1526 (China), A1529 | Global)
                              @"iPhone6,1" :@"iPhone 5",       // (model A1433, A1533 | GSM)
                              @"iPhone6,2" :@"iPhone 5",       // (model A1457, A1518, A1528 (China), A1530 | Global)
                              @"iPhone7,1" :@"iPhone 6plus",   //
                              @"iPhone7,2" :@"iPhone 6",        //
                              @"iPad4,1"   :@"iPhone 4",        // 5th Generation iPad (iPad Air) - Wifi
                              @"iPad4,2"   :@"iPhone 4",        // 5th Generation iPad (iPad Air) - Cellular
                              @"iPad4,4"   :@"iPhone 4",       // (2nd Generation iPad Mini - Wifi)
                              @"iPad4,5"   :@"iPhone 4"        // (2nd Generation iPad Mini - Cellular)
                              };
    }
    
    NSString* deviceName = [deviceNamesByCode objectForKey:code];
    
    if (!deviceName) {
            deviceName = @"iPhone 4";
    }
    
    return deviceName;
}

@end