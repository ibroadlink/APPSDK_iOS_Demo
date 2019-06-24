//
//  BLLogLevel.h
//  BLLetBase
//
//  Created by zhujunjie on 2017/12/27.
//  Copyright © 2017年 zhujunjie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLLogLevel : NSObject

+ (instancetype)sharedLevel;

@property (nonatomic, assign) NSUInteger level;

@end
