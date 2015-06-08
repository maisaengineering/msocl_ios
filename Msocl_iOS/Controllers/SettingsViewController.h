//
//  SettingsViewController.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/22/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Webservices.h"
@interface SettingsViewController : UIViewController<webServiceProtocol>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIButton *changePasswordBtn;
-(IBAction)profileClicked:(id)sender;
-(IBAction)PushNotifiClicked:(id)sender;
-(IBAction)emailNotifiClicked:(id)sender;
@end
