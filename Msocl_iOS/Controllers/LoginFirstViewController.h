//
//  LoginFirstViewController.h
//  Msocl_iOS
//
//  Created by Maisa Pride on 9/1/16.
//  Copyright © 2016 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Webservices.h"
@class NewLoginViewController;

@interface LoginFirstViewController : UIViewController<webServiceProtocol>

@property (nonatomic, strong) IBOutlet UITextField *txt_username;
@property (nonatomic, strong) IBOutlet UIButton *btn_next;


-(IBAction)nextClicked:(id)sender;
@end
