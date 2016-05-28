//
//  RateTheAppViewController.m
//  Msocl_iOS
//
//  Created by Maisa Pride on 5/28/16.
//  Copyright © 2016 Maisa Solutions. All rights reserved.
//

#import "RateTheAppViewController.h"

@interface RateTheAppViewController ()

@end

@implementation RateTheAppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.remindMeLaterBtn.layer.cornerRadius = 2;
    self.remindMeLaterBtn.layer.borderWidth = 1;
    self.remindMeLaterBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.rateBtn.layer.cornerRadius = 2;
    
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
