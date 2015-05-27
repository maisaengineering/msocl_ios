//
//  LoadingViewController.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Webservices.h"
@class AppDelegate;
@interface LoadingViewController : UIViewController<webServiceProtocol>
{

    AppDelegate *appdelegate;
    Webservices *webServices;
    UIImageView *iconImage;
}

@end
