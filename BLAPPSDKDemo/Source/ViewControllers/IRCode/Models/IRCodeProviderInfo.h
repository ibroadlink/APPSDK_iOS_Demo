//
//  ProviderInfo.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/3/26.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IRCodeProviderInfo : NSObject

@property (nonatomic, copy) NSString *providername;
@property (nonatomic, assign) NSInteger providerid;
@property (nonatomic, assign) NSInteger locateid;

@end

NS_ASSUME_NONNULL_END
