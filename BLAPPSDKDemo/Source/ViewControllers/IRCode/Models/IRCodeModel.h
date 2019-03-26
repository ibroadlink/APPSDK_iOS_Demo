//
//  IRCodeModel.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/3/26.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IRCodeModel : NSObject

@property(nonatomic, copy) NSString *name;
@property(nonatomic, assign) NSInteger modelId;
@property(nonatomic, assign) NSInteger brandId;
@property(nonatomic, assign) NSInteger devtype;

@end

NS_ASSUME_NONNULL_END
