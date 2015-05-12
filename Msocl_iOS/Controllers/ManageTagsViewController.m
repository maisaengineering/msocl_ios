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
#import "PhotoCollectionViewCell.h"
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
 UIView *addPopUpView;

}
@synthesize collectionView;
@synthesize timerHomepage;
@synthesize subContext;
@synthesize homeContext;


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
    
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 7;
    layout.minimumLineSpacing = 7;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10,10, 300, Deviceheight-10) collectionViewLayout:layout];
    else
        collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10,74, 300, Deviceheight-74) collectionViewLayout:layout];

    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [collectionView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:collectionView];
    

    
    [self getAllGroups];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self check];
    [super viewWillAppear:YES];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
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
    
    
    [collectionView reloadData];
}
-(void)fetchingGroupsFailedWithError
{
    
}

#pragma mark - UICollectionViewDataSource Methods
#pragma mark -
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    return managedTagsArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize retval;
    retval.height= 95; retval.width = 95; return retval;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"cellIdentifier";
    
    PhotoCollectionViewCell* cell=[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
    __weak UIImageView *weakSelf = imageView;
    
    [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[managedTagsArray objectAtIndex:indexPath.row] objectForKey:@"picture"]]] placeholderImage:[UIImage imageNamed:@"tag-placeholder.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf.image = [photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(95, 95)];
         
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
         
     }];
    
    [cell addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 75, 95, 20)];
    label.backgroundColor = [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1.0];
    [label setText:[[managedTagsArray objectAtIndex:indexPath.row] objectForKey:@"name"]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont fontWithName:@"Ubuntu-Light" size:12]];
    [label setTextColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0]];
    [cell addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"tag-tick-active.png"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(80, 8, 15, 15)];
    [cell addSubview:button];
    
    if([selectedTags containsObject:[managedTagsArray objectAtIndex:indexPath.row]])
    {
        [button setImage:[UIImage imageNamed:@"tag-tick.png"] forState:UIControlStateNormal];
        [label setBackgroundColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0]];
        [label setTextColor:[UIColor whiteColor]];
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView1 didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(![selectedTags containsObject:[managedTagsArray objectAtIndex:indexPath.row]])
    {
        
        NSMutableArray *groups =  [[[NSUserDefaults standardUserDefaults] objectForKey:@"Groups"] mutableCopy];
        NSDictionary *dict = [managedTagsArray objectAtIndex:indexPath.row];
        if(![groups containsObject:dict])
        {
            [groups addObject:dict];
            [[NSUserDefaults standardUserDefaults] setObject:groups forKey:@"Groups"];
        }
        
        AccessToken* token = sharedModel.accessToken;
        
        NSDictionary* postData = @{@"command": @"follow",@"access_token": token.access_token};
        NSDictionary *userInfo = @{@"command": @"followGroup"};
        
        NSString *urlAsString = [NSString stringWithFormat:@"%@groups/%@",BASE_URL,[dict objectForKey:@"uid"]];
        [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
        
        [selectedTags addObject:dict];
        
    }
    else
    {
        
        NSMutableArray *groups =  [[[NSUserDefaults standardUserDefaults] objectForKey:@"Groups"] mutableCopy];
        
        NSDictionary *dict = [managedTagsArray objectAtIndex:indexPath.row];
        [groups removeObject:dict];
        [[NSUserDefaults standardUserDefaults] setObject:groups forKey:@"Groups"];
        AccessToken* token = sharedModel.accessToken;
        
        NSDictionary* postData = @{@"command": @"unfollow",@"access_token": token.access_token};
        NSDictionary *userInfo = @{@"command": @"followGroup"};
        
        NSString *urlAsString = [NSString stringWithFormat:@"%@groups/%@",BASE_URL,[dict objectForKey:@"uid"]];
        [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
        
        [selectedTags removeObject:dict];
        
        
    }
    [collectionView1 reloadData];
}
#pragma mark -
#pragma mark Follow/Unfollow API call backs
-(void) followingGroupSuccessFull:(NSDictionary *)recievedDict
{
    
}
-(void) followingGroupFailed
{
    
}
#pragma mark -
#pragma mark Timed Reminders
-(void)check
{
    NSMutableArray *timedReminderArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"PageGuidePopUpImages"];
    NSArray *array = [timedReminderArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"context = %@",@"ManageTags"]];
    if(array.count > 0)
    {
        homeContext = [[array firstObject] mutableCopy];
        NSDictionary *dictionary = [array firstObject];
        NSArray *graphicsArray = [dictionary objectForKey:@"graphics"];
        if(graphicsArray.count > 0)
        {
            
            subContext = [graphicsArray firstObject];
            [self setUpTimerWithStartInSubContext:subContext];
            
            
        }
    }
    
    
}
-(void)setUpTimerWithStartInSubContext:(NSMutableDictionary *)subContext1
{
    NSTimeInterval timeInterval = [[subContext1 valueForKey:@"start"] doubleValue];
    
    if (!timerHomepage) {
        
        timerHomepage = [NSTimer scheduledTimerWithTimeInterval: timeInterval
                                                         target: self
                                                       selector: @selector(displayPromptForNewKidWhenStreamDataEmpty)
                                                       userInfo: nil
                                                        repeats: NO];
    }
    else
    {
        
        [timerHomepage invalidate];
        timerHomepage = nil;
        timerHomepage = [NSTimer scheduledTimerWithTimeInterval: timeInterval
                                                         target: self
                                                       selector: @selector(displayPromptForNewKidWhenStreamDataEmpty)
                                                       userInfo: nil
                                                        repeats: NO];
    }
}
/// Display the pop up
-(void)displayPromptForNewKidWhenStreamDataEmpty
{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    addPopUpView = [[UIView alloc] initWithFrame:CGRectMake(0,0,screenWidth,screenHeight)];
    [addPopUpView setBackgroundColor:[UIColor clearColor]];
    
    
    //MARK:POP Up image
    UIImageView *popUpContent = [[UIImageView alloc] init];
    [popUpContent setFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    
    NSString *imageURL = [subContext objectForKey:@"asset"];
    UIImage *thumb;
    if (imageURL.length >0)
    {
        photoUtils = [ProfilePhotoUtils alloc];
        thumb = [photoUtils getImageFromCache:imageURL];
        
        if (thumb == nil)
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^(void)
                           {
                               NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
                               UIImage* image = [[UIImage alloc] initWithData:imageData];
                               if (image) {
                                   [photoUtils saveImageToCache:imageURL :image];
                                   
                               }
                           });
        }
        else
        {
            [popUpContent setImage:thumb];
        }
    }
    else
    {
        //[popUpContent setImage:[UIImage imageNamed:@"New_Child_Stream_Empty.png"]];
    }
    [popUpContent setImage:thumb];
    
    [addPopUpView addSubview:popUpContent];
    
    // MARK:Got it button
    UIButton *gotItButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [gotItButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    gotItButton.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    gotItButton.tag = 1;
    [addPopUpView addSubview:gotItButton];
    
    if (thumb)
    {
        [[[[UIApplication sharedApplication] delegate] window] addSubview:addPopUpView];
    }
    
}
- (void)buttonClicked:(UIButton *)sender
{
    //
    [addPopUpView removeFromSuperview];
    
    NSMutableArray *userDefaultsArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PageGuidePopUpImages"] mutableCopy];
    long int index = [userDefaultsArray indexOfObject:homeContext];
    NSMutableArray *graphicsArrray =  [[homeContext objectForKey:@"graphics"] mutableCopy];
    [graphicsArrray removeObject:subContext];
    [homeContext setObject:graphicsArrray forKey:@"graphics"];
    [userDefaultsArray replaceObjectAtIndex:index withObject:homeContext];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userDefaultsArray forKey:@"PageGuidePopUpImages"];
    
    
    ////////////Saving already viewed uids in userdefaults
    NSMutableArray *visitedRemainders =  [[userDefaults objectForKey:@"time_reminder_visits"] mutableCopy];
    if(visitedRemainders.count >0 )
    {
        NSArray *contextArray  = [visitedRemainders filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"reminder_uid = %@",[homeContext objectForKey:@"uid"]]];
        if(contextArray.count >0)
        {
            NSMutableDictionary *contextDict = [[contextArray firstObject] mutableCopy];
            long int index = [visitedRemainders indexOfObject:contextDict];
            NSMutableArray *graphicsArray = [[contextDict objectForKey:@"graphic_uids"] mutableCopy];
            [graphicsArray addObject:[subContext objectForKey:@"uid"]];
            [contextDict setObject:graphicsArray forKey:@"graphic_uids"];
            [visitedRemainders replaceObjectAtIndex:index withObject:contextDict];
            [userDefaults setObject:visitedRemainders forKey:@"time_reminder_visits"];
            
        }
        else
        {
            [visitedRemainders addObject:@{@"reminder_uid":[homeContext objectForKey:@"uid"],@"graphic_uids":[NSArray arrayWithObject:[subContext objectForKey:@"uid"]]}];
            [userDefaults setObject:visitedRemainders forKey:@"time_reminder_visits"];
            
        }
        
        
    }
    else
    {
        NSArray *visited_Remainders = [NSArray arrayWithObject:@{@"reminder_uid":[homeContext objectForKey:@"uid"],@"graphic_uids":[NSArray arrayWithObject:[subContext objectForKey:@"uid"]]}];
        [userDefaults setObject:visited_Remainders forKey:@"time_reminder_visits"];
        
    }
    
    [userDefaults synchronize];
    
    
    [self check];
    
    
}


@end
