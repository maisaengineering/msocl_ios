//
//  NotificationsViewController.h
//  Msocl_iOS
//
//  Created by Maisa Pride on 5/13/16.
//  Copyright © 2016 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Webservices.h"
#import "NIAttributedLabel.h"

@interface NotificationsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,webServiceProtocol,NIAttributedLabelDelegate>


@property (nonatomic, strong) NSMutableArray *notificationsArray;
@property (nonatomic, strong) UITableView *notificationsTableView;
@property (nonatomic, assign) BOOL bProcessing;
@property (nonatomic, assign) BOOL isSearching;

@property (nonatomic, strong) NSString *timeStamp;
@property (nonatomic, strong) NSString *etag;
@property (nonatomic, strong) NSNumber *notificationCount;

-(void)callNotificationsApi:(NSString *)step;
-(void)resetData;

@end
