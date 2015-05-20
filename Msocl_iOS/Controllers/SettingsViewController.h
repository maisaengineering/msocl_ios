//
//  SettingsViewController.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/22/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIButton *changePasswordBtn;
-(IBAction)changePassword:(id)sender;
-(IBAction)manageTags:(id)sender;
@end
