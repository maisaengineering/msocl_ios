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
#import "UIImageView+AFNetworking.h"
#import "ProfilePhotoUtils.h"
@implementation ManageTagsViewController
{
    UITableView *manageTagsTableView;
    UITableView *recomondedTagsTableView;
    NSMutableArray *recomondedTagsArray;
    NSMutableArray *managedTagsArray;
    ModelManager *sharedModel;
    Webservices *webServices;
    NSMutableArray *selectedTags;
    ProfilePhotoUtils  *photoUtils;


}
@synthesize recomondedButton;
@synthesize manageButton;
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"MANAGE TAGS";
    
    sharedModel = [ModelManager sharedModel];

    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    
    photoUtils = [ProfilePhotoUtils alloc];
    
    selectedTags = [[NSMutableArray alloc] init];

    UIImage *background = [UIImage imageNamed:@"icon-back.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside]; //adding action
    [button setImage:background forState:UIControlStateNormal];
    button.frame = CGRectMake(0 ,0,13,17);
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    manageTagsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, 320, Deviceheight)];
    manageTagsTableView.delegate = self;
    manageTagsTableView.dataSource = self;
    manageTagsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    manageTagsTableView.tag = 2;
    [self.view addSubview:manageTagsTableView];
    
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
    managedTagsArray = [[responseDict objectForKey:@"favourites"] mutableCopy];
    [managedTagsArray addObjectsFromArray:[responseDict objectForKey:@"recommended"]];
    selectedTags = [[responseDict objectForKey:@"favourites"] mutableCopy];
    
    
    [manageTagsTableView reloadData];
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
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return managedTagsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        static NSString *simpleTableIdentifier = @"ManagedCell";
        UITableViewCell *cell = [tableView1 dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *viw in [[cell contentView] subviews])
            [viw removeFromSuperview];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 200, 50)];
    label.text = [[managedTagsArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    label.textColor = [UIColor colorWithRed:200/255.0 green:199/255.0 blue:203/255.0 alpha:1.0];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    [cell.contentView addSubview:label];
    
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(287, 17.5, 15, 15)];
        [imageView setImage:[UIImage imageNamed:@"tag-tick-active.png"]];
        [cell.contentView addSubview:imageView];

    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 16, 20, 20)];
    __weak UIImageView *weakSelf = iconImageView;
    
    [iconImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[managedTagsArray objectAtIndex:indexPath.row] objectForKey:@"picture"]]] placeholderImage:[UIImage imageNamed:@"yoga-img.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf.image = [photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(20, 20)];
         
     }failure:nil];
    

    [iconImageView setImage:[UIImage imageNamed:@"yoga-img.png"]];
    [cell.contentView addSubview:iconImageView];

    if([selectedTags containsObject:[managedTagsArray objectAtIndex:indexPath.row]])
    {
        imageView.image = [UIImage imageNamed:@"tag-tick.png"];
        label.textColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
        
    }
        
        return cell;
    
}
- (void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![selectedTags containsObject:[managedTagsArray objectAtIndex:indexPath.row]])
    {
            NSDictionary *dict = [managedTagsArray objectAtIndex:indexPath.row];
            AccessToken* token = sharedModel.accessToken;
            
            NSDictionary* postData = @{@"command": @"follow",@"access_token": token.access_token};
            NSDictionary *userInfo = @{@"command": @"followGroup"};
            
            NSString *urlAsString = [NSString stringWithFormat:@"%@groups/%@",BASE_URL,[dict objectForKey:@"uid"]];
            [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
       
        [selectedTags addObject:dict];
        [manageTagsTableView reloadData];

    }
    else
    {
        NSDictionary *dict = [managedTagsArray objectAtIndex:indexPath.row];
        AccessToken* token = sharedModel.accessToken;
        
        NSDictionary* postData = @{@"command": @"unfollow",@"access_token": token.access_token};
        NSDictionary *userInfo = @{@"command": @"followGroup"};
        
        NSString *urlAsString = [NSString stringWithFormat:@"%@groups/%@",BASE_URL,[dict objectForKey:@"uid"]];
        [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
     

        [selectedTags removeObject:dict];
        [manageTagsTableView reloadData];

    }
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
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
