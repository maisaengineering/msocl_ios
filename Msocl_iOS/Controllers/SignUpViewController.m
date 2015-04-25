//
//  SignUpViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/7/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "SignUpViewController.h"
#import "ModelManager.h"
#import "StringConstants.h"
#import "AppDelegate.h"
#import "ProfilePhotoUtils.h"
#import "Base64.h"
#import "PromptImages.h"
@implementation SignUpViewController
{
    AppDelegate *appdelegate;
    BOOL photoFromCamera;
    BOOL isSignupClicked;
    ProfilePhotoUtils  *photoUtils;
    NSString *imageId;
    BOOL isUploadingImage;
    Webservices *webServices;
    UIImage *selectedImage;
    
}
@synthesize txt_firstName;
@synthesize txt_password;
@synthesize txt_confirmPassword;
@synthesize txt_emailAddress;
@synthesize txt_lastname;
@synthesize profileImage;
@synthesize txt_postal_code;
@synthesize txt_phno;
-(void)viewDidLoad
{
    [super viewDidLoad];
    appdelegate = [[UIApplication sharedApplication] delegate];
    photoUtils = [ProfilePhotoUtils alloc];
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    imageId = @"";
    //Aviary
    // Aviary iOS 7 Start
    ALAssetsLibrary * assetLibrary1 = [[ALAssetsLibrary alloc] init];
    [self setAssetLibrary:assetLibrary1];
    
    // Allocate Sessions Array
    NSMutableArray * sessions1 = [NSMutableArray new];
    [self setSessions:sessions1];
    
    // Start the Aviary Editor OpenGL Load
    [AFOpenGLManager beginOpenGLLoad];
    
    UIColor *color = [UIColor lightGrayColor];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:12.0];
    
    txt_password.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"Enter password"
                                    attributes:@{
                                                 NSForegroundColorAttributeName: color,
                                                 NSFontAttributeName : font
                                                 }
     ];
    txt_firstName.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"Enter first name"
                                    attributes:@{
                                                 NSForegroundColorAttributeName: color,
                                                 NSFontAttributeName : font
                                                 }
     ];
    txt_lastname.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"Enter last name"
                                    attributes:@{
                                                 NSForegroundColorAttributeName: color,
                                                 NSFontAttributeName : font
                                                 }
     ];
    txt_confirmPassword.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"Enter confirm password"
                                    attributes:@{
                                                 NSForegroundColorAttributeName: color,
                                                 NSFontAttributeName : font
                                                 }
     ];

    txt_confirmPassword.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"Enter confirm password"
                                    attributes:@{
                                                 NSForegroundColorAttributeName: color,
                                                 NSFontAttributeName : font
                                                 }
     ];

    txt_emailAddress.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"Enter email id"
                                    attributes:@{
                                                 NSForegroundColorAttributeName: color,
                                                 NSFontAttributeName : font
                                                 }
     ];

    
}
-(IBAction)backClickes:(id)sender
{
    [self resignKeyBoards];
    NSArray *viewControllers = [self.navigationController viewControllers];
    [self.navigationController popToViewController:viewControllers[viewControllers.count - 2] animated:NO];
}

-(IBAction)closeClicked:(id)sender
{
    [self resignKeyBoards];
    NSArray *viewControllers = [self.navigationController viewControllers];
    [self.navigationController popToViewController:viewControllers[viewControllers.count - 3] animated:NO];
}

#pragma mark -
#pragma mark Signup Methods
-(IBAction)signupClicked:(id)sender
{
    [self resignKeyBoards];
    if( txt_password.text.length == 0 || txt_lastname.text.length == 0 || txt_firstName.text.length == 0|| txt_emailAddress.text.length == 0|| txt_confirmPassword.text.length == 0)
    {
        ShowAlert(PROJECT_NAME,@"All fields are required", @"OK");
        return;
    }
    else if(![txt_confirmPassword.text isEqualToString:txt_password.text])
    {
        ShowAlert(PROJECT_NAME,@"Password and Confirm Password are not matching", @"OK");
        return;
    }
    else
    {
        isSignupClicked = YES;
        [appdelegate showOrhideIndicator:YES];
        if(!isUploadingImage)
            [self doSignup];
    }
}
-(void)doSignup
{
    NSMutableDictionary *postDetails  = [NSMutableDictionary dictionary];
    [postDetails setObject:txt_lastname.text forKey:@"lname"];
    [postDetails setObject:txt_firstName.text forKey:@"fname"];
    [postDetails setObject:txt_emailAddress.text forKey:@"email"];
    [postDetails setObject:txt_password.text forKey:@"password"];
    [postDetails setObject:txt_confirmPassword.text forKey:@"password_confirmation"];
    if(imageId.length > 0)
    [postDetails setObject:imageId forKey:@"key"];
    [postDetails setObject:DEVICE_UUID forKey:@"device_token"];
    [postDetails setObject:@"iOS" forKey:@"platform"];
    
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    
    NSString *command = @"SignUp";
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": @"create",
                               @"body": postDetails};
    NSDictionary *userInfo = @{@"command": command};
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}

-(void)signUpSccessfull:(NSDictionary *)responseDict
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLogedIn"];

    [[NSUserDefaults standardUserDefaults] setObject:responseDict forKey:@"userprofile"];
    
    NSMutableDictionary *tokenDict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"tokens"] mutableCopy];
    [tokenDict setObject:[responseDict objectForKey:@"access_token"] forKey:@"access_token"];
    [[NSUserDefaults standardUserDefaults] setObject:tokenDict forKey:@"tokens"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[[ModelManager sharedModel] accessToken] setAccess_token:[responseDict objectForKey:@"access_token"]];
    [[ModelManager sharedModel] setUserDetails:responseDict];
    [[PromptImages sharedInstance] getAllGroups];
    [appdelegate showOrhideIndicator:NO];
    NSArray *viewControllers = [self.navigationController viewControllers];
    [self.navigationController popToViewController:viewControllers[viewControllers.count - 3] animated:NO];
}
-(void)signUpFailed
{
    [appdelegate showOrhideIndicator:NO];
    ShowAlert(@"Error", @"Signup Failed", @"OK");
}
#pragma mark -
#pragma mark Image Selection Methods
-(IBAction)chosePhoto:(id)sender
{
    if ([self hasValidAPIKey])
    {
        UIActionSheet *addImageActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                              @"Take photo", @"Choose existing", nil];
        addImageActionSheet.tag = 1;
        [addImageActionSheet setDelegate:self];
        [addImageActionSheet showInView:[UIApplication sharedApplication].keyWindow];
        
    }
}
#pragma mark- Aviary API Key Validation Method

- (BOOL) hasValidAPIKey
{
    if ([kAFAviaryAPIKey isEqualToString:@"<YOUR-API-KEY>"] || [kAFAviarySecret isEqualToString:@"<YOUR-SECRET>"])
    {
        ShowAlert(@"Oops!", @"You forgot to add your API key and secret!", @"OK");
        return NO;
    }
    return YES;
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag)
    {
            ///For image captrure
        case 1:
        {
            switch (buttonIndex)
            {
                case 0:
                {
                    
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                    {
                        imagePicker = [[UIImagePickerController alloc]init];
                        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
                        imagePicker.delegate = self;
                        imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
                        photoFromCamera = TRUE;
                    }
                    else
                    {
                        ShowAlert(@"Error", @"This device doesn't have a camera.", @"OK");
                        
                    }
                    [self resignKeyBoards];
                    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
                    [self launchPicker];
                    break;
                }
                case 1:
                {
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
                    {
                        imagePicker = [[UIImagePickerController alloc]init];
                        
                        imagePicker.sourceType =  UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                        imagePicker.delegate = self;
                        photoFromCamera = FALSE;
                        
                    }
                    else
                    {
                        ShowAlert(@"Error", @"This device doesn't support photo libraries.", @"OK");
                        
                    }
                    [self resignKeyBoards];
                    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
                    [self launchPicker];
                    break;
                }
                    
                case 2:
                {
                    
                }
                default:
                    break;
            }
        }
            break;
            
            
        default:
            break;
    }
    
}

-(void)launchPicker
{
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

#pragma mark - Photo Editor Launch Methods

- (void) launchEditorWithAsset:(ALAsset *)asset
{
    UIImage * editingResImage = [self editingResImageForAsset:asset];
    UIImage * highResImage = [self highResImageForAsset:asset];
    
    [self launchPhotoEditorWithImage:editingResImage highResolutionImage:highResImage];
}

#pragma mark - Photo Editor Creation and Presentation
- (void) launchPhotoEditorWithImage:(UIImage *)editingResImage highResolutionImage:(UIImage *)highResImage
{
    // Customize the editor's apperance. The customization options really only need to be set once in this case since they are never changing, so we used dispatch once here.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setPhotoEditorCustomizationOptions];
    });
    
    // Initialize the photo editor and set its delegate
    AVYPhotoEditorController * photoEditor = [[AVYPhotoEditorController alloc] initWithImage:highResImage];
    [photoEditor setDelegate:self];
    
    // If a high res image is passed, create the high res context with the image and the photo editor.
    if (highResImage)
    {
        [self setupHighResContextForPhotoEditor:photoEditor withImage:highResImage];
    }
    else
    {
        [self setupHighResContextForPhotoEditor:photoEditor withImage:editingResImage];
    }
    
    // Present the photo editor.
    [self presentViewController:photoEditor animated:NO completion:^{ [appdelegate showOrhideIndicator:NO];    }];
}

- (void) setupHighResContextForPhotoEditor:(AVYPhotoEditorController *)photoEditor withImage:(UIImage *)highResImage
{
    id<AVYPhotoEditorRender> render = [photoEditor enqueueHighResolutionRenderWithImage:highResImage
                                                                             completion:^(UIImage *result, NSError *error) {
                                                                                 if (result) {
                                                                                 } else {
                                                                                     NSLog(@"High-res render failed with error : %@", error);
                                                                                 }
                                                                             }];
    
    
    
    // Provide a block to receive updates about the status of the render. This block will be called potentially multiple times, always
    // from the main thread.
    
    [render setProgressHandler:^(CGFloat progress) {
        NSLog(@"Render now %lf percent complete", round(progress * 100.0f));
    }];
}

#pragma Photo Editor Delegate Methods

// This is called when the user taps "Done" in the photo editor.
- (void) photoEditor:(AVYPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    [self finishedEditingImage:image];
}

-(void)finishedEditingImage:(UIImage *)image
{
    [self dismissViewControllerAnimated:YES completion:nil];
    profileImage.image = [photoUtils makeRoundKidPhoto:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(50, 50)]];
    selectedImage = image;
    [self UploadImage:image];
}


// This is called when the user taps "Cancel" in the photo editor.
- (void) photoEditorCanceled:(AVYPhotoEditorController *)editor
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Photo Editor Customization

- (void) setPhotoEditorCustomizationOptions
{
    // Set API Key and Secret
    [AVYPhotoEditorController setAPIKey:kAFAviaryAPIKey secret:kAFAviarySecret];
    
    // Set Tool Order
    // kAFStickers
    // NSArray * toolOrder = @[kAFEffects, kAFFocus, kAFFrames, kAFEnhance, kAFOrientation, kAFCrop, kAFAdjustments, kAFSplash, kAFDraw, kAFText, kAFRedeye, kAFWhiten, kAFBlemish, kAFMeme];
    
    NSArray * toolOrder = @[kAVYOrientation , kAVYCrop, kAVYEffects, kAVYFrames, kAVYEnhance, kAVYColorAdjust, kAVYLightingAdjust, kAVYFocus];
    [AVYPhotoEditorCustomization setToolOrder:toolOrder];
    
    // Set Custom Crop Sizes
    [AVYPhotoEditorCustomization setCropToolOriginalEnabled:NO];
    [AVYPhotoEditorCustomization setCropToolCustomEnabled:YES];
    NSDictionary * fourBySix = @{kAVYCropPresetHeight : @(4.0f), kAVYCropPresetWidth : @(6.0f)};
    NSDictionary * fiveBySeven = @{kAVYCropPresetHeight : @(5.0f), kAVYCropPresetWidth : @(7.0f)};
    NSDictionary * square = @{kAVYCropPresetName: @"Square", kAVYCropPresetHeight : @(1.0f), kAVYCropPresetWidth : @(1.0f)};
    [AVYPhotoEditorCustomization setCropToolPresets:@[fourBySix, fiveBySeven, square]];
    
    // Set Supported Orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSArray * supportedOrientations = @[@(UIInterfaceOrientationPortrait), @(UIInterfaceOrientationPortraitUpsideDown), @(UIInterfaceOrientationLandscapeLeft), @(UIInterfaceOrientationLandscapeRight)];
        [AVYPhotoEditorCustomization setSupportedIpadOrientations:supportedOrientations];
    }
}

#pragma mark - UIImagePicker Delegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [appdelegate showOrhideIndicator:YES];
    NSURL * assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    void(^completion)(void)  = ^(void){
        
        [[self assetLibrary] assetForURL:assetURL resultBlock:^(ALAsset *asset)
         {
             if (asset)
             {
                 [self launchEditorWithAsset:asset];
                 
                 //save image to phone IF it came from camera
                 if (photoFromCamera == TRUE)
                 {
                     UIImage * origImage = info[UIImagePickerControllerOriginalImage];
                     [photoUtils saveImageToPhotoLib:origImage];
                 }
             }
             else
             {
                 
                 if (photoFromCamera == TRUE)
                 {
                     UIImage * origImage = info[UIImagePickerControllerOriginalImage];
                     [photoUtils saveImageToPhotoLib:origImage];
                 }
                 
                 
                 [self launchPhotoEditorWithImage:info[UIImagePickerControllerOriginalImage] highResolutionImage:info[UIImagePickerControllerOriginalImage]];
             }
         }
                            failureBlock:^(NSError *error) {
                                [appdelegate showOrhideIndicator:NO];
                                ShowAlert(@"Error", @"Please enable access to your device's photos.", @"OK");
                            }];
    };
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        [self dismissViewControllerAnimated:NO completion:completion];
    }else{
        //[self dismissPopoverWithCompletion:completion];
    }
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ALAssets Helper Methods

- (UIImage *)editingResImageForAsset:(ALAsset*)asset
{
    CGImageRef image = [[asset defaultRepresentation] fullScreenImage];
    
    return [UIImage imageWithCGImage:image scale:1.0 orientation:UIImageOrientationUp];
}

- (UIImage *)highResImageForAsset:(ALAsset*)asset
{
    ALAssetRepresentation * representation = [asset defaultRepresentation];
    
    CGImageRef image = [representation fullResolutionImage];
    UIImageOrientation orientation = (UIImageOrientation)[representation orientation];
    CGFloat scale = [representation scale];
    
    return [UIImage imageWithCGImage:image scale:scale orientation:orientation];
}

#pragma mark - Status Bar Style

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark- Photo upload Methods
#pragma mark-
-(void)UploadImage:(UIImage *)imageOrg
{
    isUploadingImage = YES;
    NSData *imageData = UIImageJPEGRepresentation(imageOrg, 0.7);
    NSString *fileExtension = @"JPEG";
    NSString *imageExtension = fileExtension;
    imageExtension = [imageExtension uppercaseString];
    NSString *stringImageName = [NSString stringWithFormat:@"temp.%@",imageExtension];
    NSString *stringContentType = [NSString stringWithFormat:@"image/%@",[imageExtension lowercaseString]];
    NSString *stringContent = [imageData base64EncodedString];
    
    NSMutableDictionary *newImageDetails  = [NSMutableDictionary dictionary];
    [newImageDetails setValue:stringImageName     forKey:@"name"];
    [newImageDetails setValue:stringContentType   forKey:@"content_type"];
    [newImageDetails setValue:stringContent       forKey:@"content"];
    
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": @"s3upload",
                               @"body": newImageDetails};
    NSDictionary *userInfo = @{@"command": @"upload_Profile_Image"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
    
    
}
-(void)profileImageUploadSccess:(NSDictionary *)notifiDict
{
    imageId = [notifiDict objectForKey:@"key"];
    if(isUploadingImage && isSignupClicked)
    {
        isSignupClicked = NO;
        [self doSignup];
    }
    isUploadingImage = NO;
    
}
-(void)profileImageUploadFailed
{
    if(isUploadingImage && isSignupClicked)
    {
        isSignupClicked = NO;
        [self doSignup];
    }
    isUploadingImage = NO;
    
}

#pragma mark -
#pragma mark Textfield Delegate methods
-(void)resignKeyBoards
{
    for (UIView *i in self.view.subviews)
    {
        if([i isKindOfClass:[UITextField class]]){
            UITextField *txtfield = (UITextField *)i;
            {
                [txtfield resignFirstResponder];
            }
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
@end
