//
//  SettingsViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/22/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "SettingsViewController.h"
#import "ChangePasswordViewController.h"
#import "SlideNavigationController.h"
#import "ManageTagsViewController.h"
@implementation SettingsViewController
{
    UITableView *tableView;

}
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Settings";
    
    UIImage *background = [UIImage imageNamed:@"icon-back.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside]; //adding action
    [button setImage:background forState:UIControlStateNormal];
    button.frame = CGRectMake(0 ,0,13,17);
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;

    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,20, 320, Deviceheight - 20)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:tableView];
}
-(void)backClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)changePassword:(id)sender
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ChangePasswordViewController"];
    
    [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];

}

#pragma mark- UITableView Data Source Methods
#pragma mark-
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    UITableViewCell *cell = [tableView1 dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell.textLabel setTextColor:[UIColor colorWithRed:76/255.0 green:121/255.0 blue:251/255.0 alpha:1.0]];
    
    switch (indexPath.row)
    {
        case 0:
            cell.textLabel.text = @"Change password";
            break;
            
        case 1:
            cell.textLabel.text = @"Manage tags";
            break;
            
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];
            UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ChangePasswordViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case 1:
        {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];
            UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ManageTagsViewController"];
            [self.navigationController pushViewController:vc animated:YES];

        }
            break;
            
    }

}


@end

