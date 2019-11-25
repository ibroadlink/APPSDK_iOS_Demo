//
//  BLTopologyModel.h
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/11/22.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BLLetBase/BLLetBase.h>
NS_ASSUME_NONNULL_BEGIN

@interface BLTopologyDevice : NSObject
@property (nonatomic, copy)   NSString *mac;
@property (nonatomic, assign) NSInteger rssi;
@property (nonatomic, assign) NSInteger parentIndex;
@end

@interface BLTopologyModel : BLBaseResult
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, copy)   NSArray<BLTopologyDevice *> *deviceList;
@end

NS_ASSUME_NONNULL_END
