//
//  BLLinkageInfo.h
//  BLSFamily
//
//  Created by hongkun.bai on 2019/7/25.
//  Copyright © 2019 hongkun.bai. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BLLinkageInfo;
@class BLLinkagedevices;
@class BLDev;
@class BLSubscribe;



NS_ASSUME_NONNULL_BEGIN

@interface BLSubscribe : NSObject
@property (nonatomic, copy)   NSString *ruleid;
@property (nonatomic, copy)   NSString *endpointID;
@property (nonatomic, assign) NSInteger didtype;
@end

@interface BLDev : NSObject
@property (nonatomic, copy)   NSString *endpointID;
@property (nonatomic, copy)   NSString *gatewayID;
@property (nonatomic, assign) NSInteger order;
@property (nonatomic, copy)   NSString *content;
@end

@interface BLLinkagedevices : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *linkagedevicesExtern;
@property (nonatomic, copy) NSString *linkagetype;
@property (nonatomic, copy) NSArray<BLDev *> *devs;
@end

@interface BLLinkageInfo : NSObject
@property (nonatomic, copy)   NSString *familyid;
@property (nonatomic, copy)   NSString *rulename;
@property (nonatomic, assign) NSInteger ruletype;
@property (nonatomic, copy)   NSString *ruleid;
@property (nonatomic, copy)   NSString *teamid;
@property (nonatomic, assign) NSInteger enable;
@property (nonatomic, assign) NSInteger delay;
@property (nonatomic, copy)   NSString *characteristicinfo;
@property (nonatomic, copy)   NSString *locationinfo;
@property (nonatomic, copy)   NSArray<NSString *> *sceneIDS;
@property (nonatomic, copy)   NSArray<BLSubscribe *> *subscribe;
@property (nonatomic, copy)   NSString *source;
@property (nonatomic, strong) BLLinkagedevices *linkagedevices;
@end


NS_ASSUME_NONNULL_END
