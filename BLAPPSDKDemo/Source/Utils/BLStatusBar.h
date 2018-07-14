//
//  BLStatusBar.h
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface BLStatusBar : UIView

+(void)showTipMessageWithStatus:(NSString* )message;

+(void)showTipMessageWithStatus:(NSString* )message andImage:(UIImage* )image andTipIsBottom:(BOOL)isBottom;

@end
