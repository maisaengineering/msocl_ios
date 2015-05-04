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
#import "Webservices.h"
#import "PostDetails.h"

@protocol EditPostProtocol<NSObject>
-(void) PostEdited:(PostDetails *)postDetails;
-(void)PostDeletedFromEditPostDetails;
@end

@interface AddPostViewController : UIViewController<UITextViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,webServiceProtocol, AVYPhotoEditorControllerDelegate, UIPopoverControllerDelegate,UICollectionViewDelegate, UICollectionViewDataSource>
{
    UIImagePickerController *imagePicker;

}

@property (nonatomic , strong) UIScrollView *scrollView;
@property (nonatomic , strong)  NSMutableArray *selectedtagsArray;
@property (strong, nonatomic)  UICollectionView *collectionView;
@property (nonatomic, strong) NSTimer *timerHomepage;
@property (nonatomic, strong) NSMutableDictionary *subContext;
@property (nonatomic, strong) NSMutableDictionary *homeContext;



//For Aviary
@property (nonatomic, strong) ALAssetsLibrary     * assetLibrary;
@property (nonatomic, strong) NSMutableArray      * sessions;
@property (nonatomic, strong) PostDetails *postDetailsObject;
@property (nonatomic,weak) id <EditPostProtocol>delegate;



@end
