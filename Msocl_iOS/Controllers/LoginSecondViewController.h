//
//  LoginSecondViewController.h
//  Msocl_iOS
//
//  Created by Maisa Pride on 9/1/16.
//  Copyright © 2016 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Webservices.h"
#import <CoreLocation/CoreLocation.h>

@interface LoginSecondViewController : UIViewController<webServiceProtocol,CLLocationManagerDelegate>

@property (nonatomic, strong) IBOutlet UITextField *txt_username;
@property (nonatomic, strong) IBOutlet UITextField *txt_password;

@property (nonatomic, strong) IBOutlet UIButton *loginBtn;

@property (nonatomic, assign) BOOL addPostFromNotifications;
@property (nonatomic, assign) BOOL isSignUp;
@property (nonatomic, strong) NSString *userName;

-(IBAction)loginClicked:(id)sender;

@end
