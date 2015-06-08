//
//  EmailViewController.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 6/8/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Webservices.h"
@interface EmailViewController : UIViewController<webServiceProtocol>

@property (nonatomic, strong) IBOutlet UISwitch *switchCntrl;
@property (nonatomic, strong) NSDictionary *notifiResoonseDict;
@end
