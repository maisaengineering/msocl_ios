//
//  PromptImages.h
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/5/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProfilePhotoUtils.h"
#import "Webservices.h"
@interface PromptImages : NSObject<webServiceProtocol>
{
     ProfilePhotoUtils *photoUtils;
    Webservices *webServices;
}
+ (id)sharedInstance;
-(void)getPrompImages;
-(void)getAllGroups;
@end
