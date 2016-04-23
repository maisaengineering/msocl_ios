//
//  PromptViewController.h
//  Msocl_iOS
//
//  Created by Maisa Pride on 4/23/16.
//  Copyright © 2016 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PromptDelegate <NSObject>

- (void)responseFromPrompt:(int)index;

@end

@interface PromptViewController : UIViewController


@property (nonatomic, strong) IBOutlet UIButton *noThanksBtn;
@property (nonatomic, strong) IBOutlet UIButton *notifyBtn;
@property (nonatomic, strong) IBOutlet UIView *contentView;

@property (nonatomic, weak) id<PromptDelegate> delegate;

-(IBAction)buttonTapped:(id)sender;
@end
