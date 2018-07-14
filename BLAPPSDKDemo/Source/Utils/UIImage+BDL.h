//
//  UIImage+BDL.h
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2018/7/3.
//  Copyright © 2018 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BDL)
- (NSData *)convertToNSDataWithMaxLimit: (NSNumber *)maxLimitDataSize;

- (BOOL)writeToFileAtPath:(NSString*)aPath withMaxLimitDataSize: (NSNumber *)maxLimitDataSize;
@end
