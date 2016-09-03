//
//  NewLoginViewController.h
//  Msocl_iOS
//
//  Created by Maisa Pride on 9/1/16.
//  Copyright © 2016 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Webservices.h"
#import <AVFoundation/AVFoundation.h>

@interface NewLoginViewController : UIViewController<webServiceProtocol>

@property (nonatomic, assign) BOOL addPostFromNotifications;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) IBOutlet UIImageView *bgImageView;
@property (nonatomic, strong) IBOutlet UIButton *backButton;

@property (nonatomic, assign) BOOL isFromEmailPrompt;
@property (nonatomic, assign) BOOL isFromPhonePrompt;



-(IBAction)closeClicked:(id)sender;
-(IBAction)backClicked:(id)sender;
@end
