//
//  PostDetailDescriptionViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/10/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "PostDetailDescriptionViewController.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "StringConstants.h"
#import "ProfilePhotoUtils.h"
#import "ProfileDateUtils.h"
#import "ModelManager.h"
#import "PostDetails.h"
#import "SDWebImageManager.h"

@implementation PostDetailDescriptionViewController
{
    ProfilePhotoUtils *photoUtils;
    ProfileDateUtils *profileDateUtils;
    ModelManager *sharedModel;
    
    Webservices *webServices;
}
@synthesize storiesArray;
@synthesize postID;
@synthesize streamTableView;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    
    photoUtils = [ProfilePhotoUtils alloc];
    profileDateUtils = [ProfileDateUtils alloc];
    sharedModel   = [ModelManager sharedModel];
    
    webServices = [[Webservices alloc] init];
    webServices.delegate = self;
    
    
    //Upvote
    UIButton *follow = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [follow setTitle:@"Follow this post" forState:UIControlStateNormal];
    [follow.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [follow setFrame:CGRectMake(0, 64, 320, 40)];
    [self.view addSubview:follow];

    
    storiesArray = [[NSMutableArray alloc] init];
    streamTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, follow.frame.size.height+follow.frame.origin.y, 320, Deviceheight-(follow.frame.size.height+follow.frame.origin.y + 40))];
    streamTableView.delegate = self;
    streamTableView.dataSource = self;
    streamTableView.tableFooterView = nil;
    streamTableView.tableHeaderView = nil;
    streamTableView.backgroundColor = [UIColor colorWithRed:(229/255.f) green:(225/255.f) blue:(221/255.f) alpha:1];
    [streamTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:streamTableView];
    
    self.commentView = [[UIView alloc] initWithFrame:CGRectMake(0, streamTableView.frame.origin.y+streamTableView.frame.size.height, 320, 40)];
    [self.view addSubview:self.commentView];
    self.txt_comment = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 250, 40)];
    [self.txt_comment setText:@"Add comment"];
    self.txt_comment.delegate = self;
    [self.commentView addSubview:self.txt_comment];
    //Upvote
    UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [commentBtn setTitle:@"Comment" forState:UIControlStateNormal];
    [commentBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [commentBtn setFrame:CGRectMake(250, 0, 70, 40)];
    [commentBtn addTarget:self action:@selector(commentClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.commentView addSubview:commentBtn];
    
    [self.view addSubview:self.commentView];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self callShowPostApi];
}
#pragma mark -
#pragma mark API calls to get Stream data
-(void)callShowPostApi
{
    AccessToken* token = sharedModel.accessToken;
    
    NSDictionary* postData = @{@"command": @"show",@"access_token": token.access_token};
    NSDictionary *userInfo = @{@"command": @"ShowPost"};
        
        NSString *urlAsString = [NSString stringWithFormat:@"%@posts/%@",BASE_URL,postID];
        [webServices callApi:[NSDictionary dictionaryWithObjectsAndKeys:postData,@"postData",userInfo,@"userInfo", nil] :urlAsString];
}
-(void) didReceiveShowPost:(NSDictionary *)recievedDict
{
    NSArray *postArray = [recievedDict objectForKey:@"posts"];
    [storiesArray removeAllObjects];
    [storiesArray addObjectsFromArray:postArray];
    [streamTableView reloadData];
    
}
-(void) showPostFailed
{
    
}

#pragma mark -
#pragma mark TableViewMethods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [storiesArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"StreamCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    PostDetails *postDetailsObject = [storiesArray objectAtIndex:indexPath.row];
    
    //removes any subviews from the cell
    for(UIView *viw in [[cell contentView] subviews])
    {
        [viw removeFromSuperview];
    }
    
    [self buildCell:cell withDetails:postDetailsObject];
    
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(void)buildCell:(UITableViewCell *)cell withDetails:(PostDetails *)postDetailsObject
{
    float yPosition = 15;
    
    //Back Ground Image
    UIImageView *backGroundImage  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
    [backGroundImage setBackgroundColor:[UIColor lightGrayColor]];
    [cell.contentView addSubview:backGroundImage];
    
    //Profile Image
    UIImageView *profileImage  = [[UIImageView alloc] initWithFrame:CGRectMake(10, yPosition, 100, 100)];
    [profileImage setImageWithURL:[NSURL URLWithString:postDetailsObject.profileImage] placeholderImage:[UIImage imageNamed:@"EmptyProfilePic.jpg"]];
    [cell.contentView addSubview:profileImage];
    
    //Profile name
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(120, yPosition, 140, 21)];
    [name setText:postDetailsObject.name];
    [name setFont:[UIFont systemFontOfSize:16]];
    [cell.contentView addSubview:name];
    
    //Time
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(260, yPosition, 50, 21)];
    [time setText:postDetailsObject.time];
    [time setTextAlignment:NSTextAlignmentRight];
    [time setText:@"5 min ago"];
    [time setFont:[UIFont systemFontOfSize:12]];
    [cell.contentView addSubview:time];
    
    
    //Start of Description Text and Upvote
    yPosition += 21 + 5;
    
    //Upvote
    UIButton *upVote = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [upVote setTitle:@"Up vote" forState:UIControlStateNormal];
    [upVote.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [upVote setFrame:CGRectMake(260, yPosition, 50, 40)];
    [cell.contentView addSubview:upVote];
    
    [self addDescription:cell withDetails:postDetailsObject];
    
    
    
}
-(void)addDescription:(UITableViewCell *)cell withDetails:(PostDetails *)postDetailsObject
{
    float yPosition = 15;
    
    //Start of Description Text
    yPosition += 21 + 5;
    
    //Description
    UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(115, yPosition, 140, 55)];
    
    NSString *input = @"test teste tetste \n::db1kj vf v f::\n test teste tte +\n::db2::\n+\n::db3::\n testette";
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:input attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\::(.*?)\\::" options:NSRegularExpressionCaseInsensitive error:NULL];
    
    
    do{
        
        NSArray *myArray = [regex matchesInString:attributedString.string options:0 range:NSMakeRange(0, [attributedString.string length])] ;
        if(myArray.count > 0)
        {
            NSTextCheckingResult *match =  [myArray firstObject];
            NSRange matchRange = [match rangeAtIndex:1];
            NSLog(@"%@", [input substringWithRange:matchRange]);
            
            UIImage  *image = [photoUtils squareImageWithImage:[UIImage imageNamed:@"EmptyProfilePic.jpg"] scaledToSize:CGSizeMake(20, 20)];
            NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
            textAttachment.image = image;
            
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:[NSURL URLWithString:@"https://test-kl-tmp.s3.amazonaws.com/uploads/image/source/5524da8a6639610003080000/canberra_hero_image.jpg"] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                textAttachment.image = [photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(20, 20)];
                [description setNeedsDisplay];
            }];
            
            NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
            [attributedString replaceCharactersInRange:match.range withAttributedString:attrStringWithImage];
        }
        else
        {
            break;
        }
        
    }while (1);
    //This regex captures all items between []
    
    [description setAttributedText:attributedString];
    [description setTextAlignment:NSTextAlignmentLeft];
    [description setFont:[UIFont systemFontOfSize:12]];
    [description setNumberOfLines:0];
    [cell.contentView addSubview:description];
    
    yPosition += description.frame.size.height;
    
    if([postDetailsObject.tags count] > 0)
    {
        UIView *tagsView = [[UIView alloc] initWithFrame:CGRectMake(115, yPosition, 140, 15)];
        [cell.contentView addSubview:tagsView];
        NSArray *tagsArray = postDetailsObject.tags;
        for(int i=0,x=0; i <tagsArray.count ;i++)
        {
            NSString *tagName = tagsArray[i];
            CGSize size = [tagName sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
            UILabel *tag = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, MIN(size.width, 140 - x) , 15)];
            [tag setText:tagName];
            [tag setFont:[UIFont systemFontOfSize:12]];
            [tag setBackgroundColor:[UIColor lightGrayColor]];
            [tagsView addSubview:tag];
            x += tag.frame.size.width + 3;
            
            if(x >= 140)
                break;
            
        }
        yPosition += 15;
    }
    
    //Time
    UILabel *comments = [[UILabel alloc] initWithFrame:CGRectMake(115, yPosition, 140, 15)];
    [comments setText:[NSString stringWithFormat:@"Comments(22) Upvotses(21)"]];
    [comments setFont:[UIFont systemFontOfSize:10]];
    [cell.contentView addSubview:comments];
    
    yPosition += 15;
    
    if([postDetailsObject.commenters count] > 0)
    {
        NSMutableArray *commenters = [NSMutableArray arrayWithArray:postDetailsObject.commenters];
        UIView *commentersView = [[UIView alloc] initWithFrame:CGRectMake(115, yPosition, 140, 20)];
        [cell.contentView addSubview:commentersView];
        
        int x = 0;
        for(int i = 0; i < commenters.count; i++)
            //for(id dict in array)
        {
            
            NSString *url = [commenters objectAtIndex:i];
            UIImageView *imagVw = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, 20, 20)];
            [commentersView addSubview:imagVw];
            
            [imagVw setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"EmptyProfilePic.jpg"]];
            x+= 20 + 3;
            
            if(i >= 6)
                break;
        }
    }
    
}

-(void)commentClicked:(id)sender
{
    
}
-(void)follow:(id)sender
{
    
}


@end
