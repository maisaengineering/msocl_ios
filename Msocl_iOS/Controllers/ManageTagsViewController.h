//
//  ManageTagsViewController.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/24/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Webservices.h"

@interface ManageTagsViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource,webServiceProtocol>

@property (strong, nonatomic)  UICollectionView *collectionView;

@end
