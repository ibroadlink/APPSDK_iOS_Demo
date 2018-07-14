//
//  BLLoadingButton.h
//  ihc
//
//  Created by apple on 2017/4/20.
//  Copyright © 2017年 broadlink. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 注意不能使用systemTypeButton
 */
@interface BLLoadingButton : UIButton

/**
 default is NO
 */
@property (nonatomic, assign) BOOL isLoading;

@end
