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
#import "PostDetails.h"
#import "AddPostViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "NIAttributedLabel.h"
@protocol PostDetailsProtocol<NSObject>
-(void)PostEditedFromPostDetails:(PostDetails *)postDetails;
-(void)PostDeletedFromPostDetails;
@end


@interface PostDetailDescriptionViewController : UIViewController<UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,webServiceProtocol,SWTableViewCellDelegate,EditPostProtocol,UIActionSheetDelegate,MFMailComposeViewControllerDelegate,NIAttributedLabelDelegate>

@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSMutableArray *storiesArray;
@property (nonatomic, strong) IBOutlet UITableView *streamTableView;
@property (nonatomic, strong) UIView *commentView;
@property (nonatomic, strong) UITextView *txt_comment;
@property (nonatomic, strong) NSTimer *timerHomepage;
@property (nonatomic, strong) NSMutableDictionary *subContext;
@property (nonatomic, strong) NSMutableDictionary *homeContext;


@property (nonatomic,weak) id <PostDetailsProtocol>delegate;

@property (nonatomic, strong) PostDetails *postObjectFromWall;
-(void)commentClicked:(id)sender;
-(void)follow:(id)sender;
@end
