//
//  PageGuidePopUps.h
//  Msocl_iOS
//
//  Created by Maisa Solutions Pvt Ltd on 18/04/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Webservices.h"
#import "ProfilePhotoUtils.h"

@interface PageGuidePopUps : NSObject<webServiceProtocol>
{
    Webservices *webServices;
    ProfilePhotoUtils *photoUtils;
    UIView *addPopUpView;
}
@property (strong, nonatomic) NSMutableDictionary *dicVisitedPage;
@property (strong, nonatomic) NSMutableArray *arrVisitedPages;
@property (nonatomic, strong) NSTimer *timer;
@property (strong, nonatomic) NSMutableArray *grphicsArray;

+ (id)sharedInstance;
- (void)getPageGuidePopUpData;
-(void)setUpTimerWithStartIn;
-(void)sendVisitedPageGuides;
- (void)getAllTimedReminderImagesWithURLS:(NSMutableArray *) pageGuidesArray;
@end
