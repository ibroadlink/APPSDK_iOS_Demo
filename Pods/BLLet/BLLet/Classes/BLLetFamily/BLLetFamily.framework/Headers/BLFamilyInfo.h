//
//  BLFamilyInfo.h
//  Let
//
//  Created by zjjllj on 2017/2/7.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface BLFamilyInfo : NSObject <NSCopying>

- (instancetype)initWithDictionary:(NSDictionary *)dic;

- (NSDictionary *)getBaseDictionary;

- (NSDictionary *)toDictionary;

@property (nonatomic, copy)NSString *familyId;              //家庭ID
@property (nonatomic, copy)NSString *familyVersion;         //家庭版本信息
@property (nonatomic, copy)NSString *familyIconPath;        //家庭Icon路径
@property (nonatomic, copy)NSString *familyName;            //家庭名称
@property (nonatomic, copy)NSString *familyDescription;     //家庭描述
@property (nonatomic, assign)NSInteger familyLimit;         //家庭的访问权限
@property (nonatomic, copy)NSString *familyPostcode;        //家庭的邮编
@property (nonatomic, copy)NSString *familyMailaddress;     //家庭的邮寄地址
@property (nonatomic, assign)NSUInteger familyLongitude;    //家庭所在维度
@property (nonatomic, assign)NSUInteger familyLatitude;     //家庭所在经度
@property (nonatomic, copy)NSString *familyCountry;         //家庭所在国家
@property (nonatomic, copy)NSString *familyProvince;        //家庭所在省份
@property (nonatomic, copy)NSString *familyCity;            //家庭所在城市
@property (nonatomic, copy)NSString *familyArea;            //家庭所在城区
@property (nonatomic, assign)NSInteger familyOrder;         //家庭序号

@end
