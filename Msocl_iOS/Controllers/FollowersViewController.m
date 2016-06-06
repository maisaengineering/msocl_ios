//
//  FollowersViewController.m
//  Msocl_iOS
//
//  Created by Maisa Pride on 6/6/16.
//  Copyright © 2016 Maisa Solutions. All rights reserved.
//

#import "FollowersViewController.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "StringConstants.h"
#import "ProfilePhotoUtils.h"
#import "ProfileDateUtils.h"
#import "ModelManager.h"
#import "SDWebImageManager.h"
#import "STTweetLabel.h"
#import "AppDelegate.h"
#import "UserProfileViewCotroller.h"
#import "Follower.h"

@interface FollowersViewController ()
{
    NSMutableArray *followersArray;
    ProfilePhotoUtils *photoUtils;
    ProfileDateUtils *profileDateUtils;
    ModelManager *sharedModel;
    
    Webservices *webServices;
    
    AppDelegate *appDelegate;
}
@end

@implementation FollowersViewController
@synthesize followersTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    sharedModel   = [ModelManager sharedModel];
    photoUtils = [ProfilePhotoUtils alloc];
    appDelegate = [[UIApplication sharedApplication] delegate];
    followersArray = [[NSMutableArray alloc] init];
    followersTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, Deviceheight-65)];
    followersTableView.delegate = self;
    followersTableView.dataSource = self;
    followersTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    followersTableView.tableHeaderView = nil;
    followersTableView.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
    [self.view addSubview:followersTableView];
    self.title = @"Followers";
    
    UIImage *background = [UIImage imageNamed:@"icon-back.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside]; //adding action
    [button setImage:background forState:UIControlStateNormal];
    button.frame = CGRectMake(0 ,0,13,17);
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;

    [self callFollowersApi];
}
-(void)backClicked
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)callFollowersApi
{
    AccessToken* token = sharedModel.accessToken;
    NSString *command = @"followers";
    NSDictionary* body = @{@"uid": self.uid};

    NSDictionary* postData = @{@"command": command,@"access_token": token.access_token,@"body":body};
    NSDictionary *userInfo = @{@"command": @"followers"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];

}

-(void) didReceiveFollowers:(NSDictionary *)recievedDict
{
    NSArray *notifiArray = [recievedDict objectForKey:@"followers"];
    followersArray = [notifiArray mutableCopy];
    [followersTableView reloadData];
    
    
    [appDelegate showOrhideIndicator:NO];
}
-(void) followersFailed
{
    [appDelegate showOrhideIndicator:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [followersArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"FollowersCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    Follower *followerObject = [followersArray objectAtIndex:indexPath.row];
    
    //removes any subviews from the cell
    for(UIView *viw in [[cell contentView] subviews])
    {
        [viw removeFromSuperview];
    }
    cell.backgroundColor = [UIColor clearColor];


    [self buildCell:cell withDetails:followerObject :indexPath];

    return cell;
    
}
-(void)buildCell:(UITableViewCell *)cell withDetails:(Follower *)followerObject :(NSIndexPath *)indexPath
{
    
    UIImageView *profileImage;
    profileImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
    __weak UIImageView *weakSelf = profileImage;
    
    NSMutableString *parentFnameInitial = [[NSMutableString alloc] init];
    if( [followerObject.fname length] >0)
        [parentFnameInitial appendString:[[followerObject.fname substringToIndex:1] uppercaseString]];
    if([followerObject.lname length]>0)
        [parentFnameInitial appendString:[[followerObject.lname substringToIndex:1] uppercaseString]];
    
    
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:parentFnameInitial
                                           attributes:nil];
    NSRange range;
    if(parentFnameInitial.length > 0)
    {
        range.location = 0;
        range.length = 1;
        [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:16]}
                                range:range];
    }
    if(parentFnameInitial.length > 1)
    {
        range.location = 1;
        range.length = 1;
        [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:102/255.0],NSFontAttributeName:[UIFont fontWithName:@"SanFranciscoText-Regular" size:16]}
                                range:range];
    }
    
    
    //add initials
    
    UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    initial.attributedText = attributedText;
    [initial setBackgroundColor:[UIColor clearColor]];
    initial.textAlignment = NSTextAlignmentCenter;
    [profileImage addSubview:initial];
    
    if(followerObject.photo_thumb.length > 0)
    {
        
        [profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:followerObject.photo_thumb]] placeholderImage:[UIImage imageNamed:@"circle-80.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(40, 40)] withRadious:0];
             [initial removeFromSuperview];
             
         }failure:nil];
    }
    else
    {
        [profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:followerObject.photo]] placeholderImage:[UIImage imageNamed:@"circle-80.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(40, 40)] withRadious:0];
             [initial removeFromSuperview];
             
         }failure:nil];
    }
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, 200, 40)];
    name.textAlignment = NSTextAlignmentLeft;
    [name setText:[NSString stringWithFormat:@"%@ %@",followerObject.fname,followerObject.lname]];
    [name setFont:[UIFont fontWithName:@"SanFranciscoText-Regular" size:15]];
    [name setTextColor:[UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:1.0]];
    [cell.contentView addSubview:name];
    
    
    [cell.contentView addSubview:profileImage];
    
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Follower *followerObject = [followersArray objectAtIndex:indexPath.row];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    UserProfileViewCotroller *postDetailDescriptionViewController = (UserProfileViewCotroller*)[mainStoryboard
                                                                                                instantiateViewControllerWithIdentifier: @"UserProfileViewCotroller"];
    postDetailDescriptionViewController.profileId = followerObject.uid;
    [self.navigationController pushViewController:postDetailDescriptionViewController animated:YES];


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
