//
//  VerificationViewController.m
//  Msocl_iOS
//
//  Created by Maisa Pride on 9/1/16.
//  Copyright © 2016 Maisa Solutions. All rights reserved.
//

#import "VerificationViewController.h"
#import "StringConstants.h"
#import "ModelManager.h"
#import "AppDelegate.h"
#import "PromptImages.h"
#import "NotificationUtils.h"
#import "SlideNavigationController.h"
#import "AddPostViewController.h"

@interface VerificationViewController ()

{
    ModelManager *sharedModel;
    Webservices *webServices;
    AppDelegate *appDelegate;
}
@end

@implementation VerificationViewController
@synthesize textField1;
@synthesize textField2;
@synthesize textField3;
@synthesize textField4;
@synthesize counterLabel;
- (void)viewDidLoad {
    
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    sharedModel   = [ModelManager sharedModel];
    appDelegate = [[UIApplication sharedApplication] delegate];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [textField1.layer setBorderColor:[UIColor whiteColor].CGColor];
    [textField1.layer setBorderWidth:2];
    [textField1.layer setCornerRadius:3];

    [textField2.layer setBorderColor:[UIColor whiteColor].CGColor];
    [textField2.layer setBorderWidth:2];
    [textField2.layer setCornerRadius:3];
    
    [textField3.layer setBorderColor:[UIColor whiteColor].CGColor];
    [textField3.layer setBorderWidth:2];
    [textField3.layer setCornerRadius:3];
    
    [textField4.layer setBorderColor:[UIColor whiteColor].CGColor];
    [textField4.layer setBorderWidth:2];
    [textField4.layer setCornerRadius:3];
    
    [self.navigationController setNavigationBarHidden:YES];

    [textField1 becomeFirstResponder];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)hideKeyBoard
{
    [textField1 resignFirstResponder];
    [textField2 resignFirstResponder];
    [textField3 resignFirstResponder];
    [textField4 resignFirstResponder];
}
-(IBAction)resend:(id)sender
{
    AccessToken* token = sharedModel.accessToken;
    
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": @"resendCode"};
    NSDictionary *userInfo = @{@"command": @"resendCode"};
    NSString *urlAsString = [NSString stringWithFormat:@"%@v2/users",BASE_URL];
    
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];

}
-(IBAction)verify:(id)sender
{
    [appDelegate showOrhideIndicator:YES];

    [self hideKeyBoard];
    
    NSString *verificationCode = [NSString stringWithFormat:@"%@%@%@%@",textField1.text,textField2.text,textField3.text,textField4.text];
    
    
    NSMutableDictionary *postDetails  = [NSMutableDictionary dictionary];
    [postDetails setObject:verificationCode forKey:@"code"];
    
    AccessToken* token = sharedModel.accessToken;
    
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": @"verifyAccount",
                               @"body": postDetails};
    NSDictionary *userInfo = @{@"command": @"verifyAccount"};
    NSString *urlAsString = [NSString stringWithFormat:@"%@v2/users",BASE_URL];
    
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];

    
}

-(void) phoneVerificationSuccessFull:(NSDictionary *)recievedDict
{
     [appDelegate showOrhideIndicator:NO];
    if (self.addPostFromNotifications)
    {
        [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        
        AddPostViewController *addPostViewCntrl = (AddPostViewController*)[mainStoryboard
                                                                           instantiateViewControllerWithIdentifier: @"AddPostViewController"];
        SlideNavigationController *slide = [SlideNavigationController sharedInstance];
        
        NSMutableArray *viewCntrlArray = [[slide viewControllers] mutableCopy];
        [viewCntrlArray removeLastObject];
        [viewCntrlArray addObject:addPostViewCntrl];
        [slide setViewControllers:viewCntrlArray animated:YES];

    }
    else
    {

        [self.navigationController popViewControllerAnimated:NO];
    }

}
-(void) phoneVerificationFailed:(NSDictionary *)recievedDict
{
    [appDelegate showOrhideIndicator:NO];
    
    if([recievedDict objectForKey:@"message"])
    {
        ShowAlert(@"Error", [recievedDict objectForKey:@"message"], @"OK");
    }
    else
    {
        ShowAlert(@"Error",@"Failed to verify. Please try again", @"OK");
    }

}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    

}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}
-(IBAction)textFieldDidChange:(UITextField *)textField
{
    if(textField.text.length > 0)
    {
        if(textField == textField1)
        {
            [textField2 becomeFirstResponder];
        }
        if(textField == textField2)
        {
            [textField3 becomeFirstResponder];
        }
        if(textField == textField3)
        {
            [textField4 becomeFirstResponder];
        }
    }

}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if( textField.text.length > 0 && string.length > 0)
    {
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
