//
//  LoginViewController.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/7/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Webservices.h"
@interface LoginViewController : UIViewController<UITextFieldDelegate,webServiceProtocol>

@property (nonatomic, strong) IBOutlet UITextField *txt_username;
@property (nonatomic, strong) IBOutlet UITextField *txt_password;

-(IBAction)loginClicked:(id)sender;
-(IBAction)forgotPasswordClicked:(id)sender;

@end
