//
//  OnboardingViewController.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnboardingViewController : UIViewController

{
    UIImageView *imageView;
    NSDictionary *tour_Dict;
    NSString *base_Url;
}
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *continueButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *addKidButton;
@property (nonatomic, strong) UIButton *inviteFriendsButton;
@property (nonatomic, strong) UIButton *justExploreButton;
@property (nonatomic, strong) NSArray *imageArray;
@property BOOL isFromMoreTab;

- (void)continueButtonTapped:(UIButton *)sender;


@end
