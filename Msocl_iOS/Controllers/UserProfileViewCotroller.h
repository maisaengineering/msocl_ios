//
//  UserProfileViewCotroller.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/23/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StreamDisplayView.h"
#import "PostDetailDescriptionViewController.h"
#import "Webservices.h"
@interface UserProfileViewCotroller : UIViewController<StreamDisplayViewDelegate,PostDetailsProtocol,webServiceProtocol>

@property (nonatomic, strong) NSString *profileId;
@property (nonatomic, strong) NSString *photo;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong)  UIImageView *profileImageVw;
@property (nonatomic, strong)  UIImageView *lineImageVw;
@property (nonatomic, strong)  UIView *animatedTopView;

@property (nonatomic, strong)  UILabel *nameLabel;
@property (nonatomic, strong)  UILabel *aboutLabel;
@property (nonatomic, strong)  UIButton *linkButton;
@property (nonatomic, strong)  UIButton *followOrEditBtn;
@property (nonatomic, strong)  UILabel *postsCount;
@property (nonatomic, strong)  UILabel *followingCount;



-(void)followOrEditClicked:(id)sender;

@end
