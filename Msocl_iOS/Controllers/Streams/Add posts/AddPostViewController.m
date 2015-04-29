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
#import "DXPopover.h"
#import "SDWebImageManager.h"
#import "UIImageView+AFNetworking.h"
#import "PhotoCollectionViewCell.h"

@implementation AddPostViewController
{
    UITextView *textView;
    AppDelegate *appdelegate;
    BOOL photoFromCamera;
    BOOL isPostClicked;
    ProfilePhotoUtils  *photoUtils;
    NSMutableDictionary *imagesIdDict;
    int uploadingImages;
    NSArray *tagsArray;
    UIView *inputView;
    UIButton *postButton;
    BOOL isPrivate;
    Webservices *webServices;
    DXPopover *popover;
    UIView *popView;
    UILabel *placeholderLabel;
    UIButton *anonymousButton;
    UIImageView *postAnonymous;

}
@synthesize scrollView;
@synthesize postDetailsObject;
@synthesize delegate;
@synthesize selectedtagsArray;
@synthesize collectionView;
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;

    
    photoUtils = [ProfilePhotoUtils alloc];
    uploadingImages = 0;
    if(selectedtagsArray.count == 0)
    selectedtagsArray = [[NSMutableArray alloc] init];
    tagsArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"Groups"];
    
    popover = [DXPopover popover];

   
    
    UIImage *background = [UIImage imageNamed:@"icon-back.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside]; //adding action
    [button setImage:background forState:UIControlStateNormal];
    button.frame = CGRectMake(0 ,0,13,17);
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    
    postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [postButton addTarget:self action:@selector(createPost) forControlEvents:UIControlEventTouchUpInside];
    [postButton setFrame:CGRectMake(250, 0, 35, 44)];
    [postButton setImage:[UIImage imageNamed:@"btn-post.png"] forState:UIControlStateNormal];

    anonymousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [anonymousButton setImage:[UIImage imageNamed:@"btn-post-more.png"] forState:UIControlStateNormal];
    [anonymousButton addTarget:self action:@selector(anonymousPostClicked:) forControlEvents:UIControlEventTouchUpInside];
    [anonymousButton setFrame:CGRectMake(285.3, 0, 26, 44)];
    
    postAnonymous = [[UIImageView alloc] initWithFrame:CGRectMake(4, 13, 18, 18)];

    __weak UIImageView *weakSelf = postAnonymous;
    __weak ProfilePhotoUtils *weakphotoUtils = photoUtils;
    ModelManager *sharedModel = [ModelManager sharedModel];
    
    [postAnonymous setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:sharedModel.userProfile.image]] placeholderImage:[UIImage imageNamed:@"icon-profile-register.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf.image = [weakphotoUtils makeRoundWithBoarder:[weakphotoUtils squareImageWithImage:image scaledToSize:CGSizeMake(18, 18)] withRadious:0];
         
     }failure:nil];
    [anonymousButton addSubview:postAnonymous];
    
    [self.navigationController.navigationBar addSubview:postButton];
    [self.navigationController.navigationBar addSubview:anonymousButton];
    
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
    
    
    if(postDetailsObject != nil)
    {
        [self setDetails];
    }
    if(selectedtagsArray.count > 0)
    [collectionView reloadData];

}

-(void)backClicked
{
    [textView resignFirstResponder];
    [postButton removeFromSuperview];
    [postAnonymous removeFromSuperview];
    [anonymousButton removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];

}
-(void)postDetailsScroll
{
    int height = Deviceheight-64;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, Deviceheight)];
    else
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, 320, height)];
    scrollView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    [self.view addSubview:scrollView];

    UIButton *addPhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addPhotoBtn.frame = CGRectMake(10, 4, 28, 30);
    [addPhotoBtn setImage:[UIImage imageNamed:@"icon-camera-add.png"] forState:UIControlStateNormal];
    [addPhotoBtn addTarget:self action:@selector(AddPhoto) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:addPhotoBtn];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, addPhotoBtn.frame.origin.y+addPhotoBtn.frame.size.height+4, 300, 188)];
    [imageView setImage:[UIImage imageNamed:@"textfield.png"]];
    [scrollView addSubview:imageView];

    textView = [[UITextView alloc] initWithFrame:CGRectMake(14,addPhotoBtn.frame.origin.y+addPhotoBtn.frame.size.height+8,292, 180)];
    textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
    textView.delegate = self;
    [scrollView addSubview:textView];
    
    placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 0, textView.frame.size.width, 20)];
    //[placeholderLabel setText:placeholder];
    [placeholderLabel setBackgroundColor:[UIColor clearColor]];
    [placeholderLabel setNumberOfLines:0];
    placeholderLabel.text = @"Write description";
    [placeholderLabel setTextAlignment:NSTextAlignmentLeft];
    [placeholderLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:12]];
    [placeholderLabel setTextColor:[UIColor lightGrayColor]];
    [textView addSubview:placeholderLabel];

    
    inputView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [inputView setBackgroundColor:[UIColor colorWithRed:0.56f
                                                  green:0.59f
                                                   blue:0.63f
                                                  alpha:1.0f]];
    
    UIButton *donebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [donebtn setFrame:CGRectMake(250, 0, 70, 40)];
    [donebtn setTitle:@"Done" forState:UIControlStateNormal];
    [donebtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15]];
    [donebtn addTarget:self action:@selector(doneClick:) forControlEvents:UIControlEventTouchUpInside];
    [inputView addSubview:donebtn];
    
    
    
    UILabel *selectTagslabel = [[UILabel alloc] initWithFrame:CGRectMake(10, textView.frame.origin.y+textView.frame.size.height+20, 300, 20)];
    [selectTagslabel setFont:[UIFont fontWithName:@"HelveticaNeue-Roman" size:12]];
    [selectTagslabel setText:@"Select tags"];
    [scrollView addSubview:selectTagslabel];
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 7;
    layout.minimumLineSpacing = 7;

    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, selectTagslabel.frame.origin.y+selectTagslabel.frame.size.height+10, 300, height - selectTagslabel.frame.origin.y+selectTagslabel.frame.size.height) collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [collectionView setBackgroundColor:[UIColor clearColor]];
    [scrollView addSubview:collectionView];

    
}
-(void)setDetails
{
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setFrame:CGRectMake(287, 4, 30, 30)];
    [deleteButton setImage:[UIImage imageNamed:@"icon-delete-post.png"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:deleteButton];

    if(postDetailsObject.anonymous)
    {
        isPrivate = YES;
        postAnonymous.image = [UIImage imageNamed:@"icon-anamous.png"];

        
    }
    else
    {
        isPrivate = NO;
    }
    
    [placeholderLabel removeFromSuperview];
    self.title = @"EDIT POST";
    [postButton setTitle:@"Save" forState:UIControlStateNormal];
    [postButton removeTarget:self action:@selector(createPost) forControlEvents:UIControlEventTouchUpInside];
    [postButton addTarget:self action:@selector(editPost) forControlEvents:UIControlEventTouchUpInside];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:postDetailsObject.content attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:14],NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]}];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\::(.*?)\\::" options:NSRegularExpressionCaseInsensitive error:NULL];
    
    
    do{
        
        NSArray *myArray = [regex matchesInString:attributedString.string options:0 range:NSMakeRange(0, [attributedString.string length])] ;
        if(myArray.count > 0)
        {
            NSTextCheckingResult *match =  [myArray firstObject];
            NSRange matchRange = [match rangeAtIndex:1];
            NSLog(@"%@", [attributedString.string substringWithRange:matchRange]);
            
            UIImage  *image = [photoUtils imageWithImage:[UIImage imageNamed:@"EmptyProfilePic.jpg"] scaledToSize:CGSizeMake(26, 16) withRadious:3.0];
            NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
            
            NSString *identifier = [NSString stringWithFormat:@"image%lu",(unsigned long)imagesIdDict.count+1];
            image.accessibilityIdentifier = identifier;
            textAttachment.image = image;
            [imagesIdDict setObject:[attributedString.string substringWithRange:matchRange] forKey:identifier];

            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:[NSURL URLWithString:[postDetailsObject.images objectForKey:[attributedString.string substringWithRange:matchRange]]] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                image = [photoUtils imageWithImage:image scaledToSize:CGSizeMake(26, 16) withRadious:3.0];
                image.accessibilityIdentifier = textAttachment.image.accessibilityIdentifier;
                textAttachment.image = image;
                [textView setNeedsDisplay];
            }];
            
            NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
            [attributedString replaceCharactersInRange:match.range withAttributedString:attrStringWithImage];
            
        }

        else
        {
            break;
        }
        
    }while (1);

    textView.attributedText = attributedString;

    selectedtagsArray = [postDetailsObject.tags mutableCopy];
    [collectionView reloadData];

}

-(void)deleteButtonClicked
{
    UIAlertView *cautionAlert = [[UIAlertView alloc]initWithTitle:@"Sure you want to delete this post?" message:@"" delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel", nil];
    cautionAlert.tag = 1;
    [cautionAlert show];
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        if (buttonIndex == 0)
        {
            // Delete
            [appdelegate showOrhideIndicator:YES];
            AccessToken* token = [[ModelManager sharedModel] accessToken];
            
            NSDictionary *postData = @{@"command": @"destroy",@"access_token": token.access_token};
            NSDictionary *userInfo = @{@"command": @"deletePost"};
            
            NSString *urlAsString = [NSString stringWithFormat:@"%@posts/%@",BASE_URL,postDetailsObject.uid];
            [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
        }
        else if (buttonIndex == 1)
        {
            // Cancel
        }
    }
    
    
}
-(void) postDeleteSuccessFull:(NSDictionary *)recievedDict
{
    [postButton removeFromSuperview];
    [anonymousButton removeFromSuperview];
    [postAnonymous removeFromSuperview];

    
    [appdelegate showOrhideIndicator:NO];
    [self.delegate PostDeletedFromEditPostDetails];
    NSArray *viewControllers = [self.navigationController viewControllers];
    [self.navigationController popToViewController:viewControllers[viewControllers.count - 3] animated:YES];
    
}
-(void) postDeleteFailed
{
    [appdelegate showOrhideIndicator:NO];
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
                        ShowAlert(@"Error", @"This device doesn't support photo libraries.", @"OK");

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
            
       //For Privacy
        case 2:
        {
            switch (buttonIndex)
            {
                case 0:
                {
                    isPrivate = NO;
                    [self createPost];
                    break;
                }
                case 1:
                {
                    isPrivate = YES;
                    [self createPost];
                    break;
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
    
    image = [photoUtils imageWithImage:image scaledToSize:CGSizeMake(26, 16) withRadious:3.0];
    NSMutableAttributedString *attributedString = [textView.attributedText mutableCopy];
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    image.accessibilityIdentifier = identifier;
    textAttachment.image = image;

  //  textAttachment.image = [UIImage imageWithCGImage:textAttachment.image.CGImage scale:1 orientation:UIImageOrientationUp];
   
    
    
   NSRange selectedrange = textView.selectedRange;
    if(textView.text.length > textView.selectedRange.location)
    {
        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [attributedString insertAttributedString:[[NSAttributedString alloc] initWithString:@"\n"] atIndex:selectedrange.location];
        [attributedString insertAttributedString:attrStringWithImage atIndex:selectedrange.location+1];
        [attributedString insertAttributedString:[[NSAttributedString alloc] initWithString:@"\n"] atIndex:selectedrange.location+2];
        
    }
    else
    {
        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        [attributedString appendAttributedString:attrStringWithImage];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        
    }
    [attributedString addAttributes:@{NSFontAttributeName:textView.font} range:NSMakeRange(0, attributedString.string.length)];

    textView.attributedText = attributedString;
    
    uploadingImages ++;
    
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



#pragma mark- Image upload Methods
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
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": @"s3upload",
                               @"body": newImageDetails};
    NSDictionary *userInfo = @{@"command": @"upload_to_s3",@"identifier":imageOrg.accessibilityIdentifier};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];


}
-(void)uploadImageSccess:(NSDictionary *)notifiDict
{
    uploadingImages--;
    NSDictionary *responseDict = [notifiDict objectForKey:@"response"];
    [imagesIdDict setObject:[responseDict objectForKey:@"key"] forKey:[notifiDict objectForKey:@"identifier"]];
    if(uploadingImages == 0 && isPostClicked)
    {
        isPostClicked = NO;
        if(postDetailsObject != nil)
            [self callEditPostApi];
        else
        [self callPostApi];
    }
    
}
-(void)uploadImageFailed
{
    uploadingImages--;
    if(uploadingImages == 0 && isPostClicked)
    {
        isPostClicked = NO;
            if(postDetailsObject != nil)
                [self callEditPostApi];
            else
                [self callPostApi];
    }
}


#pragma mark - UICollectionViewDataSource Methods
#pragma mark -
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
        return tagsArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    CGSize retval;
    retval.height= 90; retval.width = 95; return retval;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"cellIdentifier";
    
    PhotoCollectionViewCell* cell=[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
    [imageView setImage:[UIImage imageNamed:@"yoga-img.png"]];
    [cell addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 95, 20)];
    label.backgroundColor = [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1.0];
    [label setText:[[tagsArray objectAtIndex:indexPath.row] objectForKey:@"name"]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
    [label setTextColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0]];
    [cell addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"tag-tick-active.png"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(80, 4, 15, 15)];
    [cell addSubview:button];
    
    if([selectedtagsArray containsObject:[[tagsArray objectAtIndex:indexPath.row] objectForKey:@"name"]])
    {
        [button setImage:[UIImage imageNamed:@"tag-tick.png"] forState:UIControlStateNormal];
        [label setBackgroundColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0]];
        [label setTextColor:[UIColor whiteColor]];
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView1 didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([selectedtagsArray containsObject:[[tagsArray objectAtIndex:indexPath.row] objectForKey:@"name"]])
    {
        [selectedtagsArray removeObject:[[tagsArray objectAtIndex:indexPath.row] objectForKey:@"name"]];
    }
    else
    {
        [selectedtagsArray addObject:[[tagsArray objectAtIndex:indexPath.row] objectForKey:@"name"]];
    }
    [collectionView1 reloadData];
}


#pragma mark -
#pragma mark Text View Delegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView1
{
    [placeholderLabel removeFromSuperview];
    [textView setInputAccessoryView:inputView];
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView1
{
    
    [textView setInputAccessoryView:inputView];
    [placeholderLabel removeFromSuperview];
    return YES;
    
}
- (void)textViewDidEndEditing:(UITextView *)txtView
{
    if (![txtView hasText])
        [txtView addSubview:placeholderLabel];
}
- (void)textViewDidChange:(UITextView *)textView1
{
    if(![textView1 hasText])
    {
        [textView1 addSubview:placeholderLabel];
    }
    else if ([[textView1 subviews] containsObject:placeholderLabel])
    {
        [placeholderLabel removeFromSuperview];
        
    }
    
}

-(void)textChangedCustomEvent
{
    [placeholderLabel removeFromSuperview];
    
}

-(void)doneClick:(id)sender
{
    [textView resignFirstResponder];
}

#pragma mark -
#pragma mark Post Methods
-(void)postAsAnonymous
{
    
    [popover dismiss];
    postAnonymous.image = [UIImage imageNamed:@"icon-anamous.png"];
 isPrivate = YES;
    /*
    if(textView.text.length == 0)
    {
        ShowAlert(PROJECT_NAME, @"Please enter text", @"OK");
        return;
    }
    if([tagsArray count] == 0)
    {
            ShowAlert(PROJECT_NAME, @"Please select atleast one tag", @"OK");
            return;
    }
    isPrivate = YES;
    if(postDetailsObject != nil)
        [self editPost];
    else
    [self createPost];
     */
}
-(void)anonymousPostClicked:(id)sender
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = [(UIButton *)sender frame];
    frame.origin.y += 20;
    btn.frame = frame;
    
    popView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 32)];
    
    if(!isPrivate)
    {
        UILabel *postAsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 32)];
        [postAsLabel setText:@"Post as"];
        [postAsLabel setTextAlignment:NSTextAlignmentCenter];
        [postAsLabel setTextColor:[UIColor colorWithRed:76/255.0 green:121/255.0 blue:251/255.0 alpha:1.0]];
        [postAsLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        [popView addSubview:postAsLabel];
        
        UIImageView *anonymusImage = [[UIImageView alloc] initWithFrame:CGRectMake(182, 4, 32, 24)];
        [anonymusImage setImage:[UIImage imageNamed:@"icon-anamous.png"]];
        [popView addSubview:anonymusImage];
        
        UIButton *postBtnAnonymous = [UIButton buttonWithType:UIButtonTypeCustom];
        postBtnAnonymous.frame = CGRectMake(0, 0, 300, 32);
        [postBtnAnonymous addTarget:self action:@selector(postAsAnonymous) forControlEvents:UIControlEventTouchUpInside];
        [popView addSubview:postBtnAnonymous];

    }
    else
    {
        UILabel *postAsLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 32)];
        [postAsLabel1 setText:@"Post as"];
        [postAsLabel1 setTextAlignment:NSTextAlignmentCenter];
        [postAsLabel1 setTextColor:[UIColor colorWithRed:76/255.0 green:121/255.0 blue:251/255.0 alpha:1.0]];
        [postAsLabel1 setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        [popView addSubview:postAsLabel1];
        
        UIImageView *userImage = [[UIImageView alloc] initWithFrame:CGRectMake(182, 4, 24, 24)];
        
        __weak UIImageView *weakSelf1 = userImage;
        __weak ProfilePhotoUtils *weakphotoUtils1 = photoUtils;
        ModelManager *sharedModel = [ModelManager sharedModel];

        [userImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:sharedModel.userProfile.image]] placeholderImage:[UIImage imageNamed:@"icon-profile-register.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             weakSelf1.image = [weakphotoUtils1 makeRoundWithBoarder:[weakphotoUtils1 squareImageWithImage:image scaledToSize:CGSizeMake(24, 24)] withRadious:0];
             
         }failure:nil];
        [popView addSubview:userImage];
        
        UIButton *postBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        postBtn.frame = CGRectMake(0, 0, 300, 32);
        [postBtn addTarget:self action:@selector(postClicked) forControlEvents:UIControlEventTouchUpInside];
        [popView addSubview:postBtn];

    }
    
    
    


    [popover showAtView:btn withContentView:popView];

}
-(void)postClicked
{
    [popover dismiss];
    __weak UIImageView *weakSelf = postAnonymous;
    __weak ProfilePhotoUtils *weakphotoUtils = photoUtils;
    ModelManager *sharedModel = [ModelManager sharedModel];
    
    [postAnonymous setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:sharedModel.userProfile.image]] placeholderImage:[UIImage imageNamed:@"icon-profile-register.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf.image = [weakphotoUtils makeRoundWithBoarder:[weakphotoUtils squareImageWithImage:image scaledToSize:CGSizeMake(18, 18)] withRadious:0];
         
     }failure:nil];
    isPrivate = NO;
    
}
-(void)createPost
{
    
    [appdelegate showOrhideIndicator:YES];
    isPostClicked = YES;
    postButton.enabled = NO;
    if(uploadingImages == 0)
    {
        [self callPostApi];
    }
}

#pragma mark Create Post
-(void)callPostApi
{
    [textView resignFirstResponder];
    
    NSMutableDictionary *postDetails  = [NSMutableDictionary dictionary];
    
    //Visiblity
    if(isPrivate)
        [postDetails setObject:[NSNumber numberWithBool:YES] forKey:@"anonymous"];
    else
        [postDetails setObject:[NSNumber numberWithBool:NO] forKey:@"anonymous"];
    
    //Tags
    if([selectedtagsArray count] > 0)
    [postDetails setObject:selectedtagsArray forKey:@"tags_array"];
    
    //Text
    NSString *formatedDesc = [self formatStringForServer:textView.attributedText];
    [postDetails setObject:formatedDesc forKey:@"content"];

    //Image Ids
    if([[imagesIdDict allValues] count] > 0)
    [postDetails setObject:[imagesIdDict allValues] forKey:@"img_keys"];
    
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
 
    NSString *command = @"create";
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": command,
                               @"body": postDetails};
    NSDictionary *userInfo = @{@"command": @"createPost"};
    NSString *urlAsString = [NSString stringWithFormat:@"%@posts",BASE_URL];
    
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
    
    isPrivate = postDetailsObject.anonymous;
}
-(void)postCreationSccessfull:(NSDictionary *)notificationDict
{
    [appdelegate showOrhideIndicator:NO];
    isPostClicked = NO;
    postButton.enabled = YES;
    
    [postButton removeFromSuperview];
    [anonymousButton removeFromSuperview];
    [postAnonymous removeFromSuperview];

    [self.navigationController popViewControllerAnimated:YES];
}
-(void)postCreationFailed
{
    [appdelegate showOrhideIndicator:NO];
    
    isPostClicked = NO;
    postButton.enabled = YES;
    
    ShowAlert(@"Error", POST_CREATION_FAILED, @"OK");
}

#pragma Edit Post
-(void)editPostClicked
{
    if(textView.text.length == 0)
    {
        ShowAlert(PROJECT_NAME, @"Please enter text", @"OK");
        return;
    }
    if([selectedtagsArray count] == 0)
    {
        ShowAlert(PROJECT_NAME, @"Please select atleast one tag", @"OK");
        return;
    }
    isPrivate = NO;
    [self editPost];

}
-(void)editPost
{
    [appdelegate showOrhideIndicator:YES];
    isPostClicked = YES;
    postButton.enabled = NO;
    if(uploadingImages == 0)
    {
        [self callEditPostApi];
    }

}
-(void)callEditPostApi
{
    
    [textView resignFirstResponder];
    NSMutableDictionary *postDetails  = [NSMutableDictionary dictionary];
    
    //Visiblity
    if(isPrivate)
        [postDetails setObject:[NSNumber numberWithBool:YES] forKey:@"anonymous"];
    else
        [postDetails setObject:[NSNumber numberWithBool:NO] forKey:@"anonymous"];
    
    //Tags
    if([selectedtagsArray count] > 0)
        [postDetails setObject:selectedtagsArray forKey:@"tags_array"];
    
    //Text
    NSString *formatedDesc = [self formatStringForServer:textView.attributedText];
    [postDetails setObject:formatedDesc forKey:@"content"];
    
    //Image Ids
    if([[imagesIdDict allValues] count] > 0)
        [postDetails setObject:[imagesIdDict allValues] forKey:@"img_keys"];
    
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    
    NSString *command = @"update";
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": command,
                               @"body": postDetails};
    NSDictionary *userInfo = @{@"command": @"updatePost"};
    NSString *urlAsString = [NSString stringWithFormat:@"%@posts/%@",BASE_URL,postDetailsObject.uid];
    
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}
-(void) updatePostSccessfull:(PostDetails *)postDetails
{
    [appdelegate showOrhideIndicator:NO];
    isPostClicked = NO;
    postButton.enabled = YES;
    
    [postButton removeFromSuperview];
    [anonymousButton removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate PostEdited:postDetails];

}
-(void) updatePostFailed
{
    [appdelegate showOrhideIndicator:NO];
    
    isPostClicked = NO;
    postButton.enabled = YES;
    
    ShowAlert(@"Error", POST_CREATION_FAILED, @"OK");
}
#pragma mark -
#pragma mark Methods To Proccess String For Server
-(NSString *)formatStringForServer:(NSAttributedString *)stringToFormat
{
    //for each attributed string replace with kl_id
    NSMutableAttributedString *newAttrString = [stringToFormat mutableCopy];
    
    [newAttrString beginEditing];
    
    [newAttrString enumerateAttributesInRange:NSMakeRange(0, newAttrString.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:
     ^(NSDictionary *attributes, NSRange attrRange, BOOL *stop)
     {
         NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
         
         NSTextAttachment *textAttachment = [mutableAttributes objectForKey:@"NSAttachment"];
         if(textAttachment != nil)
         {
             NSString *identifier = textAttachment.image.accessibilityIdentifier;
             [[newAttrString mutableString] replaceCharactersInRange:attrRange withString:[NSString stringWithFormat:@"::%@::",[imagesIdDict objectForKey:identifier]]];
         }
         
     }];
    
    [newAttrString endEditing];
    
    NSString *stringToReturn = newAttrString.string;
    return stringToReturn;
    
}
@end
