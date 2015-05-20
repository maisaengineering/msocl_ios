//
//  WebViewController.h
//  Msocl_iOS
//
//  Created by Maisa Solutions Pvt Ltd on 11/04/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Webservices.h"
@class AppDelegate;

@interface WebViewController : UIViewController<UIWebViewDelegate, webServiceProtocol>
{
    AppDelegate *appdelegate;
    Webservices *webServices;
}
@property (nonatomic, strong) NSURL *loadUrl;
@property (nonatomic) int tagValue;
@end
