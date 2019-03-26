//
//  SubAreaInfo.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/3/26.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IRCodeSubAreaInfo : NSObject

@property(nonatomic, assign) NSInteger locateid;
@property(nonatomic, assign) NSInteger levelid;
@property(nonatomic, assign) NSInteger isleaf;
@property(nonatomic, copy) NSString *status;
@property(nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
