//
//  ChangePasswordViewController.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/22/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Webservices.h"

@interface ChangePasswordViewController : UIViewController<webServiceProtocol>

@property (nonatomic, strong) IBOutlet UITextField *txt_oldPassword;
@property (nonatomic, strong) IBOutlet UITextField *txt_Password;
@property (nonatomic, strong) IBOutlet UITextField *txt_confirmPassword;
-(void)resetClicked;
@end
