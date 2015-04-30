//
//  EditCommentViewController.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/30/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Webservices.h"
@protocol EditCommentProtocol<NSObject>
-(void)CommentEdited:(NSDictionary *)commentDetails;
@end

@interface EditCommentViewController : UIViewController<webServiceProtocol,UITextViewDelegate>

@property (nonatomic, strong) NSDictionary *commentDetails;
@property (nonatomic,weak) id <EditCommentProtocol>delegate;

@end
