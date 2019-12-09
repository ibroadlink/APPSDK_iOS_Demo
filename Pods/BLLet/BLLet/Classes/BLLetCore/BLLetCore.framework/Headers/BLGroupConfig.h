//
//  BLGroupConfig.h
//  AFNetworking
//
//  Created by hongkun.bai on 2019/8/23.
//

#import <Foundation/Foundation.h>
#import "BLSubDevKeys.h"
NS_ASSUME_NONNULL_BEGIN

@interface BLGroupConfig : NSObject

@property (nonatomic, copy)NSString *target;

@property (nonatomic, copy)NSArray<BLSubDevKeys *> *list;
@end

NS_ASSUME_NONNULL_END
