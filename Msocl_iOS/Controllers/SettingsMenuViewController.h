//
//  SettingsMenuViewController.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/13/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "AppDelegate.h"
#import "Webservices.h"

@interface SettingsMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,webServiceProtocol>
{
    AppDelegate *appdelegate;
    Webservices *webServices;
}
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL slideOutAnimationEnabled;

@end
