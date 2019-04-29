//
//  BaseResult.m
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLBaseResult.h"

@implementation BLBaseResult

- (instancetype)init {
    self = [super init];
    if (self) {
        self.status = 0;
        self.error = 0;
        self.msg = @"success";
    }
    
    return self;
}

- (Boolean)succeed {
    return (self.error == 0) ? YES : NO;
}

- (void)setError:(NSInteger)error {
    _error = error;
    _status = error;
}

- (void)setStatus:(NSInteger)status {
    _error = status;
    _status = status;
}

@end
