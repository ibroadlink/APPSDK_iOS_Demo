//
//  BLOAuthBlockResult.m
//  Let
//
//  Created by zhujunjie on 2017/8/1.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLOAuthBlockResult.h"

@implementation BLOAuthBlockResult

- (instancetype)init {
    self = [super init];
    if (self) {
        self.error = 0;
        self.msg = @"success";
    }
    
    return self;
}

- (Boolean)succeed {
    return (self.error == 0) ? YES : NO;
}


@end
