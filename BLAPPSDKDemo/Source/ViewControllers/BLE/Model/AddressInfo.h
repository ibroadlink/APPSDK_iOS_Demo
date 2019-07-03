//
//  AddressInfo.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/7/2.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddressInfo : NSObject

//状态
@property (nonatomic, assign) NSInteger state;
//地址
@property (nonatomic, strong) NSString *address;

@end

NS_ASSUME_NONNULL_END
