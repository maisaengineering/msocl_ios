//
//  PromptViewController.m
//  Msocl_iOS
//
//  Created by Maisa Pride on 4/23/16.
//  Copyright © 2016 Maisa Solutions. All rights reserved.
//

#import "PromptViewController.h"

@interface PromptViewController ()

@end

@implementation PromptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.noThanksBtn.layer.cornerRadius = 2;
    self.noThanksBtn.layer.borderWidth = 1;
    self.noThanksBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.notifyBtn.layer.cornerRadius = 2;
    
    self.contentView.center = self.view.center;
}

-(IBAction)buttonTapped:(id)sender
{
    //[self dismissViewControllerAnimated:NO completion:nil];
    [self.view removeFromSuperview];
    [self.delegate responseFromPrompt:(int)[sender tag]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
