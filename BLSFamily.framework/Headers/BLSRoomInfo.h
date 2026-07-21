//
//  BLSRoomInfo.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/19.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLSRoomInfo : NSObject

@property (nonatomic, copy)NSString *action;
@property (nonatomic, copy)NSString *roomid;
@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString *createTime;
@property (nonatomic, assign)NSInteger order;
@property (nonatomic, assign)NSInteger type;

@end

NS_ASSUME_NONNULL_END
