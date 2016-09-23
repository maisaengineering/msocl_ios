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
#import "NewLoginViewController.h"
@interface VerificationViewController ()

{
    ModelManager *sharedModel;
    Webservices *webServices;
    AppDelegate *appDelegate;
    int resendCount;
    NSTimer *timer;
    int currMinute;
    int currSeconds;
}
@end

@implementation VerificationViewController
@synthesize textField1;
@synthesize textField2;
@synthesize textField3;
@synthesize textField4;
@synthesize counterLabel;
@synthesize resendButton;
@synthesize isFromStreamPage;
@synthesize isFromSignUp;
- (void)viewDidLoad {
    
    resendCount = 0;
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    sharedModel   = [ModelManager sharedModel];
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    [textField1.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [textField1.layer setBorderWidth:1];
    [textField1.layer setCornerRadius:1];

    [textField2.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [textField2.layer setBorderWidth:1];
    [textField2.layer setCornerRadius:1];
    
    [textField3.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [textField3.layer setBorderWidth:1];
    [textField3.layer setCornerRadius:1];
    
    [textField4.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [textField4.layer setBorderWidth:1];
    [textField4.layer setCornerRadius:1];
    
    [self.navigationController setNavigationBarHidden:NO];

    [textField1 becomeFirstResponder];
    
    UIImage *background = [UIImage imageNamed:@"icon-close.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(closeClicked) forControlEvents:UIControlEventTouchUpInside]; //adding action
    [button setImage:background forState:UIControlStateNormal];
    button.frame = CGRectMake(0 ,0,26,26);
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButton;

    self.navigationItem.hidesBackButton = YES;
    
    resendButton.hidden = YES;
    counterLabel.hidden = YES;
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self startTimer];

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer invalidate];
}
-(void)startTimer
{
    resendButton.hidden = YES;
    counterLabel.hidden = NO;
    [counterLabel setText:@"2:00"];
    currMinute=2;
    currSeconds=00;
    
    [timer invalidate];
    timer =  nil;
    timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
}
-(void)timerFired
{
    if((currMinute>0 || currSeconds>=0) && currMinute>=0)
    {
        if(currSeconds==0)
        {
            currMinute-=1;
            currSeconds=59;
        }
        else if(currSeconds>0)
        {
            currSeconds-=1;
        }
        if(currMinute>-1)
            [counterLabel setText:[NSString stringWithFormat:@"%d%@%02d",currMinute,@":",currSeconds]];
    }
    else
    {
        if(!isFromSignUp)
        resendButton.hidden = NO;
        [timer invalidate];
        counterLabel.hidden = YES;
    }
}


-(void)hideKeyBoard
{
    [textField1 resignFirstResponder];
    [textField2 resignFirstResponder];
    [textField3 resignFirstResponder];
    [textField4 resignFirstResponder];
}
-(void)closeClicked
{
    SlideNavigationController *slide = [SlideNavigationController sharedInstance];
    
    NSMutableArray *viewCntrlArray = [[slide viewControllers] mutableCopy];
    
    for(int i= 0; i<viewCntrlArray.count;i++)
    {
        UIViewController *tempVC = viewCntrlArray[i];
        if([tempVC isKindOfClass:[NewLoginViewController class]])
        {
            [viewCntrlArray removeObject:tempVC];
        }
    }
    [slide setViewControllers:viewCntrlArray animated:NO];
    [self.navigationController popViewControllerAnimated:NO];

}

-(IBAction)resend:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    /*
    if(resendCount == 3)
    {
        resendButton.enabled = NO;
        return;
    }
    resendCount++;
    AccessToken* token = sharedModel.accessToken;
    
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": @"resendCode"};
    NSDictionary *userInfo = @{@"command": @"resendCode"};
    NSString *urlAsString = [NSString stringWithFormat:@"%@v2/users",BASE_URL];
    
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];

    [self startTimer];
     */
}
-(void) resendVerificationCodeSuccessFull:(NSDictionary *)recievedDict
{
    
}
-(void) resendVerificationCodeFailed:(NSDictionary *)recievedDict
{
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
    
    NSMutableDictionary *userDict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userprofile"] mutableCopy];
    [userDict setObject:[NSNumber numberWithBool:YES] forKey:@"verified"];
    [[NSUserDefaults standardUserDefaults] setObject:userDict forKey:@"userprofile"];
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]
                                  initWithSuiteName:@"group.com.maisasolutions.msocl"];
    [myDefaults setObject:userDict forKey:@"userprofile"];
    [myDefaults synchronize];
    
    [sharedModel setUserDetails:userDict];

    
    if (self.addPostFromNotifications)
    {
        [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        
        AddPostViewController *addPostViewCntrl = (AddPostViewController*)[mainStoryboard
                                                                           instantiateViewControllerWithIdentifier: @"AddPostViewController"];
        SlideNavigationController *slide = [SlideNavigationController sharedInstance];
        
        NSMutableArray *viewCntrlArray = [[slide viewControllers] mutableCopy];
        for(int i= 0; i<viewCntrlArray.count;i++)
        {
            UIViewController *tempVC = viewCntrlArray[i];
            if([tempVC isKindOfClass:[NewLoginViewController class]])
            {
                [viewCntrlArray removeObject:tempVC];
            }
        }
        [viewCntrlArray removeLastObject];
        [viewCntrlArray addObject:addPostViewCntrl];
        [slide setViewControllers:viewCntrlArray animated:YES];
        
        

    }
    else
    {

        SlideNavigationController *slide = [SlideNavigationController sharedInstance];
        
        NSMutableArray *viewCntrlArray = [[slide viewControllers] mutableCopy];
        
        for(int i= 0; i<viewCntrlArray.count;i++)
        {
            UIViewController *tempVC = viewCntrlArray[i];
            if([tempVC isKindOfClass:[NewLoginViewController class]])
            {
                [viewCntrlArray removeObject:tempVC];
            }
        }
        [slide setViewControllers:viewCntrlArray animated:NO];

        
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
    else
    {
        if(textField == textField4)
        {
            [textField3 becomeFirstResponder];
        }
        if(textField == textField3)
        {
            [textField2 becomeFirstResponder];
        }
        if(textField == textField2)
        {
            [textField1 becomeFirstResponder];
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
