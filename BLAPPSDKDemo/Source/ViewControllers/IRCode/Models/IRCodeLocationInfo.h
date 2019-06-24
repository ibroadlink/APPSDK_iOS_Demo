//
//  IRCodeLocationInfo.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/6/11.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IRCodeLocationInfo : NSObject

@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *provinceCode;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *cityCode;

@end

NS_ASSUME_NONNULL_END
