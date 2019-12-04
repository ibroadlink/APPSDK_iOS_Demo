//
//  BLSGroupDevice.h
//  BLSFamily
//
//  Created by hongkun.bai on 2019/8/28.
//  Copyright © 2019 hongkun.bai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLSGroupDevice : NSObject
@property (nonatomic, copy)   NSString *endpointId;
@property (nonatomic, copy)   NSString *gatewayId;
@property (nonatomic, copy)   NSString *extend;
@end

NS_ASSUME_NONNULL_END
