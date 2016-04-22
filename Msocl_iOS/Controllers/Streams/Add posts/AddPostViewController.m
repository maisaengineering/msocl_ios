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
#import "FacebookShareController.h"
#import "UIImage+GIF.h"
#import "UIImage+animatedGIF.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "Flurry.h"
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
    UIView *addPopUpView;
    UIImageView *dropDown;
    NSMutableDictionary *editImageDict;
    CGRect originalFrame;
    CGSize keyboardSize;
    NSDictionary *editPostDetails;
}
@synthesize scrollView;
@synthesize postDetailsObject;
@synthesize delegate;
@synthesize selectedtagsArray;
@synthesize collectionView;
@synthesize timerHomepage;
@synthesize subContext;
@synthesize homeContext;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    
    [self getAllGroups];
    photoUtils = [ProfilePhotoUtils alloc];
    uploadingImages = 0;
    if(selectedtagsArray.count == 0)
        selectedtagsArray = [[NSMutableArray alloc] init];
    
    tagsArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"Groups"];
    
    NSSortDescriptor *brandDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:brandDescriptor];
    tagsArray = [tagsArray sortedArrayUsingDescriptors:sortDescriptors];

    
    
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
    [postButton setFrame:CGRectMake(237, 5, 50, 31)];
    [postButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [postButton setTitle:@"Post as" forState:UIControlStateNormal];
    [postButton.titleLabel setFont:[UIFont fontWithName:@"SanFranciscoText-Light" size:13]];
    [postButton setBackgroundImage:[UIImage imageNamed:@"btn-postas.png"] forState:UIControlStateNormal];
    
    
    anonymousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [anonymousButton setImage:[UIImage imageNamed:@"btn-post-ana.png"] forState:UIControlStateNormal];
    [anonymousButton addTarget:self action:@selector(anonymousPostClicked:) forControlEvents:UIControlEventTouchUpInside];
    [anonymousButton setFrame:CGRectMake(287, 5, 30, 31)];
    
    postAnonymous = [[UIImageView alloc] initWithFrame:CGRectMake(4, 2.5, 22, 22)];
    
    __weak UIImageView *weakSelf = postAnonymous;
    __weak ProfilePhotoUtils *weakphotoUtils = photoUtils;
    ModelManager *sharedModel = [ModelManager sharedModel];
    
    NSMutableString *parentFnameInitial = [[NSMutableString alloc] init];
    if( [sharedModel.userProfile.fname length] >0)
        [parentFnameInitial appendString:[[sharedModel.userProfile.fname substringToIndex:1] uppercaseString]];
    if( [sharedModel.userProfile.lname length] >0)
        [parentFnameInitial appendString:[[sharedModel.userProfile.lname substringToIndex:1] uppercaseString]];
    
    if(parentFnameInitial.length < 1)
    {
        if( [sharedModel.userProfile.handle length] >0)
            [parentFnameInitial appendString:[[sharedModel.userProfile.handle substringToIndex:1] uppercaseString]];
        if( [sharedModel.userProfile.handle length] >1)
            [parentFnameInitial appendString:[[sharedModel.userProfile.handle substringWithRange:NSMakeRange(1, 1)] uppercaseString]];
    }
    
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:parentFnameInitial
                                           attributes:nil];
    NSRange range;
    if(parentFnameInitial.length > 0)
    {
        range.location = 0;
        range.length = 1;
        [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:12]}
                                range:range];
    }
    if(parentFnameInitial.length > 1)
    {
        range.location = 1;
        range.length = 1;
        [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:12]}
                                range:range];
    }
    
    
    //add initials
    
    UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    initial.attributedText = attributedText;
    [initial setBackgroundColor:[UIColor clearColor]];
    initial.textAlignment = NSTextAlignmentCenter;
    [postAnonymous addSubview:initial];
    
    
    [postAnonymous setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:sharedModel.userProfile.image]] placeholderImage:[UIImage imageNamed:@"circle-80.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf.image = [weakphotoUtils makeRoundWithBoarder:[weakphotoUtils squareImageWithImage:image scaledToSize:CGSizeMake(18, 18)] withRadious:0];
         [initial  removeFromSuperview];
         
     }failure:nil];
    [anonymousButton addSubview:postAnonymous];
    
    dropDown = [[UIImageView alloc] initWithFrame:CGRectMake(302, 24, 10, 9)];
    [dropDown setImage:[UIImage imageNamed:@"btn-post-dropdown.png"]];
    
    
    [self.navigationController.navigationBar addSubview:postButton];
    [self.navigationController.navigationBar addSubview:anonymousButton];
    [self.navigationController.navigationBar addSubview:dropDown];
    
    
    imagesIdDict = [[NSMutableDictionary alloc] init];
    editImageDict = [[NSMutableDictionary alloc] init];
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
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self check];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: YES];
    
    if([[self  timerHomepage] isValid])
        [[self  timerHomepage] invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
}
#pragma mark -
#pragma mark Groups
-(void)getAllGroups
{
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    
    NSDictionary* postData = @{@"command": @"favourites",@"access_token": token.access_token};
    NSDictionary *userInfo = @{@"command": @"GetAllGroups"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@groups",BASE_URL];
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}
-(void)didReceiveGroups:(NSDictionary *)responseDict
{
    [[NSUserDefaults standardUserDefaults] setObject:[responseDict objectForKey:@"groups"] forKey:@"Groups"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]
                                  initWithSuiteName:@"group.com.maisasolutions.msocl"];
    [myDefaults setObject:[responseDict objectForKey:@"groups"] forKey:@"Groups"];
    [myDefaults synchronize];
    
    tagsArray = [responseDict objectForKey:@"groups"];
    
    NSSortDescriptor *brandDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:brandDescriptor];
    tagsArray = [tagsArray sortedArrayUsingDescriptors:sortDescriptors];

    [collectionView reloadData];
}
-(void)fetchingGroupsFailedWithError
{
    
}

-(void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardrect = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    float keyBoardY = scrollView.frame.size.height - keyboardrect.size.height;
    if(keyBoardY < textView.frame.origin.y+textView.frame.size.height)
    {
        CGRect frame = textView.frame;
        frame.size.height -= (textView.frame.origin.y+textView.frame.size.height - keyBoardY);
        textView.frame = frame;
    }
    
    
}
-(void)keyboardWillHide:(NSNotification *)notification
{
    keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    textView.frame = originalFrame;
}
-(void)backClicked
{
    [textView resignFirstResponder];
    [postButton removeFromSuperview];
    [postAnonymous removeFromSuperview];
    [anonymousButton removeFromSuperview];
    [dropDown removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(void)postDetailsScroll
{
    int height = Deviceheight-64;
    scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
    scrollView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    [self.view addSubview:scrollView];
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 300, 188)];
    [imageView setImage:[UIImage imageNamed:@"textfield.png"]];
    [scrollView addSubview:imageView];
    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(14,19,292, 140)];
    originalFrame = textView.frame;
    textView.font = [UIFont fontWithName:@"SanFranciscoText-Light" size:14];
    textView.delegate = self;
    textView.autocorrectionType = UITextAutocorrectionTypeYes;
    [scrollView addSubview:textView];
    
    placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 5, textView.frame.size.width, 20)];
    //[placeholderLabel setText:placeholder];
    [placeholderLabel setBackgroundColor:[UIColor clearColor]];
    [placeholderLabel setNumberOfLines:0];
    placeholderLabel.text = @"Write description";
    [placeholderLabel setTextAlignment:NSTextAlignmentLeft];
    [placeholderLabel setFont:[UIFont fontWithName:@"SanFranciscoText-LightItalic" size:14]];
    [placeholderLabel setTextColor:[UIColor lightGrayColor]];
    [textView addSubview:placeholderLabel];
    
    
    inputView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [inputView setBackgroundColor:[UIColor colorWithRed:0.56f
                                                  green:0.59f
                                                   blue:0.63f
                                                  alpha:1.0f]];
    
    UIButton *addPhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addPhotoBtn.frame = CGRectMake(15, 150+10, 38, 38);
    [addPhotoBtn setImage:[UIImage imageNamed:@"icon-camera-add.png"] forState:UIControlStateNormal];
    [addPhotoBtn addTarget:self action:@selector(AddPhoto) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:addPhotoBtn];
    
    
    UIButton *donebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [donebtn setFrame:CGRectMake(250, 0, 70, 40)];
    [donebtn setTitle:@"Done" forState:UIControlStateNormal];
    [donebtn.titleLabel setFont:[UIFont fontWithName:@"SanFranciscoText-Medium" size:15]];
    [donebtn addTarget:self action:@selector(doneClick:) forControlEvents:UIControlEventTouchUpInside];
    [inputView addSubview:donebtn];
    
    
    
    UILabel *selectTagslabel = [[UILabel alloc] initWithFrame:CGRectMake(10, imageView.frame.origin.y+imageView.frame.size.height+20, 200, 20)];
    [selectTagslabel setFont:[UIFont fontWithName:@"SanFranciscoText-Regular" size:15]];
    [selectTagslabel setTextColor:[UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1.0]];
    [selectTagslabel setText:@"Select tags"];
    [scrollView addSubview:selectTagslabel];
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 7;
    layout.minimumLineSpacing = 7;
    
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, selectTagslabel.frame.origin.y+selectTagslabel.frame.size.height+10, 300, height - selectTagslabel.frame.origin.y-selectTagslabel.frame.size.height - 15) collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.scrollEnabled = YES;
    collectionView.dataSource = self;
    [collectionView registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [collectionView setBackgroundColor:[UIColor clearColor]];
    [scrollView addSubview:collectionView];
    
    
}
-(void)setDetails
{
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setFrame:CGRectMake(287, 220, 23, 26)];
    [deleteButton setImage:[UIImage imageNamed:@"icon-delete-post.png"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:deleteButton];
    
    if(postDetailsObject.anonymous)
    {
        isPrivate = YES;
        postAnonymous.image = [UIImage imageNamed:@"anamous.png"];
        
        
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
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:postDetailsObject.content attributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14],NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]}];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\::(.*?)\\::" options:NSRegularExpressionCaseInsensitive error:NULL];
    
    
    do{
        
        NSArray *myArray = [regex matchesInString:attributedString.string options:0 range:NSMakeRange(0, [attributedString.string length])] ;
        if(myArray.count > 0)
        {
            NSTextCheckingResult *match =  [myArray firstObject];
            NSRange matchRange = [match rangeAtIndex:1];
            NSLog(@"%@", [attributedString.string substringWithRange:matchRange]);
            
            
            
            UIImage  *image = [photoUtils makeRoundedCornersWithBorder:[UIImage imageNamed:@"placeHolder_wall.png"] withRadious:3.0];
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
            
            NSMutableAttributedString *attrStringWithImage = [[NSAttributedString attributedStringWithAttachment:textAttachment] mutableCopy];
            [attrStringWithImage addAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14],NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]} range:NSMakeRange(0, attrStringWithImage.string.length)];
            
            
            [attributedString replaceCharactersInRange:match.range withAttributedString:attrStringWithImage];
            
        }
        
        else
        {
            break;
        }
        
    }while (1);
    
    textView.attributedText = attributedString;
    textView.typingAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14],NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]};
    selectedtagsArray = [postDetailsObject.tags mutableCopy];
    editImageDict = [imagesIdDict mutableCopy];
    [collectionView reloadData];
    
}

-(void)deleteButtonClicked
{
    UIAlertView *cautionAlert = [[UIAlertView alloc]initWithTitle:@"Are you sure you want to delete this post?" message:@"" delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel", nil];
    cautionAlert.tag = 1;
    [cautionAlert show];
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        if (buttonIndex == 0)
        {
            //Invalidate the timer
            if([[self  timerHomepage] isValid])
                [[self  timerHomepage] invalidate];
            
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
    [dropDown removeFromSuperview];
    
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
        [textView resignFirstResponder];
        
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
    [self processImageToUpload:image];
    [self UploadImage:image];
    
}

-(void)finishedEditingImage:(UIImage *)image
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //It used to identify the attched image when sending to srever
    
}

-(void)processImageToUpload:(UIImage *)image
{
    NSString *identifier = [NSString stringWithFormat:@"image%lu",(unsigned long)imagesIdDict.count+1];
    image.accessibilityIdentifier = identifier;
    
    image = [photoUtils imageWithImage:image scaledToSize:CGSizeMake(26, 16) withRadious:3.0];
    NSMutableAttributedString *attributedString = [textView.attributedText mutableCopy];
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    image.accessibilityIdentifier = identifier;
    textAttachment.image = image;
    
    //  textAttachment.image = [UIImage imageWithCGImage:textAttachment.image.CGImage scale:1 orientation:UIImageOrientationUp];
    
    
    
    NSRange selectedrange = textView.selectedRange;
    if(textView.text.length > textView.selectedRange.location)
    {
        NSMutableAttributedString *attrStringWithImage = [[NSAttributedString attributedStringWithAttachment:textAttachment] mutableCopy];
        [attrStringWithImage addAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14],NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]} range:NSMakeRange(0, attrStringWithImage.string.length)];
        
        if(attributedString.length >0 && ([attributedString.string characterAtIndex:attributedString.string.length-1] != '\n'))
            [attributedString insertAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14],NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]}] atIndex:selectedrange.location];
        [attributedString insertAttributedString:attrStringWithImage atIndex:selectedrange.location+1];
        [attributedString insertAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14],NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]}] atIndex:selectedrange.location+2];
        
    }
    else
    {
        NSMutableAttributedString *attrStringWithImage = [[NSAttributedString attributedStringWithAttachment:textAttachment] mutableCopy];
        [attrStringWithImage addAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14],NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]} range:NSMakeRange(0, attrStringWithImage.string.length)];
        
        if(attributedString.length >0 && ([attributedString.string characterAtIndex:attributedString.string.length-1] != '\n'))
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14],NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]}]];
        [attributedString appendAttributedString:attrStringWithImage];
        
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14],NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]}]];
        
    }
    [attributedString addAttributes:@{NSFontAttributeName:textView.font} range:NSMakeRange(0, attributedString.string.length)];
    
    [placeholderLabel removeFromSuperview];
    textView.attributedText = attributedString;
    textView.typingAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14],NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]};
    
    
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
                 if ([[assetURL absoluteString] rangeOfString:@"gif" options:NSCaseInsensitiveSearch].location != NSNotFound)
                     
                 {
                     ALAssetRepresentation *rep = [asset defaultRepresentation];
                     Byte *buffer = (Byte*)malloc((NSUInteger)rep.size);
                     NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:(NSUInteger)rep.size error:nil];
                     NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                     UIImage *image = [UIImage animatedImageWithAnimatedGIFData:data];
                     [self processImageToUpload:image];
                     [self UploadGIFImage:image withData:data];
                     
                     [appdelegate showOrhideIndicator:NO];
                 }
                 else
                 {
                     [self launchEditorWithAsset:asset];
                 }
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
-(void)UploadGIFImage:(UIImage *)imageOrg withData:(NSData *)imageData
{
    NSString *fileExtension = @"gif";
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
    retval.height= 95; retval.width = 95; return retval;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"cellIdentifier";
    
    PhotoCollectionViewCell* cell=[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(31.5, 21, 32, 32)];
    __weak UIImageView *weakSelf = imageView;
    UIImage *placeHolder  = [UIImage sd_animatedGIFNamed:@"Preloader_2"];
    
    [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[tagsArray objectAtIndex:indexPath.row] objectForKey:@"image"]]] placeholderImage:placeHolder success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf.frame = cell.bounds;
         weakSelf.image = [photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(95, 95)];
         
         
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
         
     }];
    
    [cell addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 75, 95, 20)];
    label.backgroundColor = [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1.0];
    [label setText:[[tagsArray objectAtIndex:indexPath.row] objectForKey:@"name"]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont fontWithName:@"SanFranciscoText-Light" size:12]];
    [label setTextColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0]];
    [cell addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"tag-tick-active.png"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(78, 3, 14, 14)];
    [cell addSubview:button];
    
    if([selectedtagsArray containsObject:[[tagsArray objectAtIndex:indexPath.row] objectForKey:@"name"]])
    {
        [button setImage:[UIImage imageNamed:@"tag-tick.png"] forState:UIControlStateNormal];
        [label setBackgroundColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0]];
        [label setTextColor:[UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0]];
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView1 didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([[self  timerHomepage] isValid])
        [[self  timerHomepage] invalidate];
    
    {
        NSMutableArray *timedReminderArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"PageGuidePopUpImages"];
        NSArray *array = [timedReminderArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"context = %@",@"addTag"]];
        homeContext = [[array firstObject] mutableCopy];
        if([[homeContext objectForKey:@"graphics"] count] >0 )
        {
            subContext = [[homeContext objectForKey:@"graphics"] firstObject];
            
            NSMutableArray *userDefaultsArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PageGuidePopUpImages"] mutableCopy];
            long int index = [userDefaultsArray indexOfObject:homeContext];
            NSMutableArray *graphicsArrray =  [[homeContext objectForKey:@"graphics"] mutableCopy];
            [graphicsArrray removeObject:subContext];
            [homeContext setObject:graphicsArrray forKey:@"graphics"];
            [userDefaultsArray replaceObjectAtIndex:index withObject:homeContext];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:userDefaultsArray forKey:@"PageGuidePopUpImages"];
            
            
            ////////////Saving already viewed uids in userdefaults
            NSMutableArray *visitedRemainders =  [[userDefaults objectForKey:@"time_reminder_visits"] mutableCopy];
            if(visitedRemainders.count >0 )
            {
                NSArray *contextArray  = [visitedRemainders filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"reminder_uid = %@",[homeContext objectForKey:@"uid"]]];
                if(contextArray.count >0)
                {
                    NSMutableDictionary *contextDict = [[contextArray firstObject] mutableCopy];
                    long int index = [visitedRemainders indexOfObject:contextDict];
                    NSMutableArray *graphicsArray = [[contextDict objectForKey:@"graphic_uids"] mutableCopy];
                    if(![graphicsArray containsObject:[subContext objectForKey:@"uid"]])
                    {
                        [graphicsArray addObject:[subContext objectForKey:@"uid"]];
                        [contextDict setObject:graphicsArray forKey:@"graphic_uids"];
                        [visitedRemainders replaceObjectAtIndex:index withObject:contextDict];
                        [userDefaults setObject:visitedRemainders forKey:@"time_reminder_visits"];
                    }
                    
                }
                else
                {
                    [visitedRemainders addObject:@{@"reminder_uid":[homeContext objectForKey:@"uid"],@"graphic_uids":[NSArray arrayWithObject:[subContext objectForKey:@"uid"]]}];
                    [userDefaults setObject:visitedRemainders forKey:@"time_reminder_visits"];
                    
                }
                
                
            }
            else
            {
                NSArray *visited_Remainders = [NSArray arrayWithObject:@{@"reminder_uid":[homeContext objectForKey:@"uid"],@"graphic_uids":[NSArray arrayWithObject:[subContext objectForKey:@"uid"]]}];
                [userDefaults setObject:visited_Remainders forKey:@"time_reminder_visits"];
                
            }
            
            [userDefaults synchronize];
            
            
            [self check];
            
        }
    }
    
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
    textView.typingAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14],NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]};
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
    textView.typingAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14],NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]};
    
    if(![textView1 hasText])
    {
        [textView1 addSubview:placeholderLabel];
    }
    else if ([[textView1 subviews] containsObject:placeholderLabel])
    {
        [placeholderLabel removeFromSuperview];
        
    }
    
}
- (BOOL)textView:(UITextView *)textView1 shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    NSMutableAttributedString *newAttrString = [textView1.attributedText mutableCopy];
    
    [newAttrString beginEditing];
    
    [newAttrString enumerateAttributesInRange:NSMakeRange(0, newAttrString.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:
     ^(NSDictionary *attributes, NSRange attrRange, BOOL *stop)
     {
         NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
         
         NSTextAttachment *textAttachment = [mutableAttributes objectForKey:@"NSAttachment"];
         if(textAttachment != nil && attrRange.location == range.location && attrRange.length == range.length)
         {
             NSString *identifier = textAttachment.image.accessibilityIdentifier;
             [imagesIdDict removeObjectForKey:identifier];
         }
         
     }];
    
    [newAttrString endEditing];
    
    return YES;
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
    for(UIView *viw in [postAnonymous subviews])
    {
        [viw removeFromSuperview];
    }
    
    
    [popover dismiss];
    postAnonymous.image = [UIImage imageNamed:@"anamous.png"];
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
    //Invalidate the timer
    if([[self  timerHomepage] isValid])
        [[self  timerHomepage] invalidate];
    
    {
        NSMutableArray *timedReminderArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"PageGuidePopUpImages"];
        NSArray *array = [timedReminderArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"context = %@",@"anonymousPost"]];
        homeContext = [[array firstObject] mutableCopy];
        if([[homeContext objectForKey:@"graphics"] count] >0 )
        {
            subContext = [[homeContext objectForKey:@"graphics"] firstObject];
            
            NSMutableArray *userDefaultsArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PageGuidePopUpImages"] mutableCopy];
            long int index = [userDefaultsArray indexOfObject:homeContext];
            NSMutableArray *graphicsArrray =  [[homeContext objectForKey:@"graphics"] mutableCopy];
            [graphicsArrray removeObject:subContext];
            [homeContext setObject:graphicsArrray forKey:@"graphics"];
            [userDefaultsArray replaceObjectAtIndex:index withObject:homeContext];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:userDefaultsArray forKey:@"PageGuidePopUpImages"];
            
            
            ////////////Saving already viewed uids in userdefaults
            NSMutableArray *visitedRemainders =  [[userDefaults objectForKey:@"time_reminder_visits"] mutableCopy];
            if(visitedRemainders.count >0 )
            {
                NSArray *contextArray  = [visitedRemainders filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"reminder_uid = %@",[homeContext objectForKey:@"uid"]]];
                if(contextArray.count >0)
                {
                    NSMutableDictionary *contextDict = [[contextArray firstObject] mutableCopy];
                    long int index = [visitedRemainders indexOfObject:contextDict];
                    NSMutableArray *graphicsArray = [[contextDict objectForKey:@"graphic_uids"] mutableCopy];
                    if(![graphicsArray containsObject:[subContext objectForKey:@"uid"]])
                    {
                        [graphicsArray addObject:[subContext objectForKey:@"uid"]];
                        [contextDict setObject:graphicsArray forKey:@"graphic_uids"];
                        [visitedRemainders replaceObjectAtIndex:index withObject:contextDict];
                        [userDefaults setObject:visitedRemainders forKey:@"time_reminder_visits"];
                    }
                    
                }
                else
                {
                    [visitedRemainders addObject:@{@"reminder_uid":[homeContext objectForKey:@"uid"],@"graphic_uids":[NSArray arrayWithObject:[subContext objectForKey:@"uid"]]}];
                    [userDefaults setObject:visitedRemainders forKey:@"time_reminder_visits"];
                    
                }
                
                
            }
            else
            {
                NSArray *visited_Remainders = [NSArray arrayWithObject:@{@"reminder_uid":[homeContext objectForKey:@"uid"],@"graphic_uids":[NSArray arrayWithObject:[subContext objectForKey:@"uid"]]}];
                [userDefaults setObject:visited_Remainders forKey:@"time_reminder_visits"];
                
            }
            
            [userDefaults synchronize];
            
            
            [self check];
            
        }
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = [(UIButton *)sender frame];
    frame.origin.y += 20;
    btn.frame = frame;
    
    popView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    
    if(!isPrivate)
    {
        
        UILabel *postAsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 260, 40)];
        [postAsLabel setText:@"Post as anonymous"];
        [postAsLabel setTextAlignment:NSTextAlignmentCenter];
        [postAsLabel setTextColor:[UIColor colorWithRed:76/255.0 green:121/255.0 blue:251/255.0 alpha:1.0]];
        [postAsLabel setFont:[UIFont fontWithName:@"SanFranciscoText-Light" size:16]];
        [popView addSubview:postAsLabel];
        
        UIImageView *anonymusImage = [[UIImageView alloc] initWithFrame:CGRectMake(210, 5, 30, 30)];
        [anonymusImage setImage:[UIImage imageNamed:@"anamous.png"]];
        [popView addSubview:anonymusImage];
        
        UIButton *postBtnAnonymous = [UIButton buttonWithType:UIButtonTypeCustom];
        postBtnAnonymous.frame = CGRectMake(0, 0, 300, 40);
        [postBtnAnonymous addTarget:self action:@selector(postAsAnonymous) forControlEvents:UIControlEventTouchUpInside];
        [popView addSubview:postBtnAnonymous];
        
    }
    else
    {
        ModelManager *sharedModel = [ModelManager sharedModel];
        
        
        UILabel *postAsLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        [postAsLabel1 setText:[NSString stringWithFormat:@"Post as %@ %@",sharedModel.userProfile.fname,sharedModel.userProfile.lname]];
        [postAsLabel1 setTextAlignment:NSTextAlignmentRight];
        [postAsLabel1 setTextColor:[UIColor colorWithRed:76/255.0 green:121/255.0 blue:251/255.0 alpha:1.0]];
        [postAsLabel1 setFont:[UIFont fontWithName:@"SanFranciscoText-Light" size:14]];
        [popView addSubview:postAsLabel1];
        if(sharedModel.userProfile.fname.length < 1 && sharedModel.userProfile.lname.length < 1)
            postAsLabel1.text = [NSString stringWithFormat:@"Post as %@",sharedModel.userProfile.handle];
        
        UIImageView *userImage = [[UIImageView alloc] initWithFrame:CGRectMake(210, 7, 24, 24)];
        
        
        NSMutableString *parentFnameInitial = [[NSMutableString alloc] init];
        if( [sharedModel.userProfile.fname length] >0)
            [parentFnameInitial appendString:[[sharedModel.userProfile.fname substringToIndex:1] uppercaseString]];
        if( [sharedModel.userProfile.lname length] >0)
            [parentFnameInitial appendString:[[sharedModel.userProfile.lname substringToIndex:1] uppercaseString]];
        
        if(parentFnameInitial.length < 1)
        {
            if( [sharedModel.userProfile.handle length] >0)
                [parentFnameInitial appendString:[[sharedModel.userProfile.handle substringToIndex:1] uppercaseString]];
            if( [sharedModel.userProfile.handle length] >1)
                [parentFnameInitial appendString:[[sharedModel.userProfile.handle substringWithRange:NSMakeRange(1, 1)] uppercaseString]];
        }
        
        NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:parentFnameInitial
                                               attributes:nil];
        NSRange range;
        if(parentFnameInitial.length > 0)
        {
            range.location = 0;
            range.length = 1;
            [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:14]}
                                    range:range];
        }
        if(parentFnameInitial.length > 1)
        {
            range.location = 1;
            range.length = 1;
            [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:14]}
                                    range:range];
        }
        
        
        //add initials
        
        UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        initial.attributedText = attributedText;
        [initial setBackgroundColor:[UIColor clearColor]];
        initial.textAlignment = NSTextAlignmentCenter;
        [userImage addSubview:initial];
        
        
        __weak UIImageView *weakSelf1 = userImage;
        __weak ProfilePhotoUtils *weakphotoUtils1 = photoUtils;
        
        [userImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:sharedModel.userProfile.image]] placeholderImage:[UIImage imageNamed:@"circle-80.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             weakSelf1.image = [weakphotoUtils1 makeRoundWithBoarder:[weakphotoUtils1 squareImageWithImage:image scaledToSize:CGSizeMake(24, 24)] withRadious:0];
             [initial removeFromSuperview];
             
         }failure:nil];
        
        
        [popView addSubview:userImage];
        
        UIButton *postBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        postBtn.frame = CGRectMake(0, 0, 300, 40);
        [postBtn addTarget:self action:@selector(postClicked) forControlEvents:UIControlEventTouchUpInside];
        [popView addSubview:postBtn];
        
    }
    
    
    //[popover showAtView:btn withContentView:popView];
    [popover showAtView:btn withContentView:popView inView:self.navigationController.view];
    
}
-(void)postClicked
{
    [popover dismiss];
    
    
    __weak UIImageView *weakSelf = postAnonymous;
    __weak ProfilePhotoUtils *weakphotoUtils = photoUtils;
    ModelManager *sharedModel = [ModelManager sharedModel];
    
    NSMutableString *parentFnameInitial = [[NSMutableString alloc] init];
    if( [sharedModel.userProfile.fname length] >0)
        [parentFnameInitial appendString:[[sharedModel.userProfile.fname substringToIndex:1] uppercaseString]];
    if( [sharedModel.userProfile.lname length] >0)
        [parentFnameInitial appendString:[[sharedModel.userProfile.lname substringToIndex:1] uppercaseString]];
    
    if(parentFnameInitial.length < 1)
    {
        if( [sharedModel.userProfile.handle length] >0)
            [parentFnameInitial appendString:[[sharedModel.userProfile.handle substringToIndex:1] uppercaseString]];
        if( [sharedModel.userProfile.handle length] >1)
            [parentFnameInitial appendString:[[sharedModel.userProfile.handle substringWithRange:NSMakeRange(1, 1)] uppercaseString]];
    }
    
    
    
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:parentFnameInitial
                                           attributes:nil];
    NSRange range;
    if(parentFnameInitial.length > 0)
    {
        range.location = 0;
        range.length = 1;
        [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:12]}
                                range:range];
    }
    if(parentFnameInitial.length > 1)
    {
        range.location = 1;
        range.length = 1;
        [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:12]}
                                range:range];
    }
    
    
    //add initials
    
    UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    initial.attributedText = attributedText;
    [initial setBackgroundColor:[UIColor clearColor]];
    initial.textAlignment = NSTextAlignmentCenter;
    [postAnonymous addSubview:initial];
    
    
    [postAnonymous setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:sharedModel.userProfile.image]] placeholderImage:[UIImage imageNamed:@"circle-80.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf.image = [weakphotoUtils makeRoundWithBoarder:[weakphotoUtils squareImageWithImage:image scaledToSize:CGSizeMake(18, 18)] withRadious:0];
         [initial removeFromSuperview];
         
     }failure:nil];
    isPrivate = NO;
    
}
-(void)createPost
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
    //Invalidate the timer
    if([[self  timerHomepage] isValid])
        [[self  timerHomepage] invalidate];
    
    
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
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"share"];
    if(dict != nil)
    {
        if([[dict objectForKey:@"fb"] boolValue])
        {
            [self shareToFB:[notificationDict objectForKey:@"url"]];
        }
    }
    
    [appdelegate showOrhideIndicator:NO];
    isPostClicked = NO;
    postButton.enabled = YES;
    
    [postButton removeFromSuperview];
    [anonymousButton removeFromSuperview];
    [postAnonymous removeFromSuperview];
    [dropDown removeFromSuperview];
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
-(void)editPost
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
    
    //Invalidate the timer
    if([[self  timerHomepage] isValid])
        [[self  timerHomepage] invalidate];
    
    
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
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(NSString *str in [imagesIdDict allValues] )
    {
        if(![[editImageDict allValues] containsObject:str])
            [array addObject:str];
    }
    
    
    //Image Ids
    if([array count] > 0)
    {
        [postDetails setObject:array forKey:@"img_keys"];
    }
    
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    
    NSString *command = @"update";
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": command,
                               @"body": postDetails};
    NSDictionary *userInfo = @{@"command": @"updatePost"};
    NSString *urlAsString = [NSString stringWithFormat:@"%@posts/%@",BASE_URL,postDetailsObject.uid];
    
    editPostDetails = [NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData", urlAsString,@"urlString",nil];
    
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}
-(void) updatePostSccessfull:(PostDetails *)postDetails
{
    [appdelegate showOrhideIndicator:NO];
    isPostClicked = NO;
    postButton.enabled = YES;
    
    [postButton removeFromSuperview];
    [anonymousButton removeFromSuperview];
    [dropDown removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate PostEdited:postDetails];
    
}
-(void) updatePostFailed:(NSDictionary *)dict
{
    [appdelegate showOrhideIndicator:NO];
    
    isPostClicked = NO;
    postButton.enabled = YES;
    
    [Flurry logEvent:@"EditPostFailed" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:editPostDetails,@"datils",dict,@"responseFromApi", nil]];
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

#pragma mark -
#pragma mark Timed Reminders
-(void)check
{
    NSMutableArray *timedReminderArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"PageGuidePopUpImages"];
    NSArray *array = [timedReminderArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"context = %@",@"addTag"]];
    if(array.count > 0)
    {
        homeContext = [[array firstObject] mutableCopy];
        NSDictionary *dictionary = [array firstObject];
        NSArray *graphicsArray = [dictionary objectForKey:@"graphics"];
        if(graphicsArray.count > 0)
        {
            
            subContext = [graphicsArray firstObject];
            [self setUpTimerWithStartInSubContext:subContext];
            
            return;
        }
    }
    array = [timedReminderArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"context = %@",@"anonymousPost"]];
    if(array.count > 0)
    {
        homeContext = [[array firstObject] mutableCopy];
        NSDictionary *dictionary = [array firstObject];
        NSArray *graphicsArray = [dictionary objectForKey:@"graphics"];
        if(graphicsArray.count > 0)
        {
            
            subContext = [graphicsArray firstObject];
            [self setUpTimerWithStartInSubContext:subContext];
            
            return;
        }
    }
    
    
}
-(void)setUpTimerWithStartInSubContext:(NSMutableDictionary *)subContext1
{
    NSTimeInterval timeInterval = [[subContext1 valueForKey:@"start"] doubleValue];
    
    if (!timerHomepage) {
        
        timerHomepage = [NSTimer scheduledTimerWithTimeInterval: timeInterval
                                                         target: self
                                                       selector: @selector(displayPromptForNewKidWhenStreamDataEmpty)
                                                       userInfo: nil
                                                        repeats: NO];
    }
    else
    {
        
        [timerHomepage invalidate];
        timerHomepage = nil;
        timerHomepage = [NSTimer scheduledTimerWithTimeInterval: timeInterval
                                                         target: self
                                                       selector: @selector(displayPromptForNewKidWhenStreamDataEmpty)
                                                       userInfo: nil
                                                        repeats: NO];
    }
}
/// Display the pop up
-(void)displayPromptForNewKidWhenStreamDataEmpty
{
    [textView resignFirstResponder];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    addPopUpView = [[UIView alloc] initWithFrame:CGRectMake(0,0,screenWidth,screenHeight)];
    [addPopUpView setBackgroundColor:[UIColor clearColor]];
    
    
    //MARK:POP Up image
    UIImageView *popUpContent = [[UIImageView alloc] init];
    [popUpContent setFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    
    NSString *imageURL = [subContext objectForKey:@"asset"];
    UIImage *thumb;
    if (imageURL.length >0)
    {
        photoUtils = [ProfilePhotoUtils alloc];
        thumb = [photoUtils getImageFromCache:imageURL];
        
        if (thumb == nil)
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^(void)
                           {
                               NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
                               UIImage* image = [[UIImage alloc] initWithData:imageData];
                               if (image) {
                                   [photoUtils saveImageToCache:imageURL :image];
                                   
                               }
                           });
        }
        else
        {
            [popUpContent setImage:thumb];
        }
    }
    else
    {
        //[popUpContent setImage:[UIImage imageNamed:@"New_Child_Stream_Empty.png"]];
    }
    [popUpContent setImage:thumb];
    
    [addPopUpView addSubview:popUpContent];
    
    // MARK:Got it button
    UIButton *gotItButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [gotItButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    gotItButton.frame = CGRectMake(110, 432, 100, 40);
    gotItButton.tag = 1;
    [addPopUpView addSubview:gotItButton];
    
    if (thumb)
    {
        addPopUpView.frame = CGRectMake(0,-screenHeight,screenWidth,screenHeight);
        
        [[[[UIApplication sharedApplication] delegate] window] addSubview:addPopUpView];
        
        
        [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            addPopUpView.frame = CGRectMake(0,0,screenWidth,screenHeight);
            
        }
                         completion:^(BOOL finished){
                             
                         }
         ];
        
        
        
    }
    
}
- (void)buttonClicked:(UIButton *)sender
{
    //
    [addPopUpView removeFromSuperview];
    
    NSMutableArray *userDefaultsArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PageGuidePopUpImages"] mutableCopy];
    long int index = [userDefaultsArray indexOfObject:homeContext];
    NSMutableArray *graphicsArrray =  [[homeContext objectForKey:@"graphics"] mutableCopy];
    [graphicsArrray removeObject:subContext];
    [homeContext setObject:graphicsArrray forKey:@"graphics"];
    [userDefaultsArray replaceObjectAtIndex:index withObject:homeContext];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userDefaultsArray forKey:@"PageGuidePopUpImages"];
    
    
    ////////////Saving already viewed uids in userdefaults
    NSMutableArray *visitedRemainders =  [[userDefaults objectForKey:@"time_reminder_visits"] mutableCopy];
    if(visitedRemainders.count >0 )
    {
        NSArray *contextArray  = [visitedRemainders filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"reminder_uid = %@",[homeContext objectForKey:@"uid"]]];
        if(contextArray.count >0)
        {
            NSMutableDictionary *contextDict = [[contextArray firstObject] mutableCopy];
            long int index = [visitedRemainders indexOfObject:contextDict];
            NSMutableArray *graphicsArray = [[contextDict objectForKey:@"graphic_uids"] mutableCopy];
            [graphicsArray addObject:[subContext objectForKey:@"uid"]];
            [contextDict setObject:graphicsArray forKey:@"graphic_uids"];
            [visitedRemainders replaceObjectAtIndex:index withObject:contextDict];
            [userDefaults setObject:visitedRemainders forKey:@"time_reminder_visits"];
            
        }
        else
        {
            [visitedRemainders addObject:@{@"reminder_uid":[homeContext objectForKey:@"uid"],@"graphic_uids":[NSArray arrayWithObject:[subContext objectForKey:@"uid"]]}];
            [userDefaults setObject:visitedRemainders forKey:@"time_reminder_visits"];
            
        }
        
        
    }
    else
    {
        NSArray *visited_Remainders = [NSArray arrayWithObject:@{@"reminder_uid":[homeContext objectForKey:@"uid"],@"graphic_uids":[NSArray arrayWithObject:[subContext objectForKey:@"uid"]]}];
        [userDefaults setObject:visited_Remainders forKey:@"time_reminder_visits"];
        
    }
    
    [userDefaults synchronize];
    
    
    [self check];
    
    
}
#pragma mark -
#pragma mark Share Methods
-(void)shareToFB:(NSString *)url
{
    FacebookShareController *fbc = [[FacebookShareController alloc] init];
    fbc.postedConfirmationDelegate = self;
    [fbc PostToFacebookViaAPI:url:@"":@"":@"story"];
    
}

@end
