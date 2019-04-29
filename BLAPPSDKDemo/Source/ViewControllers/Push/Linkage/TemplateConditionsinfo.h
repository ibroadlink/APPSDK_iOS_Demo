//
//  TemplateConditionsinfo.h
//  ihc
//
//  Created by Stone on 2018/3/9.
//  Copyright © 2018年 broadlink. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TemplateDateTime <NSObject>

@end

@interface TemplateDateTime : NSObject

@property (nonatomic, copy) NSString *weekdays;
@property (nonatomic, assign) int timezone;
@property (nonatomic, strong) NSArray<NSString *> *validperiod;
@end

@protocol TemplateProperty <NSObject>

@end

@interface TemplateProperty : NSObject

@property (nonatomic, copy) NSString *ikey;
@property (nonatomic, assign) int ref_value;
@property (nonatomic, copy) NSString *ref_value_name;
//表示设备的状态 2:大于等于（>=） 3:小于等于（<=） 4:等于（==）
@property (nonatomic, assign) int trend_type;
@property (nonatomic, copy) NSString *category;
//以下为联动参数
@property (nonatomic, copy) NSString *dev_name;
@property (nonatomic, copy) NSString *idev_did;
@property (nonatomic, assign) double keeptime;
@property (nonatomic, assign) int type;
@end

@interface TemplateConditionsinfo : NSObject

@property (nonatomic, strong) NSArray<TemplateDateTime> *datetime;
@property (nonatomic, strong) NSArray<TemplateProperty> *property;
@end
