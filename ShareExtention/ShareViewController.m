//
//  ShareViewController.m
//  ShareExtention
//
//  Created by Maisa Solutions on 7/1/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "ShareViewController.h"
#import "StringConstants.h"
#import "Base64.h"
#import "DXPopover.h"
#import "SDWebImageManager.h"
#import "PhotoCollectionViewCell.h"
#import "ProfilePhotoUtils.h"
#import "ModelManager.h"
#include <CoreFoundation/CoreFoundation.h>
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"
#import "UIImage+GIF.h"
@interface ShareViewController ()

@end

@implementation ShareViewController
{
    
    BOOL isPostClicked;
    ProfilePhotoUtils  *photoUtils;
    NSMutableDictionary *imagesIdDict;
    int uploadingImages;
    NSArray *tagsArray;
    UIView *inputView;
    UIButton *postButton;
    BOOL isPrivate;
    DXPopover *popover;
    UIView *popView;
    UILabel *placeholderLabel;
    UIButton *anonymousButton;
    UIImageView *postAnonymous;
    UIView *addPopUpView;
    UIImageView *dropDown;
    NSMutableDictionary *editImageDict;
    UIImageView *iconImage;
    SDWebImageManager *manager;
    NSDictionary *tokenDict;
    NSDictionary *userDict;
}
@synthesize scrollView;
@synthesize selectedtagsArray;
@synthesize collectionView;
@synthesize textView;

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    
   
   
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor whiteColor], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"SanFranciscoDisplay-Regular" size:18], NSFontAttributeName, nil]];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:197/255.0 green:33/255.0 blue:40/255.0 alpha:1.0]];
    [self.navigationController setToolbarHidden:YES];
    
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    
    
    
    
    photoUtils = [ProfilePhotoUtils alloc];
    uploadingImages = 0;
    if(selectedtagsArray.count == 0)
        selectedtagsArray = [[NSMutableArray alloc] init];
    
    
    
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]
                                  initWithSuiteName:@"group.com.maisasolutions.msocl"];
    tagsArray = [myDefaults objectForKey:@"Groups"];

    tokenDict = [myDefaults objectForKey:@"tokens"];
    userDict = [myDefaults objectForKey:@"userprofile"];

    
    popover = [DXPopover popover];
    
    
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelClick:)];
    self.navigationItem.leftBarButtonItem = barButton;
    
    
    postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [postButton addTarget:self action:@selector(createPost) forControlEvents:UIControlEventTouchUpInside];
    [postButton setFrame:CGRectMake(Devicewidth-80-10, 5, 50, 31)];
    [postButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [postButton setTitle:@"Post as" forState:UIControlStateNormal];
    [postButton.titleLabel setFont:[UIFont fontWithName:@"SanFranciscoText-Light" size:13]];
    [postButton setBackgroundImage:[UIImage imageNamed:@"btn-postas.png"] forState:UIControlStateNormal];
    
    
    anonymousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [anonymousButton setImage:[UIImage imageNamed:@"btn-post-ana.png"] forState:UIControlStateNormal];
    [anonymousButton addTarget:self action:@selector(anonymousPostClicked:) forControlEvents:UIControlEventTouchUpInside];
    [anonymousButton setFrame:CGRectMake(Devicewidth-80-10+50, 5, 30, 31)];
    
    postAnonymous = [[UIImageView alloc] initWithFrame:CGRectMake(4, 2.5, 22, 22)];
    
    __weak UIImageView *weakSelf = postAnonymous;
    __weak ProfilePhotoUtils *weakphotoUtils = photoUtils;
    
    NSMutableString *parentFnameInitial = [[NSMutableString alloc] init];
    if( [[userDict objectForKey:@"fname"] length] >0)
        [parentFnameInitial appendString:[[[userDict objectForKey:@"fname"] substringToIndex:1] uppercaseString]];
    if( [[userDict objectForKey:@"lname"] length] >0)
        [parentFnameInitial appendString:[[[userDict objectForKey:@"lname"] substringToIndex:1] uppercaseString]];
    
    if(parentFnameInitial.length < 1)
    {
        if( [[userDict valueForKey:@"pinch_handle"] length] >0)
            [parentFnameInitial appendString:[[[userDict valueForKey:@"pinch_handle"] substringToIndex:1] uppercaseString]];
        if( [[userDict valueForKey:@"pinch_handle"] length] >1)
            [parentFnameInitial appendString:[[[userDict valueForKey:@"pinch_handle"] substringWithRange:NSMakeRange(1, 1)] uppercaseString]];
        
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
    
    postAnonymous.image = [UIImage imageNamed:@"circle-80.png"];
    
        if([userDict objectForKey:@"photo"] != nil)
        {
            UIImage *thumb = [photoUtils getImageFromCache:[userDict objectForKey:@"photo"]];

    if (thumb == nil)
    {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^(void)
                       {
                           NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[userDict objectForKey:@"photo"]]];
                           UIImage* image = [[UIImage alloc] initWithData:imageData];
                           if (image) {
                               

                               weakSelf.image = [weakphotoUtils makeRoundWithBoarder:[weakphotoUtils squareImageWithImage:image scaledToSize:CGSizeMake(18, 18)] withRadious:0];
                               [initial  removeFromSuperview];
                               [photoUtils saveImageToCacheWithOutCompression:[userDict objectForKey:@"photo"] :weakSelf.image];
                           }
                       });
    }
    else
    {
        weakSelf.image = thumb;
        [initial  removeFromSuperview];
    }
        }
    
    [anonymousButton addSubview:postAnonymous];
    
    dropDown = [[UIImageView alloc] initWithFrame:CGRectMake(Devicewidth-80-10+50+15, 24, 10, 9)];
    [dropDown setImage:[UIImage imageNamed:@"btn-post-dropdown.png"]];
    
    
    [self.navigationController.navigationBar addSubview:postButton];
    [self.navigationController.navigationBar addSubview:anonymousButton];
    [self.navigationController.navigationBar addSubview:dropDown];
    
    
    imagesIdDict = [[NSMutableDictionary alloc] init];
    editImageDict = [[NSMutableDictionary alloc] init];
    [self postDetailsScroll];
    
    
    if(selectedtagsArray.count > 0)
        [collectionView reloadData];

    iconImage = [[UIImageView alloc] initWithFrame:CGRectMake((Devicewidth-47)/2, 8, 47, 28)];
    [iconImage setImage:[UIImage imageNamed:@"header-icon-samepinch.png"]];
    [self.navigationController.navigationBar addSubview:iconImage];
    if(tokenDict != nil)
    [self setData];
    [self setNeedsStatusBarAppearanceUpdate];
    

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.preferredContentSize= CGSizeMake(320,568);
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    if(tokenDict == nil)
    {
        if ([UIAlertController class]) {
            UIAlertController *alertController =[UIAlertController alertControllerWithTitle:PROJECT_NAME message:@"Please login to main app" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [self.extensionContext cancelRequestWithError:nil];
                                           NSLog(@"OK action");
                                       }];
            
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
    }
}
-(void)postDetailsScroll
{
    int height = Deviceheight;
    int width = Devicewidth;
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    scrollView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    [self.view addSubview:scrollView];
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, width-20, 188)];
    [imageView setImage:[UIImage imageNamed:@"textfield.png"]];
    [scrollView addSubview:imageView];
    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(14,19,width-28, 140)];
    textView.font = [UIFont fontWithName:@"SanFranciscoText-Light" size:14];
    textView.delegate = self;
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    [scrollView addSubview:textView];
    
    inputView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 40)];
    [inputView setBackgroundColor:[UIColor colorWithRed:0.56f
                                                  green:0.59f
                                                   blue:0.63f
                                                  alpha:1.0f]];
    
    UIButton *donebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [donebtn setFrame:CGRectMake(width-70, 0, 70, 40)];
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
    
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, selectTagslabel.frame.origin.y+selectTagslabel.frame.size.height+10, width-20, height - selectTagslabel.frame.origin.y-selectTagslabel.frame.size.height - 15-64) collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.scrollEnabled = YES;
    collectionView.dataSource = self;
    [collectionView registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [collectionView setBackgroundColor:[UIColor clearColor]];
    [scrollView addSubview:collectionView];
    
    
}

-(void)setData
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
    for (NSItemProvider* itemProvider in ((NSExtensionItem*)self.extensionContext.inputItems[0]).attachments )
    {
        if([itemProvider hasItemConformingToTypeIdentifier:@"public.image"])
        {
            [itemProvider loadItemForTypeIdentifier:@"public.image" options:nil completionHandler:
             ^(id<NSSecureCoding> item, NSError *error)
             {
                 UIImage *sharedImage = nil;
                 if([(NSObject*)item isKindOfClass:[NSURL class]])
                 {
                     
                     sharedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:(NSURL*)item]];
                 }
                 if([(NSObject*)item isKindOfClass:[UIImage class]])
                 {
                     sharedImage = (UIImage*)item;
                 }
                 
                 //It used to identify the attched image when sending to srever
                 NSString *identifier = [NSString stringWithFormat:@"image%lu",(unsigned long)imagesIdDict.count+1];
                 sharedImage.accessibilityIdentifier = identifier;
                 [self UploadImage:sharedImage];

                 NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                 
                 sharedImage = [photoUtils imageWithImage:sharedImage scaledToSize:CGSizeMake(32, 32) withRadious:3.0];
                 sharedImage.accessibilityIdentifier = identifier;
                 textAttachment.image = sharedImage;
                 NSMutableAttributedString *attrStringWithImage = [[NSAttributedString attributedStringWithAttachment:textAttachment] mutableCopy];
                 [attrStringWithImage addAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14],NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]} range:NSMakeRange(0, attrStringWithImage.string.length)];
                 [attrString appendAttributedString:attrStringWithImage];
                 
                 [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:5],NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]}]];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     textView.attributedText = attrString;
                 });

                 [imagesIdDict setObject:@"" forKey:identifier];
                 uploadingImages ++;

             }];
        }
        else if ([itemProvider hasItemConformingToTypeIdentifier:@"public.url"]) {
            [itemProvider loadItemForTypeIdentifier:@"public.url" options:nil completionHandler:^(NSURL *url, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    textView.attributedText = [[NSAttributedString alloc] initWithString:url.absoluteString attributes:@{NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Light" size:14],NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]}];
                });
            }];
        }

    }
    

}
- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}
-(IBAction)cancelClick:(id)sender
{
    [self.extensionContext cancelRequestWithError:nil];

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
    
    cell.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(31.5, 21, 32, 32)];
    __weak UIImageView *weakSelf = imageView;
    UIImage *placeHolder  = [UIImage sd_animatedGIFNamed:@"Preloader_2"];
    
    imageView.image = placeHolder;
    
        if([[tagsArray objectAtIndex:indexPath.row] objectForKey:@"image"] != nil)
        {
            UIImage *thumb = [photoUtils getImageFromCache:[[tagsArray objectAtIndex:indexPath.row] objectForKey:@"image"]];

    if (thumb == nil)
    {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^(void)
                       {
                           NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[tagsArray objectAtIndex:indexPath.row] objectForKey:@"image"]]];
                           UIImage* image = [[UIImage alloc] initWithData:imageData];
                           if (image) {
                               weakSelf.frame = cell.bounds;
                               weakSelf.image = image;
                               [photoUtils saveImageToCacheWithOutCompression:[[tagsArray objectAtIndex:indexPath.row] objectForKey:@"image"] :image];

                           }
                       });
    }
    else
    {
        weakSelf.frame = cell.bounds;

        weakSelf.image = thumb;
    }

    
        }

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
        
        
        UILabel *postAsLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        [postAsLabel1 setText:[NSString stringWithFormat:@"Post as %@ %@",[userDict objectForKey:@"fname"],[userDict objectForKey:@"lname"]]];
        [postAsLabel1 setTextAlignment:NSTextAlignmentRight];
        [postAsLabel1 setTextColor:[UIColor colorWithRed:76/255.0 green:121/255.0 blue:251/255.0 alpha:1.0]];
        [postAsLabel1 setFont:[UIFont fontWithName:@"SanFranciscoText-Light" size:14]];
        [popView addSubview:postAsLabel1];
        if(postAsLabel1.text.length  <1)
        {
            [postAsLabel1 setText:[NSString stringWithFormat:@"Post as %@",[userDict objectForKey:@"pinch_handle"]]];

        }
        UIImageView *userImage = [[UIImageView alloc] initWithFrame:CGRectMake(210, 7, 24, 24)];
        
        
        NSMutableString *parentFnameInitial = [[NSMutableString alloc] init];
        if( [[userDict objectForKey:@"fname"] length] >0)
            [parentFnameInitial appendString:[[[userDict objectForKey:@"fname"] substringToIndex:1] uppercaseString]];
        if( [[userDict objectForKey:@"lname"] length] >0)
            [parentFnameInitial appendString:[[[userDict objectForKey:@"lname"] substringToIndex:1] uppercaseString]];
        
        if(parentFnameInitial.length < 1)
        {
            if( [[userDict valueForKey:@"pinch_handle"] length] >0)
                [parentFnameInitial appendString:[[[userDict valueForKey:@"pinch_handle"] substringToIndex:1] uppercaseString]];
            if( [[userDict valueForKey:@"pinch_handle"] length] >1)
                [parentFnameInitial appendString:[[[userDict valueForKey:@"pinch_handle"] substringWithRange:NSMakeRange(1, 1)] uppercaseString]];
            
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
        
        postAnonymous.image = [UIImage imageNamed:@"circle-80.png"];
        
            if([userDict objectForKey:@"photo"] != nil)
            {
                UIImage *thumb = [photoUtils getImageFromCache:[userDict objectForKey:@"photo"]];

        if (thumb == nil)
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^(void)
                           {
                               NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[userDict objectForKey:@"photo"]]];
                               UIImage* image = [[UIImage alloc] initWithData:imageData];
                               if (image) {
                                   weakSelf1.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(24, 24)] withRadious:0];
                                   [initial  removeFromSuperview];
                                   [photoUtils saveImageToCacheWithOutCompression:[userDict objectForKey:@"photo"] :weakSelf1.image];
                                   
                               }
                           });
        }
        else
        {
            weakSelf1.image = thumb;
            [initial  removeFromSuperview];
        }
        
            }
        [popView addSubview:userImage];
        
        UIButton *postBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        postBtn.frame = CGRectMake(0, 0, 300, 40);
        [postBtn addTarget:self action:@selector(postClicked) forControlEvents:UIControlEventTouchUpInside];
        [popView addSubview:postBtn];
        
    }
    
    
   // [popover showAtView:btn withContentView:popView];
    [popover showAtView:btn withContentView:popView inView:self.navigationController.view];
    
}
-(void)postClicked
{
    [popover dismiss];
    
    
    __weak UIImageView *weakSelf = postAnonymous;
    __weak ProfilePhotoUtils *weakphotoUtils = photoUtils;
    
    NSMutableString *parentFnameInitial = [[NSMutableString alloc] init];
    if( [[userDict objectForKey:@"fname"] length] >0)
        [parentFnameInitial appendString:[[[userDict objectForKey:@"fname"] substringToIndex:1] uppercaseString]];
    if( [[userDict objectForKey:@"lname"] length] >0)
        [parentFnameInitial appendString:[[[userDict objectForKey:@"lname"] substringToIndex:1] uppercaseString]];
    
    if(parentFnameInitial.length < 1)
    {
        if( [[userDict valueForKey:@"pinch_handle"] length] >0)
            [parentFnameInitial appendString:[[[userDict valueForKey:@"pinch_handle"] substringToIndex:1] uppercaseString]];
        if( [[userDict valueForKey:@"pinch_handle"] length] >1)
            [parentFnameInitial appendString:[[[userDict valueForKey:@"pinch_handle"] substringWithRange:NSMakeRange(1, 1)] uppercaseString]];
        
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
    
    
    postAnonymous.image = [UIImage imageNamed:@"circle-80.png"];
    manager = [SDWebImageManager sharedManager];
    if([userDict objectForKey:@"photo"] != nil)
    {
        UIImage *thumb = [photoUtils getImageFromCache:[userDict objectForKey:@"photo"]];

    if (thumb == nil)
    {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^(void)
                       {
                           NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[userDict objectForKey:@"photo"]]];
                           UIImage* image = [[UIImage alloc] initWithData:imageData];
                           if (image) {
                               {
                                   weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(24, 24)] withRadious:0];
                                   [initial  removeFromSuperview];
                                   [photoUtils saveImageToCacheWithOutCompression:[userDict objectForKey:@"photo"] :weakSelf.image];
                                   
                               }                           }
                       });
    }
    else
    {
        weakSelf.image = thumb;
        [initial  removeFromSuperview];
    }
    }

    isPrivate = NO;
    
}
-(void)createPost
{
    if(textView.text.length == 0)
    {
        UIAlertController *alertController =[UIAlertController alertControllerWithTitle:PROJECT_NAME message:@"Please enter text" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"OK action");
                                   }];
        
        [alertController addAction:okAction];

        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    if([selectedtagsArray count] == 0)
    {
        UIAlertController *alertController =[UIAlertController alertControllerWithTitle:PROJECT_NAME message:@"Please select atleast one tag" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"OK action");
                                   }];
        
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];

        
        return;
    }
    isPostClicked = YES;
    postButton.enabled = NO;
    if(uploadingImages == 0)
    {
        [self callPostApi];
    }
    
    [self.extensionContext cancelRequestWithError:nil];

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
    
    NSString *command = @"create";
    NSDictionary* postData = @{@"access_token": [tokenDict objectForKey:@"access_token"],
                               @"command": command,
                               @"body": postDetails};
    NSString *urlAsString = [NSString stringWithFormat:@"%@posts",BASE_URL];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:postData options:0  error:nil];
    
    //convert data to string
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    DebugLog(@"----Request-URL: %@",urlAsString);
    
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSData *requestData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"and unique name"]];
    sessionConfiguration.sharedContainerIdentifier=@"group.com.maisasolutions.msocl";
    // config.HTTPMaximumConnectionsPerHost = 1;
    
    
   NSURLSession *session = [NSURLSession  sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    
    NSURLSessionDataTask  *uploadTask = [session dataTaskWithRequest:request];
    [uploadTask resume];
    
    
    
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    
//    if([[response.URL absoluteString] containsString:@"api/posts"])
//    [self.extensionContext cancelRequestWithError:nil];
}
-(void)postCreationSccessfull:(NSDictionary *)notificationDict
{
    
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
    
    isPostClicked = NO;
    postButton.enabled = YES;
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
    
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": [tokenDict objectForKey:@"access_token"],
                               @"command": @"s3upload",
                               @"body": newImageDetails};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];

    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:postData options:0  error:nil];
    
    //convert data to string
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSData *requestData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.sharedContainerIdentifier=@"group.com.maisasolutions.msocl";
    // config.HTTPMaximumConnectionsPerHost = 1;
    __block NSString *identfier = imageOrg.accessibilityIdentifier;
    
    NSURLSession *session = [NSURLSession  sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                          
    {
        if(error == nil){
            uploadingImages--;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:nil];
            responseDict = [responseDict objectForKey:@"body"];
            [imagesIdDict setObject:[responseDict objectForKey:@"key"] forKey:identfier];
            if(uploadingImages == 0 && isPostClicked)
            {
                isPostClicked = NO;
                    [self callPostApi];
            }
            
        }
        else{
            uploadingImages--;
            if(uploadingImages == 0 && isPostClicked)
            {
                isPostClicked = NO;
                    [self callPostApi];
            }
        }
        
    }];
    
    [postDataTask resume];

}
@end
