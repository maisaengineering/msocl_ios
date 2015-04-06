//
//  AddPostViewController.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import <AviarySDK/AviarySDK.h>

@interface AddPostViewController : UIViewController<UITextViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, AVYPhotoEditorControllerDelegate, UIPopoverControllerDelegate>
{
    UIImagePickerController *imagePicker;

}

@property (nonatomic , strong) UIScrollView *scrollView;

// To avoid the memory leaks declare a global alert
@property (nonatomic, strong) UIAlertView *globalAlert;

//For Aviary
@property (nonatomic, strong) ALAssetsLibrary     * assetLibrary;
@property (nonatomic, strong) NSMutableArray      * sessions;


@end
