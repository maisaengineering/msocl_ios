//
//  FollowersViewController.h
//  Msocl_iOS
//
//  Created by Maisa Pride on 6/6/16.
//  Copyright © 2016 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Webservices.h"
#import "NIAttributedLabel.h"

@interface FollowersViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,webServiceProtocol,NIAttributedLabelDelegate>

@property (nonatomic, strong) UITableView *followersTableView;
@property (nonatomic, strong) NSString *uid;

-(void)callFollowersApi;


@end
