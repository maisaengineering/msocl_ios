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
    UITableView *tagsTableView;
    NSMutableArray *selectedtagsArray;
    UIView *inputView;
    UIButton *postButton;
    BOOL isPrivate;
    Webservices *webServices;
    DXPopover *popover;
    UIView *popView;

}
@synthesize scrollView;
@synthesize postDetailsObject;
@synthesize delegate;
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;

    
    photoUtils = [ProfilePhotoUtils alloc];
    uploadingImages = 0;
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
    [postButton setTitle:@"Post" forState:UIControlStateNormal];
    [postButton addTarget:self action:@selector(postClicked) forControlEvents:UIControlEventTouchUpInside];
    [postButton setTitleColor:[UIColor colorWithRed:(251/255.f) green:(176/255.f) blue:(64/255.f) alpha:1] forState:UIControlStateNormal];
    [postButton setFrame:CGRectMake(240, 20.5, 80, 44)];
    [postButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Roman" size:17]];
    
    

    UIButton *anonymousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [anonymousButton setTitle:@"anon" forState:UIControlStateNormal];
    [anonymousButton addTarget:self action:@selector(anonymousPostClicked:) forControlEvents:UIControlEventTouchUpInside];
    [anonymousButton setTitleColor:[UIColor colorWithRed:(251/255.f) green:(176/255.f) blue:(64/255.f) alpha:1] forState:UIControlStateNormal];
    [anonymousButton setFrame:CGRectMake(240, 20.5, 40, 44)];
    [anonymousButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Roman" size:17]];

    
    UIBarButtonItem *postBarButton = [[UIBarButtonItem alloc] initWithCustomView:postButton];
    UIBarButtonItem *anonymousBarButton = [[UIBarButtonItem alloc] initWithCustomView:anonymousButton];

    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:postBarButton,anonymousBarButton, nil];

    
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
    
    popView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
    UILabel *postAsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
    [postAsLabel setText:@"Post as"];
    [postAsLabel setTextAlignment:NSTextAlignmentCenter];
    [postAsLabel setTextColor:[UIColor colorWithRed:76/255.0 green:121/255.0 blue:251/255.0 alpha:1.0]];
    [postAsLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
    [popView addSubview:postAsLabel];
    
    UIImageView *anonymusImage = [[UIImageView alloc] initWithFrame:CGRectMake(183, 5, 25, 20)];
    [anonymusImage setImage:[UIImage imageNamed:@""]];
    [popView addSubview:anonymusImage];
    
    UIButton *postBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    postBtn.frame = CGRectMake(0, 0, 300, 30);
    [postBtn addTarget:self action:@selector(postAsAnonymous) forControlEvents:UIControlEventTouchUpInside];
    [popView addSubview:postBtn];
    
    if(postDetailsObject != nil)
    {
        [self setDetails];
    }
}

-(void)backClicked
{
    [textView resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];

}
-(void)postDetailsScroll
{
    int height = Deviceheight-64;
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
    scrollView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    [self.view addSubview:scrollView];

    textView = [[UITextView alloc] initWithFrame:CGRectMake(10,10,300, 70)];
    textView.font = [UIFont systemFontOfSize:16];
    textView.delegate = self;
    [scrollView addSubview:textView];
    
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
    
    
    UIButton *addPhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addPhotoBtn.frame = CGRectMake(10, textView.frame.origin.y+textView.frame.size.height+10, 28, 23);
    [addPhotoBtn setImage:[UIImage imageNamed:@"icon-camera-add.png"] forState:UIControlStateNormal];
    [addPhotoBtn addTarget:self action:@selector(AddPhoto) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:addPhotoBtn];
    
    UILabel *selectTagslabel = [[UILabel alloc] initWithFrame:CGRectMake(15, addPhotoBtn.frame.origin.y+addPhotoBtn.frame.size.height+10, 300, 20)];
    [selectTagslabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13]];
    [selectTagslabel setText:@"Select tags"];
    [scrollView addSubview:selectTagslabel];
    
    tagsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, selectTagslabel.frame.origin.y+selectTagslabel.frame.size.height+10, 320, height - selectTagslabel.frame.origin.y+selectTagslabel.frame.size.height)];
    tagsTableView.delegate = self;
    tagsTableView.dataSource = self;
    tagsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [scrollView addSubview:tagsTableView];

    
    
}
-(void)setDetails
{
    [postButton setTitle:@"Save" forState:UIControlStateNormal];
    [postButton removeTarget:self action:@selector(postClicked) forControlEvents:UIControlEventTouchUpInside];
    [postButton addTarget:self action:@selector(editPostClicked) forControlEvents:UIControlEventTouchUpInside];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:postDetailsObject.content attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:11],NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]}];
    
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
    [tagsTableView reloadData];

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
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    [attributedString appendAttributedString:attrStringWithImage];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
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

#pragma mark- UITableView Data Source Methods
#pragma mark-
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return tagsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    UITableViewCell *cell = [tableView1 dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    for(UIView *viw in [[cell contentView] subviews])
        [viw removeFromSuperview];
    cell.textLabel.text = [[tagsArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    if([selectedtagsArray containsObject:[[tagsArray objectAtIndex:indexPath.row] objectForKey:@"name"]])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [cell.textLabel setTextColor:[UIColor colorWithRed:76/255.0 green:121/255.0 blue:251/255.0 alpha:1.0]];

    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell.textLabel setTextColor:[UIColor lightGrayColor]];

    }
        return cell;
}
- (void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView1 cellForRowAtIndexPath:indexPath];
    if(cell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell.textLabel setTextColor:[UIColor lightGrayColor]];
        [selectedtagsArray removeObject:[[tagsArray objectAtIndex:indexPath.row] objectForKey:@"name"]];
        
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [cell.textLabel setTextColor:[UIColor colorWithRed:76/255.0 green:121/255.0 blue:251/255.0 alpha:1.0]];
        [selectedtagsArray addObject:[[tagsArray objectAtIndex:indexPath.row] objectForKey:@"name"]];
    }
    [tagsTableView beginUpdates];
    [tagsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    [tagsTableView endUpdates];
}

#pragma mark -
#pragma mark Text View Delegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView1
{
    [textView setInputAccessoryView:inputView];
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView1
{
    
    [textView setInputAccessoryView:inputView];
    return YES;
    
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
    if(textView.text.length == 0)
    {
        ShowAlert(PROJECT_NAME, @"Please enter text", @"OK");
        return;
    }
    isPrivate = YES;
    [self createPost];
}
-(void)anonymousPostClicked:(id)sender
{
    [popover showAtView:sender withContentView:popView];

}
-(void)postClicked
{
    
    if(textView.text.length == 0)
    {
        ShowAlert(PROJECT_NAME, @"Please enter text", @"OK");
        return;
    }
    
    isPrivate = NO;
    [self createPost];
    
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
