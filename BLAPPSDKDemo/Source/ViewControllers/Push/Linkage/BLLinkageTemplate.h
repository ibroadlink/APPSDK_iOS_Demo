// BLLinkageTemplate.h

// To parse this JSON:
//
//   NSError *error;
//   BLLinkageTemplate *linkageTemplate = [BLLinkageTemplate fromJSON:json encoding:NSUTF8Encoding error:&error];

#import <Foundation/Foundation.h>

@class BLLinkageTemplate;
@class BLLinkage;
@class BLLinkagedevices;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface BLLinkageTemplate : NSObject
@property (nonatomic, assign) NSInteger error;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy)   NSString *msg;
@property (nonatomic, copy)   NSArray<BLLinkage *> *linkages;

@end

@interface BLLinkage : NSObject
@property (nonatomic, copy)           NSString *familyid;
@property (nonatomic, copy)           NSString *rulename;
@property (nonatomic, assign)         NSInteger ruletype;
@property (nonatomic, copy)           NSString *ruleid;
@property (nonatomic, copy)           NSString *teamid;
@property (nonatomic, assign)         NSInteger enable;
@property (nonatomic, assign)         NSInteger delay;
@property (nonatomic, copy)           NSString *characteristicinfo;
@property (nonatomic, copy)           NSString *locationinfo;
@property (nonatomic, copy)           NSArray *moduleid;
@property (nonatomic, nullable, copy) id sceneIds;
@property (nonatomic, copy)           NSString *createtime;
@property (nonatomic, nullable, copy) NSArray *subscribe;
@property (nonatomic, copy)           NSString *source;
@property (nonatomic, copy)           NSString *md5Key;
@property (nonatomic, strong)         BLLinkagedevices *linkagedevices;
@property (nonatomic, assign)         BOOL linkEnable;
@end

@interface BLLinkagedevices : NSObject
@property (nonatomic, copy)           NSString *moduleid;
@property (nonatomic, copy)           NSString *sceneId;
@property (nonatomic, copy)           NSString *name;
@property (nonatomic, copy)           NSString *linkagedevicesExtern;
@property (nonatomic, copy)           NSString *linkagetype;
@property (nonatomic, copy)           NSString *did;
@property (nonatomic, nullable, copy) id moduledev;
@property (nonatomic, nullable, copy) id devs;
@end

NS_ASSUME_NONNULL_END
