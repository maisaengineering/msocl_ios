//
//  ManageTagsViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/24/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "ManageTagsViewController.h"
#import "StringConstants.h"
#import "ModelManager.h"

@implementation ManageTagsViewController
{
    UITableView *manageTagsTableView;
    UITableView *recomondedTagsTableView;
    NSMutableArray *recomondedTagsArray;
    NSMutableArray *managedTagsArray;
    ModelManager *sharedModel;
    Webservices *webServices;

}
@synthesize recomondedButton;
@synthesize manageButton;
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Manage tags";
    
    sharedModel = [ModelManager sharedModel];

    webServices = [[Webservices alloc] init];
    webServices.delegate = self;

    UIImage *background = [UIImage imageNamed:@"icon-back.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside]; //adding action
    [button setImage:background forState:UIControlStateNormal];
    button.frame = CGRectMake(0 ,0,13,17);
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    manageTagsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,100, 320, Deviceheight - 100)];
    manageTagsTableView.delegate = self;
    manageTagsTableView.dataSource = self;
    manageTagsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    manageTagsTableView.tag = 2;
    [self.view addSubview:manageTagsTableView];
    manageTagsTableView.hidden = YES;
    
    recomondedTagsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,100, 320, Deviceheight - 100)];
    recomondedTagsTableView.delegate = self;
    recomondedTagsTableView.dataSource = self;
    recomondedTagsTableView.tag = 1;
    recomondedTagsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:recomondedTagsTableView];
    
    recomondedButton.userInteractionEnabled = NO;
    
    [self getAllGroups];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
}
-(void)backClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)recomondOrManageClicked:(id)sender
{
    if([sender tag] == 1)
    {
        [recomondedTagsTableView setHidden:NO];
        [manageTagsTableView setHidden:YES];
        recomondedButton.userInteractionEnabled = NO;
        manageButton.userInteractionEnabled = YES;
        recomondedButton.backgroundColor = [UIColor clearColor];
        manageButton.backgroundColor = [UIColor colorWithRed:239/255.0 green:238/255.0 blue:239/255.0 alpha:1.0];
        
        [recomondedTagsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        [recomondedTagsTableView reloadData];
        
    }
    else if([sender tag] == 2)
    {
        [manageTagsTableView setHidden:NO];
        [recomondedTagsTableView setHidden:YES];
        manageButton.userInteractionEnabled = NO;
        recomondedButton.userInteractionEnabled = YES;
        manageButton.backgroundColor = [UIColor clearColor];
        recomondedButton.backgroundColor = [UIColor colorWithRed:239/255.0 green:238/255.0 blue:239/255.0 alpha:1.0];
        
        [manageTagsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        [manageTagsTableView reloadData];
    }
}
#pragma mark - 
#pragma mark API calls
-(void)getAllGroups
{
    AccessToken* token = sharedModel.accessToken;
    
    NSDictionary* postData = @{@"command": @"all",@"access_token": token.access_token};
    NSDictionary *userInfo = @{@"command": @"GetAllGroups"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@groups",BASE_URL];
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}
-(void)didReceiveGroups:(NSDictionary *)responseDict
{
    recomondedTagsArray = [[responseDict objectForKey:@"recommended"] mutableCopy];
    managedTagsArray = [[responseDict objectForKey:@"favourites"] mutableCopy];
    if(!manageTagsTableView.hidden)
        [manageTagsTableView reloadData];
    else
            [recomondedTagsTableView reloadData];
    
}
-(void)fetchingGroupsFailedWithError
{
    
}


#pragma mark- UITableView Data Source Methods
#pragma mark-
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView.tag == 1)
        return recomondedTagsArray.count;
    else
    return managedTagsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView1.tag == 1)
    {
        static NSString *simpleTableIdentifier = @"RecommondedCell";
        UITableViewCell *cell = [tableView1 dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
        if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *viw in [[cell contentView] subviews])
            [viw removeFromSuperview];
        cell.textLabel.text = [[recomondedTagsArray objectAtIndex:indexPath.row] objectForKey:@"name"];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        [cell.textLabel setTextColor:[UIColor colorWithRed:113/255.0 green:113/255.0 blue:113/255.0 alpha:1.0]];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(270, 5, 50, 34)];
        [imageView setImage:[UIImage imageNamed:@""]];
        [cell.contentView addSubview:imageView];

        return cell;
    }
    else
    {
        static NSString *simpleTableIdentifier = @"ManagedCell";
        UITableViewCell *cell = [tableView1 dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *viw in [[cell contentView] subviews])
            [viw removeFromSuperview];
        cell.textLabel.text = [[managedTagsArray objectAtIndex:indexPath.row] objectForKey:@"name"];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        [cell.textLabel setTextColor:[UIColor colorWithRed:76/255.0 green:121/255.0 blue:251/255.0 alpha:1.0]];

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(270, 5, 50, 34)];
        [imageView setImage:[UIImage imageNamed:@""]];
        [cell.contentView addSubview:imageView];
        
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView1.tag == 1)
    {
            NSDictionary *dict = [recomondedTagsArray objectAtIndex:indexPath.row];
            AccessToken* token = sharedModel.accessToken;
            
            NSDictionary* postData = @{@"command": @"follow",@"access_token": token.access_token};
            NSDictionary *userInfo = @{@"command": @"followGroup"};
            
            NSString *urlAsString = [NSString stringWithFormat:@"%@groups/%@",BASE_URL,[dict objectForKey:@"uid"]];
            [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
       
        [recomondedTagsArray removeObject:dict];
        [managedTagsArray addObject:dict];
        [recomondedTagsTableView reloadData];

    }
    else
    {
        NSDictionary *dict = [managedTagsArray objectAtIndex:indexPath.row];
        AccessToken* token = sharedModel.accessToken;
        
        NSDictionary* postData = @{@"command": @"unfollow",@"access_token": token.access_token};
        NSDictionary *userInfo = @{@"command": @"followGroup"};
        
        NSString *urlAsString = [NSString stringWithFormat:@"%@groups/%@",BASE_URL,[dict objectForKey:@"uid"]];
        [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
     
        [managedTagsArray removeObject:dict];
        [recomondedTagsArray addObject:dict];
        [manageTagsTableView reloadData];

    }
}

#pragma mark -
#pragma mark Follow/Unfollow API call backs
-(void) followingGroupSuccessFull:(NSDictionary *)recievedDict
{
    
}
-(void) followingGroupFailed
{
    
}


@end
