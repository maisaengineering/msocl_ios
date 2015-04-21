//
//  PostDetailDescriptionViewController.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/10/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Webservices.h"
#import "SWTableViewCell.h"
#import "CommentCell.h"
@interface PostDetailDescriptionViewController : UIViewController<UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,webServiceProtocol,SWTableViewCellDelegate>

@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSMutableArray *storiesArray;
@property (nonatomic, strong) IBOutlet UITableView *streamTableView;
@property (nonatomic, strong) UIView *commentView;
@property (nonatomic, strong) UITextView *txt_comment;
-(void)commentClicked:(id)sender;
-(void)follow:(id)sender;
@end
