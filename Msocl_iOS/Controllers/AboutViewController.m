//
//  AboutViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 5/19/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "AboutViewController.h"
#import "WebViewController.h"
#import "StringConstants.h"
#import "AppDelegate.h"
@interface AboutViewController ()
{
    MFMailComposeViewController * mailComposer;
    AppDelegate *appdelegate;
}
@end

@implementation AboutViewController

- (void)viewDidLoad {
    self.title = @"ABOUT";
    
    appdelegate = [[UIApplication sharedApplication] delegate];
    
    UIImage *background = [UIImage imageNamed:@"icon-back.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside]; //adding action
    [button setImage:background forState:UIControlStateNormal];
    button.frame = CGRectMake(0 ,0,13,17);
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)backClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(IBAction)buttonTapped:(id)sender
{
    
    UIStoryboard *sBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebViewController *webViewController = [sBoard instantiateViewControllerWithIdentifier:@"WebViewController"];

    switch ([sender tag])
    {
            ///For image captrure
        case 1:
        {
            UIActionSheet *addImageActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                                  @"Email", @"SMS", nil];
            addImageActionSheet.tag = 1;
            [addImageActionSheet showInView:self.view];

        }
            break;

        case 2:
        {

            webViewController.loadUrl = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@rules",APP_BASE_URL]];
            [self.navigationController pushViewController: webViewController animated:YES];

        }
            break;
        case 3:
        {
            NSString *iTunesLink = @"itms-apps://itunes.apple.com/us/app/id998823966?mt=8";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];

        }
            break;
        case 4:
        {
            webViewController.loadUrl = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@t&c/",APP_BASE_URL]];
            [self.navigationController pushViewController: webViewController animated:YES];

        }
            break;
        case 5:
        {
            webViewController.loadUrl = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@systemstatus",APP_BASE_URL]];
            [self.navigationController pushViewController: webViewController animated:YES];

        }
            break;
        case 6:
        {
            [appdelegate showOrhideIndicator:YES];

            mailComposer= [[MFMailComposeViewController alloc] init];
            [mailComposer setMailComposeDelegate:self];
            [mailComposer setSubject:@"Feedback"];
            mailComposer.navigationBar.barStyle = UIBarStyleBlackOpaque;
            [mailComposer setToRecipients:[NSArray arrayWithObjects: @"friends@samepinch.co",nil]];
            
            //        [self presentModalViewController:mailComposer animated:TRUE];
            [self presentViewController:mailComposer animated:TRUE completion:^{ [appdelegate showOrhideIndicator:NO];
}];
        }
            break;
        default:
            break;
    }
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            
            [self displayMailComposer];
            break;
        case 1:
            [self showSMS];
            
            break;
        default:
            break;
    }
}
#pragma mark -
#pragma mark Mail Composer

-(void)displayMailComposer
{
    if([MFMailComposeViewController canSendMail])
    {
         [appdelegate showOrhideIndicator:YES];
        mailComposer= [[MFMailComposeViewController alloc] init];
        [mailComposer setMailComposeDelegate:self];
        [mailComposer setSubject:@"Heard about SamePinch?"];
        
    /*    ///////Attaching image//////////
        if(selectedImage != nil)
        {
            NSData *imageData;
            imageData = UIImagePNGRepresentation(selectedImage);
            [self.mailComposer  addAttachmentData:imageData mimeType:@"image/png" fileName:@"photo"];
        }
    */
        //////Attaching Description
        
        
        //
              // NSString *styles = @"<style type='text/css'>body { font-family: 'Ubuntu-Light'; font-size: 20px; color: #7b7a7a; margin: 0; padding: 0; }</style>";
      //  NSString *htmlMsg = [NSString stringWithFormat:@"<html><head>%@</head><body>%@</body></html>",styles,@"Hey,\n\nThought you might be interested to check out this app I am in love with: www.samepinch.co\n\nThanks,\nSamePinch Fan"];
        [mailComposer setMessageBody:@"Hey,\n\nThought you might be interested to check out this app I am in love with: www.samepinch.co\n\nThanks,\nSamePinch Fan" isHTML:NO];
        
        mailComposer.navigationBar.barStyle = UIBarStyleBlackOpaque;
        [self presentViewController:mailComposer animated:YES completion:^{
            [appdelegate showOrhideIndicator:NO];
            
        }];
    }
    
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    NSString *messageStr = nil;
    switch (result){
            
        case MFMailComposeResultSaved:; //Mail is saved
            messageStr = @"Email saved successfully";
            break;
            
        case MFMailComposeResultSent:; //Mail is sent
            messageStr = @"Email sent successfully";
            break;
            
            
        case MFMailComposeResultFailed:;    //Mail sending id failed.
            //messageStr = @"Email sending failed";
            break;
            
        case MFMailComposeResultCancelled: break; //If we click on the cancle.
            
        default: break;
            
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if(result != MFMailComposeResultCancelled )
    {
        ShowAlert(PROJECT_NAME,messageStr, @"OK");
    }
    
}
#pragma mark -
#pragma mark Message Composer

//pops up the native SMS window to send the sms message to their friend
- (void)showSMS
{
    
    if(![MFMessageComposeViewController canSendText])
    {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    [appdelegate showOrhideIndicator:YES];
    
    NSString *message = [NSString stringWithFormat:@"%@", @"Hey,\n\nThought you might be interested to check out this app I am in love with: www.samepinch.co\n\nThanks,\nSamePinch Fan"];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:^{ [appdelegate showOrhideIndicator:NO];}];
}

//This method is called when a button is clicked in the native send SMS popup
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result)
    {
        case MessageComposeResultCancelled:
        {
        }
            break;
            
        case MessageComposeResultFailed:
        {
            break;
        }
            
        case MessageComposeResultSent:
        {
            //calling sms confirmation api
        }
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
