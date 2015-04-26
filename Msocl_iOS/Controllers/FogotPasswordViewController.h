//
//  FogotPasswordViewController.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/26/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Webservices.h"
@interface FogotPasswordViewController : UIViewController<UITextFieldDelegate,webServiceProtocol>

@property (nonatomic, strong) IBOutlet UITextField *emialField;
@end
