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

@implementation PageGuidePopUps

@synthesize timer;
@synthesize dicVisitedPage;
@synthesize arrVisitedPages;

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
    NSString *command = @"page_guides";
    
    NSMutableDictionary *bodyDetails  = [NSMutableDictionary dictionary];
    [bodyDetails setValue:DEVICE_UUID      forKey:@"devise_uid"];
    
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
        [[NSUserDefaults standardUserDefaults] setObject:pageGuidesArray forKey:@"PageGuidePopUpImages"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self getAllTimedReminderImagesWithURLS:pageGuidesArray];
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
        NSString *url = [[pageGuidesArray objectAtIndex:index] objectForKey:@"asset"];
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
    
    NSMutableArray *pageGuidesArray = [[NSMutableArray alloc]init];
    [[NSUserDefaults standardUserDefaults] setObject:pageGuidesArray forKey:@"PageGuidePopUpImages"];
    
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    
    NSString *command = @"visited_page_guides";
    
    NSMutableDictionary *bodyDetails  = [NSMutableDictionary dictionary];
    [bodyDetails setValue:DEVICE_UUID      forKey:@"devise_uid"];
    [bodyDetails setValue:arrVisitedPages      forKey:@"guide_uids"];
    
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": command,
                               @"body": bodyDetails};
    NSDictionary *userInfo = @{@"command": command};
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
    
}
-(void)didReceiveVisitedPageGuidesSuccessful:(NSMutableArray *)recievedArray
{
    
}
-(void)visitedPageGuidesFailed
{
    
}
@end