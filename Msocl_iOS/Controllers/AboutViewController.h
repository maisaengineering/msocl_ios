//
//  AboutViewController.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 5/19/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface AboutViewController : UIViewController<UIActionSheetDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>


-(IBAction)buttonTapped:(id)sender;
@end
