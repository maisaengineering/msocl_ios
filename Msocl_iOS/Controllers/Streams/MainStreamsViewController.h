//
//  MainStreamsViewController.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StreamDisplayView.h"
#import "SlideNavigationController.h"
#import "PageGuidePopUps.h"
#import "PostDetailDescriptionViewController.h"
#import "ProfilePhotoUtils.h"
#import "Webservices.h"

@interface MainStreamsViewController : UIViewController<StreamDisplayViewDelegate,SlideNavigationControllerDelegate,PostDetailsProtocol,webServiceProtocol>
{
    PageGuidePopUps *pageGuidePopUpsObj;
    UIView *addPopUpView;
    ProfilePhotoUtils *photoUtils;
}
@property (nonatomic, strong) IBOutlet UIButton *mostRecentButton;
@property (nonatomic, strong) NSTimer *timerHomepage;
@property (nonatomic, strong) NSMutableDictionary *subContext;
@property (nonatomic, strong) NSMutableDictionary *homeContext;
@property (nonatomic, strong) NSTimer *timer;

-(void)setUpTimer;
-(IBAction)addClicked:(id)sender;
-(IBAction)RecentOrFollowignClicked:(id)sender;
@end
