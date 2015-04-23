//
//  StreamDisplayView.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/8/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Webservices.h"

@protocol StreamDisplayViewDelegate <NSObject>

- (void)tableDidSelect:(int)index;
- (void)userProifleClicked:(int)index;

@end
@interface StreamDisplayView : UIView<UITableViewDataSource,UITableViewDelegate,webServiceProtocol>
{
    
}
@property (nonatomic, strong) NSString *profileID;
@property (nonatomic, assign) id<StreamDisplayViewDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *storiesArray;
@property (nonatomic, strong) UITableView *streamTableView;
@property (nonatomic, assign) BOOL isMostRecent;
@property (nonatomic, assign) BOOL isFollowing;
@property (nonatomic, assign) BOOL isUserProfilePosts;
@property (nonatomic, strong) NSString *userProfileId;

@property (nonatomic, strong) NSString *timeStamp;
@property (nonatomic, strong) NSString *etag;
@property (nonatomic, strong) NSNumber *postCount;


-(void)callStreamsApi:(NSString *)step;
-(void)resetData;

@end
