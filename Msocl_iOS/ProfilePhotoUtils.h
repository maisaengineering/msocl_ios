//
//  ProfilePhotoUtils.h
//  KidsLink
//
//  Created by Dale McIntyre on 4/22/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ProfilePhotoUtils : NSObject

- (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
- (UIImage *)makeRoundKidPhoto:(UIImage *)personImage;
- (UIImage *)makeRoundWithBoarder:(UIImage *)fooImage withRadious:(float)value;
-(UIImage *)makeRoundedCornersWithBorder:(UIImage *)fooImage withRadious:(float)value;
- (UIImage *)getImageFromCache:(NSString *)url;
- (UIImageView*)GrabInitials :(int)diameter :(NSString *)firstName :(NSString *)lastName;
- (void)saveImageToCache:(NSString *)url :(UIImage *)personImage;
- (UIImage *)compressForUpload:(UIImage *)original :(CGFloat)scale;
- (void)saveImageToPhotoLib:(UIImage *)image;
- (void)clearCache;
- (UIImage *)imageWithImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height;
- (void)saveRoundedRectImageToCache:(NSString *)url :(UIImage *)image;
- (UIImage*) getSubImageFrom: (UIImage*) img WithRect: (CGRect) rect;
- (void)saveImageToCacheWithOutCompression:(NSString *)url :(UIImage *)image;
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size withRadious:(CGFloat )radious;

@property (nonatomic, strong) ALAssetsLibrary     * assetLibrary;

@end
