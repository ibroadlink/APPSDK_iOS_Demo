//
//  BLFamilyElectricityInfo.h
//  Let
//
//  Created by zjjllj on 2017/2/9.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLFamilyElectricityInfo : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dic;

- (NSDictionary *)toDictionary;

/**
 Bill send address
 */
@property (nonatomic, copy)NSString *billingaddr;

/**
 peak time
 */
@property (nonatomic, copy)NSString *pvetime;

/**
 peak price
 */
@property (nonatomic, assign)float peakprice;

/**
 valley price
 */
@property (nonatomic, assign)float valleyprice;

@end
