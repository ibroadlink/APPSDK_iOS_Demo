// BLTemplate.h

// To parse this JSON:
//
//   NSError *error;
//   BLTemplate *template = [BLTemplate fromJSON:json encoding:NSUTF8Encoding error:&error];

#import <Foundation/Foundation.h>

@class BLTemplate;
@class BLTemplateElement;
@class BLAction;
@class BLAlicloud;
@class BLMail;
@class BLConditionsinfo;
@class BLEvent;
@class BLTemplatename;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface BLTemplate : NSObject
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy)   NSString *msg;
@property (nonatomic, assign) NSInteger totalpage;
@property (nonatomic, copy)   NSArray<BLTemplateElement *> *templates;

@end

@interface BLTemplateElement : NSObject
@property (nonatomic, copy)           NSString *templateid;
@property (nonatomic, copy)           NSArray<NSString *> *categorys;
@property (nonatomic, copy)           NSString *templatetype;
@property (nonatomic, copy)           NSString *companyid;
@property (nonatomic, assign)         BOOL enable;
@property (nonatomic, copy)           NSArray<BLEvent *> *events;
@property (nonatomic, copy)           NSArray<BLTemplatename *> *templatename;
@property (nonatomic, copy)           NSString *createdat;
@property (nonatomic, copy)           NSString *status;
@property (nonatomic, nullable, copy) id pids;
@property (nonatomic, nullable, copy) id masterid;
@property (nonatomic, assign)         NSInteger pushmember;
@property (nonatomic, nullable, copy) id needconfig;
@property (nonatomic, nullable, copy) id needconfigdetail;
@property (nonatomic, strong)         BLConditionsinfo *conditionsinfo;
@property (nonatomic, copy)           NSArray<BLAction *> *action;
@end

@interface BLAction : NSObject
@property (nonatomic, copy)   NSString *language;
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, copy)   NSString *status;
@property (nonatomic, strong) BLAlicloud *alicloud;
@property (nonatomic, strong) BLAlicloud *gcm;
@property (nonatomic, strong) BLAlicloud *ios;
@property (nonatomic, strong) BLMail *mail;
@property (nonatomic, strong) BLMail *wechat;
@end

@interface BLAlicloud : NSObject
@property (nonatomic, copy)           NSString *templateid;
@property (nonatomic, copy)           NSString *tagcode;
@property (nonatomic, nullable, copy) NSArray<NSString *> *keylist;
@property (nonatomic, copy)           NSString *content;
@property (nonatomic, copy)           NSString *templatecontent;
@property (nonatomic, assign)         BOOL enable;
@property (nonatomic, copy)           NSString *name;
@property (nonatomic, copy)           NSString *did;
@property (nonatomic, copy)           NSString *action;
@property (nonatomic, nullable, copy) NSArray *actionkeylist;
@property (nonatomic, nullable, copy) id actionvaluelist;
@end

@interface BLMail : NSObject
@property (nonatomic, copy)           NSString *templateid;
@property (nonatomic, copy)           NSString *tagcode;
@property (nonatomic, nullable, copy) id keylist;
@property (nonatomic, copy)           NSString *content;
@property (nonatomic, copy)           NSString *templatecontent;
@property (nonatomic, assign)         BOOL enable;
@property (nonatomic, copy)           NSString *name;
@property (nonatomic, copy)           NSString *did;
@end

@interface BLConditionsinfo : NSObject
@property (nonatomic, copy)   NSArray *datetime;
@property (nonatomic, copy)   NSArray *property;
@end

@interface BLEvent : NSObject
@property (nonatomic, copy)   NSString *ikey;
@property (nonatomic, copy)   NSString *expression;
@property (nonatomic, assign) NSInteger ref_value;
@property (nonatomic, copy)   NSString *ref_value_name;
@property (nonatomic, assign) NSInteger trend_type;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy)   NSString *dev_name;
@property (nonatomic, assign) NSInteger keeptime;
@property (nonatomic, copy)   NSString *category;
@property (nonatomic, copy)   NSString *idev_did;
@end

@interface BLTemplatename : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *language;
@end

NS_ASSUME_NONNULL_END

