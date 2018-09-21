//
//  PairResult.h
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

@interface BLPairResult : BLBaseResult

/**
 Get device control id

 @return Device control id
 */
- (NSInteger)getId;

/**
 Set device control id

 @param pairId Device control id
 */
- (void)setId:(NSInteger)pairId;

/**
 Get device control key

 @return Device control key
 */
- (NSString *)getKey;

/**
 Set device control key

 @param key Device control key
 */
- (void)setKey:(NSString *)key;

@end
