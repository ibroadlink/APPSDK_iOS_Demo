//
//  Tools.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2018/7/3.
//  Copyright © 2018 BroadLink. All rights reserved.
//

#import "Tools.h"

@implementation Tools


+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize compressionQuality:(CGFloat)compressionQuality {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [UIImage imageWithData:UIImageJPEGRepresentation(newImage, compressionQuality)];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
