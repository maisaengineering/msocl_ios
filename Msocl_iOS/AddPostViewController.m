//
//  AddPostViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "AddPostViewController.h"
#import "StringConstants.h"
#import "AppDelegate.h"
#import "ModelManager.h"
#import "Base64.h"
#import "Webservices.h"
#import "ProfilePhotoUtils.h"

@implementation AddPostViewController
{
    UITextView *textView;
    AppDelegate *appdelegate;
    BOOL photoFromCamera;
    BOOL isPostClicked;
    ProfilePhotoUtils  *photoUtils;
    NSMutableDictionary *imagesIdDict;
    int uploadingImages;

}
@synthesize scrollView;
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    photoUtils = [ProfilePhotoUtils alloc];
    uploadingImages = 0;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,screenWidth, 64)];
    [topView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:topView];
    UIImageView *lineImage = [[UIImageView alloc] init];
    [lineImage setBackgroundColor:[UIColor colorWithRed:192/255.0 green:184/255.0 blue:176/255.0 alpha:1.0]];
    [lineImage setFrame:CGRectMake(0, 63.5f, screenWidth, 0.5f)];
    [self.view addSubview:lineImage];
    
    
    
    CGRect frame = CGRectMake(0, 17, screenWidth, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:69.0/255.0 green:199.0/255.0 blue:242.0/255.0 alpha:1.0];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0];
    label.text = @"Add post";
    [topView addSubview:label];
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitleColor:[UIColor colorWithRed:(251/255.f) green:(176/255.f) blue:(64/255.f) alpha:1] forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(-0.5, 20.5, 80, 44)];
    [cancelButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Roman" size:17]];
    [topView addSubview:cancelButton];
    
    imagesIdDict = [[NSMutableDictionary alloc] init];
    
    [self postDetailsScroll];
    
    
    //Aviary
    // Aviary iOS 7 Start
    ALAssetsLibrary * assetLibrary1 = [[ALAssetsLibrary alloc] init];
    [self setAssetLibrary:assetLibrary1];
    
    // Allocate Sessions Array
    NSMutableArray * sessions1 = [NSMutableArray new];
    [self setSessions:sessions1];
    
    // Start the Aviary Editor OpenGL Load
    [AFOpenGLManager beginOpenGLLoad];
    
    [self RemoveOrAddUploadPostImageObservers:YES];

}
-(void)cancelClicked:(id)sender
{
    [textView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];

}
-(void)postDetailsScroll
{
    int height = Deviceheight-64;
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, 320, height)];
    scrollView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:scrollView];

    textView = [[UITextView alloc] initWithFrame:CGRectMake(10,10,300, 180)];
    textView.font = [UIFont systemFontOfSize:16];
    textView.delegate = self;
    [scrollView addSubview:textView];
    
    UIButton *addPhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addPhotoBtn.frame = CGRectMake(10, textView.frame.origin.y+textView.frame.size.height, 100, 30);
    [addPhotoBtn setTitle:@"Add Photo" forState:UIControlStateNormal];
    [addPhotoBtn addTarget:self action:@selector(AddPhoto) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:addPhotoBtn];
    
    [textView becomeFirstResponder];
}


#pragma mark -
#pragma mark Image Methods

-(void)AddPhoto
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
        UIAlertView *forgotKeyAlert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                 message:@"You forgot to add your API key and secret!"
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
        self.globalAlert = forgotKeyAlert;
        
        [forgotKeyAlert show];
        return NO;
    }
    return YES;
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag)
    {
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
                        UIAlertView *alert;
                        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                           message:@"This device doesn't have a camera."
                                                          delegate:self cancelButtonTitle:@"Ok"
                                                 otherButtonTitles:nil];
                        
                        self.globalAlert = alert;
                        
                        [alert show];
                    }
                    [textView resignFirstResponder];
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
                        UIAlertView *alert;
                        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                           message:@"This device doesn't support photo libraries."
                                                          delegate:self cancelButtonTitle:@"Ok"
                                                 otherButtonTitles:nil];
                        
                        self.globalAlert = alert;
                        
                        [alert show];
                    }
                    [textView resignFirstResponder];
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
    
    //It used to identify the attched image when sending to srever
    NSString *identifier = [NSString stringWithFormat:@"image%lu",(unsigned long)imagesIdDict.count+1];
    image.accessibilityIdentifier = identifier;
    [self UploadImage:image];
    
    image = [photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(30, 30)];
    NSMutableAttributedString *attributedString = [textView.attributedText mutableCopy];
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    image.accessibilityIdentifier = identifier;
    textAttachment.image = image;

  //  textAttachment.image = [UIImage imageWithCGImage:textAttachment.image.CGImage scale:1 orientation:UIImageOrientationUp];
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    [attributedString appendAttributedString:attrStringWithImage];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    [attributedString addAttributes:@{NSFontAttributeName:textView.font} range:NSMakeRange(0, attributedString.string.length)];
    textView.attributedText = attributedString;
    [textView becomeFirstResponder];
    
    [self formatStringForServer:attributedString];
    uploadingImages ++;
    
}


// This is called when the user taps "Cancel" in the photo editor.
- (void) photoEditorCanceled:(AVYPhotoEditorController *)editor
{
    [textView becomeFirstResponder];
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
                                UIAlertView *disableAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enable access to your device's photos." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                self.globalAlert = disableAlert;
                                [disableAlert show];
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
    [textView becomeFirstResponder];
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



#pragma mark- MilestoneImageUploadManagerDelegate Methods
#pragma mark-
-(void)UploadImage:(UIImage *)imageOrg
{
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
    UserProfile *_userProfile = sharedModel.userProfile;
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": @"upload_to_s3",
                               @"body": newImageDetails};
    NSDictionary *userInfo = @{@"command": @"upload_to_s3",@"identifier":imageOrg.accessibilityIdentifier};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@v2/posts",BASE_URL];
    [[Webservices sharedInstance] uploadPostImage:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];


}
-(void)uploadImageSccess:(NSNotification *)notificationObject
{
    uploadingImages--;
    NSDictionary *notifiDict = [notificationObject object];
    NSDictionary *responseDict = [notifiDict objectForKey:@"response"];
    [imagesIdDict setObject:[responseDict objectForKey:@"id"] forKey:[notifiDict objectForKey:@"identifier"]];
    if(uploadingImages == 0 && isPostClicked)
    {
        isPostClicked = NO;
    }
}
-(void)uploadImageFailed
{
    
}

-(void)RemoveOrAddUploadPostImageObservers:(BOOL)key
{
    if(key)
    {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(uploadImageSccess:) name:API_SUCCESS_UPLOAD_POST_IMAGES object:Nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(uploadImageFailed) name:API_FAILED_UPLOAD_POST_IMAGES object:Nil];

    }
    else
    {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:API_SUCCESS_UPLOAD_POST_IMAGES object:nil];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:API_FAILED_UPLOAD_POST_IMAGES object:nil];

    }
}

#pragma mark -
#pragma mark Post Methods
-(void)postClicked
{
    isPostClicked = YES;
    [appdelegate showOrhideIndicator:YES];
    if(uploadingImages == 0)
    {
        
    }
}
#pragma mark -
#pragma mark Methods To Proccess String For Server
-(NSString *)formatStringForServer:(NSAttributedString *)stringToFormat
{
    //for each attributed string replace with kl_id
    NSMutableAttributedString *newAttrString = [stringToFormat mutableCopy];
    
    //first replace our special chars just in case
    [[newAttrString mutableString] replaceOccurrencesOfString:@"::" withString:@"||" options:NSCaseInsensitiveSearch range:NSMakeRange(0, newAttrString.string.length)];
    
    [newAttrString beginEditing];
    
    [newAttrString enumerateAttributesInRange:NSMakeRange(0, newAttrString.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:
     ^(NSDictionary *attributes, NSRange attrRange, BOOL *stop)
     {
         NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
         
         NSTextAttachment *textAttachment = [mutableAttributes objectForKey:@"NSAttachment"];
         if(textAttachment != nil)
         {
             NSString *identifier = textAttachment.image.accessibilityIdentifier;
             [[newAttrString mutableString] replaceCharactersInRange:attrRange withString:identifier];
         }
         
     }];
    
    [newAttrString endEditing];
    
    NSString *stringToReturn = newAttrString.string;
    return stringToReturn;
    
}
@end