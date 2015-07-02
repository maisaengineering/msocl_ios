//
//  ShareViewController.h
//  ShareExtention
//
//  Created by Maisa Solutions on 7/1/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>

@interface ShareViewController : UIViewController<UITextViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,NSURLSessionDelegate>

-(void)cancelClick:(id)sender;
@property (nonatomic , strong) UIScrollView *scrollView;
@property (nonatomic , strong)  NSMutableArray *selectedtagsArray;
@property (strong, nonatomic)  UICollectionView *collectionView;

@end
