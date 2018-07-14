//
//  UIImage+BDL.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2018/7/3.
//  Copyright © 2018 BroadLink. All rights reserved.
//


#import "UIImage+BDL.h"

@implementation UIImage (BDL)

- (NSData *)convertToNSDataWithMaxLimit:(NSNumber *)maxLimitDataSize isPng:(BOOL)ifPng{
    
    NSData *imageData;
    if (ifPng) {
        imageData = UIImagePNGRepresentation(self);
    }else {
        imageData = UIImageJPEGRepresentation(self, 0);
    }
    double   factor       = 1.0;
    double   adjustment   = 1.0 / sqrt(2.0);
    CGSize   size         = self.size;
    CGSize   currentSize  = size;
    UIImage *currentImage = self;
    
    
    while (imageData.length >= [maxLimitDataSize longLongValue]) {
        @autoreleasepool {
            factor      *= adjustment;
            currentSize  = CGSizeMake(roundf(size.width * factor), roundf(size.height * factor));
            currentImage = [currentImage convertToSize: currentSize];
            if (ifPng) {
                imageData = UIImagePNGRepresentation(currentImage);
            }else {
                imageData = UIImageJPEGRepresentation(currentImage, 0);
            }
        }
    }
    return imageData;
}

- (NSData *)convertToNSDataWithMaxLimit: (NSNumber *)maxLimitDataSize {
    return [self convertToNSDataWithMaxLimit: maxLimitDataSize isPng:NO];
}

- (BOOL)writeToFileAtPath:(NSString*)aPath withMaxLimitDataSize: (NSNumber *)maxLimitDataSize {
    if ((aPath == nil) || ([aPath isEqualToString:@""])) {
        return NO;
    }
    
    @try {
        NSString *ext = [aPath pathExtension];
        NSData *imageData = [self convertToNSDataWithMaxLimit: maxLimitDataSize isPng: [ext isEqualToString: @"png"]];
        
        if ((imageData == nil) || ([imageData length] <= 0)) {
            return NO;
        }
        [imageData writeToFile:aPath atomically:YES];
        return YES;
    } @catch (NSException *e) {
        NSLog(@"create thumbnail exception.");
    }
    
    return NO;
}

- (UIImage *)convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

@end
