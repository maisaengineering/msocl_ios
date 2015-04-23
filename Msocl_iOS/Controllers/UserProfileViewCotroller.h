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
@interface UserProfileViewCotroller : UIViewController<StreamDisplayViewDelegate,PostDetailsProtocol>

@property (nonatomic, strong) NSString *profileId;
@property (nonatomic, strong) NSString *photo;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) IBOutlet UIImageView *profileImageVw;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UIButton *followOrEditBtn;


-(IBAction)followOrEditClicked:(id)sender;

@end
