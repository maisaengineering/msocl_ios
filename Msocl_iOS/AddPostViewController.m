//
//  AddPostViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "AddPostViewController.h"
#import "StringConstants.h"

@implementation AddPostViewController
{
    UITextView *textView;
}
@synthesize scrollView;
-(void)viewDidLoad
{
    [super viewDidLoad];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,screenWidth, 64)];
    [topView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:topView];
    UIImageView *lineImage = [[UIImageView alloc] init];
    [lineImage setBackgroundColor:[UIColor colorWithRed:192/255.0 green:184/255.0 blue:176/255.0 alpha:1.0]];
    [lineImage setFrame:CGRectMake(0, 63.5f, screenWidth, 0.5f)];
    [self.view addSubview:lineImage];
    
    
    
    CGRect frame = CGRectMake(0, 17, screenWidth, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:69.0/255.0 green:199.0/255.0 blue:242.0/255.0 alpha:1.0];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0];
    label.text = @"Add post";
    [topView addSubview:label];
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitleColor:[UIColor colorWithRed:(251/255.f) green:(176/255.f) blue:(64/255.f) alpha:1] forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(-0.5, 20.5, 80, 44)];
    [cancelButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Roman" size:17]];
    [topView addSubview:cancelButton];
    
    [self postDetailsScroll];
    
}
-(void)cancelClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];

}
-(void)postDetailsScroll
{
    int height = Deviceheight-64;
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, 320, height)];
    scrollView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:scrollView];

    textView = [[UITextView alloc] initWithFrame:CGRectMake(10,10,300, 200)];
    textView.font = [UIFont systemFontOfSize:16];
    [scrollView addSubview:textView];
}
@end
