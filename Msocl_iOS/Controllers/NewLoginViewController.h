//
//  NewLoginViewController.h
//  Msocl_iOS
//
//  Created by Maisa Pride on 9/1/16.
//  Copyright © 2016 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Webservices.h"
@interface NewLoginViewController : UIViewController<webServiceProtocol>

@property (nonatomic, strong) IBOutlet UIImageView *bgImageView;


-(IBAction)closeClicked:(id)sender;
@end
