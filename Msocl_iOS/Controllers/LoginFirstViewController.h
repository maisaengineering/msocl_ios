//
//  LoginFirstViewController.h
//  Msocl_iOS
//
//  Created by Maisa Pride on 9/1/16.
//  Copyright © 2016 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Webservices.h"
#import "TPKeyboardAvoidingScrollView.h"
@interface LoginFirstViewController : UIViewController<webServiceProtocol>

@property (nonatomic, strong) IBOutlet UITextField *txt_username;
@property (nonatomic, strong) IBOutlet UIButton *btn_next;
@property (nonatomic, strong) IBOutlet UILabel *topTextLabel;
@property (nonatomic, strong) IBOutlet UIView *backgroundView;
@property (nonatomic, assign) BOOL isSignUp;

@property (nonatomic, assign) BOOL isFromEmailPrompt;
@property (nonatomic, assign) BOOL isFromPhonePrompt;

-(IBAction)nextClicked:(id)sender;
-(IBAction)returnClicked:(id)sender;
@end
