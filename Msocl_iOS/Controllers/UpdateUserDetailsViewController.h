//
//  UpdateUserDetailsViewController.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/23/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import <AviarySDK/AviarySDK.h>
#import "Webservices.h"

@interface UpdateUserDetailsViewController : UIViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, AVYPhotoEditorControllerDelegate,webServiceProtocol,
UIPopoverControllerDelegate>
{
    UIImagePickerController *imagePicker;
}
@property (nonatomic, strong) ALAssetsLibrary     * assetLibrary;
@property (nonatomic, strong) NSMutableArray      * sessions;

@property (nonatomic, strong) IBOutlet UITextField *txt_firstName;
@property (nonatomic, strong) IBOutlet UITextField *txt_lastname;
@property (nonatomic, strong) IBOutlet UITextField *txt_emailAddress;
@property (nonatomic, strong) IBOutlet UIImageView *profileImage;
@property (nonatomic, strong) IBOutlet UITextField *txt_postal_code;
@property (nonatomic, strong) IBOutlet UITextField *txt_phno;
@property (nonatomic, strong) IBOutlet UITextField *txt_blog;

-(IBAction)backClickes:(id)sender;
-(IBAction)closeClicked:(id)sender;
-(IBAction)signupClicked:(id)sender;
-(IBAction)chosePhoto:(id)sender;

@end