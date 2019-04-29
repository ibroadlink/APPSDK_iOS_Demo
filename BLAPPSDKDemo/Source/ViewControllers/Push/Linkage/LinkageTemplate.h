//
//  LinkageTemplate.h
//  ihc
//
//  Created by Stone on 2018/3/9.
//  Copyright © 2018年 broadlink. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "TemplateConditionsinfo.h"
#import "TemplateAction.h"

@protocol TemplateName <NSObject>

@end

@interface TemplateName : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *language;
@end


@protocol TemplateEvent <NSObject>

@end

@interface TemplateEvent : NSObject
@property (nonatomic, copy) NSString *ikey;
@property (nonatomic, assign) int ref_value;
@property (nonatomic, copy) NSString *ref_value_name;
@property (nonatomic, assign) int trend_type;
@property (nonatomic, assign) int type;
@property (nonatomic, copy) NSString *name;
//保持时间，时间单位为毫秒
@property (nonatomic, assign) double keeptime;
@property (nonatomic, copy) NSString *category;
//以下参数为联动参数
@property (nonatomic, copy) NSString *dev_name;
@property (nonatomic, copy) NSString *idev_did;
@end

@interface LinkageTemplate : NSObject

@property (nonatomic, copy) NSString *templateid;
@property (nonatomic, strong) NSArray<NSString *> *categorys;
@property (nonatomic, copy) NSString *companyid;
@property (nonatomic, copy) NSString *templatetype;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, strong) NSArray<TemplateName> *templatename;
@property (nonatomic, strong) NSArray<TemplateEvent> *events;
@property (nonatomic, strong) TemplateConditionsinfo *conditionsinfo;
@property (nonatomic, strong) NSArray<TemplateAction> *action;
//-(NSDictionary*)toDictionary;
@end
