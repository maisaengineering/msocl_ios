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

@interface MainStreamsViewController : UIViewController<StreamDisplayViewDelegate,SlideNavigationControllerDelegate>

-(IBAction)addClicked:(id)sender;
@end
