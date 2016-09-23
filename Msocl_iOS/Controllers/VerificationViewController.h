//
//  VerificationViewController.h
//  Msocl_iOS
//
//  Created by Maisa Pride on 9/1/16.
//  Copyright © 2016 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Webservices.h"
@interface VerificationViewController : UIViewController<webServiceProtocol,UITextFieldDelegate>

@property (nonatomic, assign) BOOL addPostFromNotifications;
@property (nonatomic, assign) BOOL isFromStreamPage;
@property (nonatomic, assign) BOOL isFromSignUp;
@property (nonatomic, strong) IBOutlet UITextField *textField1;
@property (nonatomic, strong) IBOutlet UITextField *textField2;
@property (nonatomic, strong) IBOutlet UITextField *textField3;
@property (nonatomic, strong) IBOutlet UITextField *textField4;

@property (nonatomic, strong) IBOutlet UILabel *counterLabel;
@property (nonatomic, strong) IBOutlet UIButton *resendButton;

-(IBAction)resend:(id)sender;
-(IBAction)verify:(id)sender;
-(IBAction)textFieldDidChange:(UITextField *)textField;




@end
