//
//  CustomCipher.h
//  KidsLink
//
//  Created by Dale McIntyre on 9/12/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomCipher : NSObject

+(NSString *) encrypt:(NSString *)stringToEncrypt;
+(NSString *) decrypt:(NSString *)stringToEncrypt;
@end
