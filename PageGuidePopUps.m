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
#import "ProfileDateUtils.h"
#import "AppDelegate.h"
@implementation PageGuidePopUps

@synthesize timer;
@synthesize dicVisitedPage;
@synthesize arrVisitedPages;
@synthesize grphicsArray;
@synthesize rateView;

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
    [bodyDetails setValue:DEVICE_UUID      forKey:@"device_uid"];
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
    
    
    for(int index = 0; index < [pageGuidesArray count]; index++)
    {

        grphicsArray = [[NSMutableArray alloc]init];
        grphicsArray = [[pageGuidesArray objectAtIndex:index] valueForKey:@"graphics"];
        for(int i=0;i<[grphicsArray count];i++)
        {
            NSMutableDictionary *objectDict=[[NSMutableDictionary alloc] initWithDictionary:[grphicsArray objectAtIndex:i]];
            
            // add a bool
            
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
        }
        
        
    }
    [[NSUserDefaults standardUserDefaults] setObject:pageGuidesArray forKey:@"PageGuidePopUpImages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PageGuidsDownloaded" object:nil userInfo:nil];

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
    
    NSMutableArray *visited_reminders = [[NSUserDefaults standardUserDefaults] objectForKey:@"time_reminder_visits"];
   
    DebugLog(@"visited_reminders %@",visited_reminders);
    
    if(visited_reminders.count >0)
    {
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    
    NSString *command = @"time_reminder_visits";
    
    NSMutableDictionary *bodyDetails  = [NSMutableDictionary dictionary];
    [bodyDetails setValue:DEVICE_UUID      forKey:@"device_uid"];
    [bodyDetails setValue:visited_reminders      forKey:@"visited_reminders"];
    
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": command,
                               @"body": bodyDetails};
    
    DebugLog(@"%@",postData);
    NSDictionary *userInfo = @{@"command": @"visited_page_guides"};
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}
    
}
-(void)didReceiveVisitedPageGuidesSuccessful:(NSMutableArray *)recievedArray
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"time_reminder_visits"];
    //[self getPageGuidePopUpData];
    DebugLog(@"recievded dict %@",recievedArray);
}
-(void)visitedPageGuidesFailed
{
    DebugLog(@"recievded dict failed");
}

- (NSString*) deviceName
{
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
    
    static NSDictionary* deviceNamesByCode = nil;
    
    if (!deviceNamesByCode) {
        
        deviceNamesByCode = @{@"i386"      :@"iphone 4",
                              @"x86_64"    :@"iphone 5",
                              @"iPod1,1"   :@"iphone 4",      // (Original)
                              @"iPod2,1"   :@"iphone 4",      // (Second Generation)
                              @"iPod3,1"   :@"iphone 4",      // (Third Generation)
                              @"iPod4,1"   :@"iphone 4",      // (Fourth Generation)
                              @"iPhone1,1" :@"iphone 4",          // (Original)
                              @"iPhone1,2" :@"iphone 4",          // (3G)
                              @"iPhone2,1" :@"iphone 4",          // (3GS)
                              @"iPad1,1"   :@"iphone 4",            // (Original)
                              @"iPad2,1"   :@"iphone 4",          //
                              @"iPad3,1"   :@"iphone 4",            // (3rd Generation)
                              @"iPhone3,1" :@"iphone 4",        // (GSM)
                              @"iPhone3,3" :@"iphone 4",        // (CDMA/Verizon/Sprint)
                              @"iPhone4,1" :@"iphone 4",       //
                              @"iPhone5,1" :@"iphone 5",        // (model A1428, AT&T/Canada)
                              @"iPhone5,2" :@"iphone 5",        // (model A1429, everything else)
                              @"iPad3,4"   :@"iphone 4",            // (4th Generation)
                              @"iPad2,5"   :@"iphone 4",       // (Original)
                              @"iPhone5,3" :@"iphone 5",       // (model A1456, A1532 | GSM)
                              @"iPhone5,4" :@"iphone 5",       // (model A1507, A1516, A1526 (China), A1529 | Global)
                              @"iPhone6,1" :@"iphone 5",       // (model A1433, A1533 | GSM)
                              @"iPhone6,2" :@"iphone 5",       // (model A1457, A1518, A1528 (China), A1530 | Global)
                              @"iPhone7,1" :@"iphone 6plus",   //
                              @"iPhone7,2" :@"iphone 6",        //
                              @"iPad4,1"   :@"iphone 4",        // 5th Generation iPad (iPad Air) - Wifi
                              @"iPad4,2"   :@"iphone 4",        // 5th Generation iPad (iPad Air) - Cellular
                              @"iPad4,4"   :@"iphone 4",       // (2nd Generation iPad Mini - Wifi)
                              @"iPad4,5"   :@"iphone 4"        // (2nd Generation iPad Mini - Cellular)
                              };
    }
    
    NSString* deviceName = [deviceNamesByCode objectForKey:code];
    
    if (!deviceName) {
            deviceName = @"iphone 4";
    }
    
    return deviceName;
}

#pragma mark -
#pragma mark Call to Disable External Sign in
-(void)getAppConfig
{
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    NSString *command = @"appConfig";
    NSDictionary* postData;
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogedIn"])
    {
        
        postData = @{@"access_token": token.access_token,
                     @"command": command,
                     @"body":@{@"ref": sharedModel.userProfile.uid}
                     };


    }
    else
    {
        postData = @{@"access_token": token.access_token,
                     @"command": command,
                     @"body":@{@"ref": DEVICE_UUID}
                     };
    }
    NSDictionary *userInfo = @{@"command": command};
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}
-(void)externalSigninOptionsSuccessFull:(NSDictionary *)recievedDict
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[recievedDict objectForKey:@"notifications_count"] forKey:@"notificationcount"];
    [defaults setObject:[recievedDict objectForKey:@"ratingInterval"] forKey:@"ratingInterval"];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdateNotificationCount" object:nil];


}
-(void)externalSigninOptionsFailed
{
    
}
#pragma mark -
#pragma mark Call to New session api
-(void)trackNewUserSession
{
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    NSString *command = @"newSession";
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": command};
    NSDictionary *userInfo = @{@"command": command};
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}
-(void)newSessionSuccessFull:(NSDictionary *)recievedDict
{
    
    
}
-(void)newSessionFailed
{
    
}

#pragma mark -
#pragma mark Rate App Methods
-(void)askForRateApp
{
    if(rateView && rateView.view.superview != nil)
    {
        return;
    }
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    
    if(![defaults boolForKey:@"ratedapp"])
    {
        NSDate *installedDate = [defaults objectForKey:@"last_shown_date"];
        NSInteger daysBetween = 0;

        if(installedDate != nil)
        {
            daysBetween = [ProfileDateUtils daysBetweenDate:installedDate andDate:[NSDate date]];
            
            NSDictionary *ratringDict = [defaults objectForKey:@"ratingInterval"];
            
            int intervel = 0;
            if([defaults boolForKey:@"shownOneTime"])
                intervel = [[ratringDict objectForKey:@"later"] intValue];
            else
                intervel = [[ratringDict objectForKey:@"first"] intValue];

            if(daysBetween >= intervel)
            {
                [defaults setObject:[NSDate date] forKey:@"last_shown_date"];
                
                [defaults setBool:YES forKey:@"shownOneTime"];

                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                         bundle: nil];
                rateView = (RateTheAppViewController *)[mainStoryboard
                                                     instantiateViewControllerWithIdentifier: @"RateTheAppViewController"];
                rateView.delegate = self;
                AppDelegate *appdele = [[UIApplication sharedApplication] delegate];
                [appdele.window addSubview:rateView.view];

            }

        }
        else
        {
            [defaults setObject:[NSDate date] forKey:@"last_shown_date"];
            [defaults synchronize];

        }
    }
}
-(void)responseFromPrompt:(int)index
{
    if(index == 2)
    {
        
        NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"ratedapp"];
        
        NSString *iTunesLink = @"itms-apps://itunes.apple.com/us/app/id998823966?mt=8";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];

    }
    AppDelegate *appdele = [[UIApplication sharedApplication] delegate];

    if(appdele.deferNotificationPrompt)
    {
        [appdele askForNotificationPermission];
    }
}


@end
