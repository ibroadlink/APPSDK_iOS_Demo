//
//  StdData.h
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Device control data class.
 Help developers easy to compose control data.
 */
@interface BLStdData : NSObject

/** subDevice password */
@property (nonatomic, copy) NSString *subPassword;

/** subDevice srv */
@property (nonatomic, copy) NSString *srv;

/**
 Init class with params and vals.

 @param params      Control params (eg. @[@"pwr", ...] ). All params can be find in device profile.
 @param vals        Control vals (eg. @[ @[ @{ @"val":@(1), @"idx":@(1) } ], ... ] )
 @return            BLStdData Object
 */
- (instancetype)initDataWithParams:(NSArray<NSString *> *)params vals:(NSArray<NSArray<NSDictionary *> *> *)vals;

/**
 Init class with params=@[] and vals=@[].
 
 @return            BLStdData Object
 */
- (instancetype)init;

/**
 Set object params and vals.

 @param paramsArray Control params ( eg. @[@"pwr", ...] ). All params can be find in device profile.
 @param valuesArray Control vals ( eg. @[ @[ @{ @"val":@(1), @"idx":@(1) } ], ... ] )
 */
- (void)setParams:(NSArray<NSString *> *)paramsArray values:(NSArray<NSArray<NSDictionary *> *> *)valuesArray;

/**
 Easy method to compose control data. Default idx=1
 If param and val is existed, overwrite these.
 If param and val is not existed, add these.

 @param value       Val ( eg. @(1) )
 @param param       Param ( eg. @"pwr" )
 */
- (void)setValue:(id)value forParam:(NSString *)param;

/**
 Easy method to compose control data.
 If param and val is existed, overwrite these.
 If param and val is not existed, add these.
 
 @param value       Val ( eg. @(1) )
 @param param       Param ( eg. @"pwr" )
 @param idx         idx
 */
- (void)setValue:(id)value forParam:(NSString *)param forIdx:(NSUInteger)idx;


/**
 Get all vals with param.

 @param param       Param
 @return            Vals
 */
- (id)valueForParam:(NSString *)param;

/**
 Get val with param and idx.

 @param param       Param
 @param idx         idx
 @return            Val
 */
- (id)valueForParam:(NSString *)param forIdx:(NSUInteger)idx;

/**
 Get all params

 @return All params
 */
- (NSArray<NSString *> *)allParams;

/**
 Get All vals

 @return All vals
 */
- (NSArray<NSString *> *)allValues;

/**
 make params and vals to control data dictionary.

 @return Control data dictionary
 */
- (NSDictionary *)toDictionary;

@end
