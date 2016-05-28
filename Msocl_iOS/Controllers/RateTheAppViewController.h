//
//  RateTheAppViewController.h
//  Msocl_iOS
//
//  Created by Maisa Pride on 5/28/16.
//  Copyright © 2016 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RateTheAppViewControllerDelegate <NSObject>

- (void)responseFromPrompt:(int)index;

@end

@interface RateTheAppViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *remindMeLaterBtn;
@property (nonatomic, strong) IBOutlet UIButton *rateBtn;
@property (nonatomic, strong) IBOutlet UIView *contentView;

@property (nonatomic, weak) id<RateTheAppViewControllerDelegate> delegate;

-(IBAction)buttonTapped:(id)sender;


@end
