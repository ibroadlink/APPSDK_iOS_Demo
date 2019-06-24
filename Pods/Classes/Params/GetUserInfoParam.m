//
//  GetUserInfoParam.m
//  Let
//
//  Created by yzm on 16/5/18.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "GetUserInfoParam.h"

@implementation GetUserInfoParam

- (instancetype)init
{
    return [self initWithUseridArray:nil];
}

- (instancetype)initWithUseridArray:(NSArray<NSString *> *)useridArray
{
    self = [super init];
    if (self) {
        self.useridArray = useridArray;
    }
    
    return self;
}

- (void)addUserid:(NSString *)userid
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:self.useridArray];
    [array addObject:userid];
    
    self.useridArray = [NSArray arrayWithArray:array];
}

@end
