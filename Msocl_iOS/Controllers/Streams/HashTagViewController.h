//
//  HashTagViewController.h
//  Msocl_iOS
//
//  Created by Maisa Pride on 9/23/16.
//  Copyright © 2016 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StreamDisplayView.h"
#import "SlideNavigationController.h"
#import "PostDetailDescriptionViewController.h"
#import "ProfilePhotoUtils.h"
#import "Webservices.h"

@interface HashTagViewController : UIViewController<StreamDisplayViewDelegate,SlideNavigationControllerDelegate,PostDetailsProtocol,webServiceProtocol>
{
}
@property (nonatomic, strong) NSString *tagName;
@end
