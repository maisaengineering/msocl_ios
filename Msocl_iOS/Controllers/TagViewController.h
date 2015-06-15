//
//  TagViewController.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/25/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StreamDisplayView.h"
#import "PostDetailDescriptionViewController.h"
#import "Webservices.h"

@interface TagViewController : UIViewController<StreamDisplayViewDelegate,PostDetailsProtocol,webServiceProtocol>

@property (nonatomic, strong) NSString *tagName;
@property (nonatomic, strong) IBOutlet UIImageView *profileImageVw;
@property (nonatomic, strong) IBOutlet UIImageView *smallProfileImageVw;
@property (nonatomic, strong) IBOutlet UIView *animatedTopView;


@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UIButton *followOrEditBtn;
@property (nonatomic, strong) IBOutlet UILabel *postsCount;
@property (nonatomic, strong) IBOutlet UILabel *followingCount;


-(IBAction)followOrEditClicked:(id)sender;

@end
