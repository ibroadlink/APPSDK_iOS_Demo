//
//  TemplateAction.h
//  ihc
//
//  Created by Stone on 2018/3/9.
//  Copyright © 2018年 broadlink. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ActionInfo <NSObject>

@end

@interface ActionInfo : NSObject

@property (nonatomic, copy) NSString *templateid;
@property (nonatomic, copy) NSString *tagcode;
@property (nonatomic, strong) NSArray<NSString *> *keylist;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *templatecontent;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, copy) NSString *did;
@property (nonatomic, copy) NSString *action;
@end

@protocol TemplateAction <NSObject>

@end

@interface TemplateAction : NSObject

@property (nonatomic, copy) NSString *templatetype;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, strong) ActionInfo *alicloud;
@property (nonatomic, strong) ActionInfo *gcm;
@property (nonatomic, strong) ActionInfo *ios;
@property (nonatomic, strong) ActionInfo *mail;
@property (nonatomic, strong) ActionInfo *wechat;

//- (NSDictionary*)toDictionary;
@end
