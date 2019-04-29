//
//  BLCatchCrash.h
//  Let
//
//  Created by zhujunjie on 2017/7/11.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLCatchCrash : NSObject

void uncaughtExceptionHandler(NSException *exception);

@end
