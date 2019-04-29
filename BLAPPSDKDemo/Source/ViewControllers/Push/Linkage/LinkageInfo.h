//
//  BLlinkageInfo.h
//  ihc
//
//  Created by Stone on 2018/3/16.
//  Copyright © 2018年 broadlink. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ModuleDevice <NSObject>

@end

@interface ModuleDevice : NSObject

@property (nonatomic, copy) NSString *did;
@property (nonatomic, copy) NSString *sdid;
@property (nonatomic, copy) NSString *order;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *devmoduleid;

@end


@interface LinkageDevices : NSObject

@property (nonatomic, copy) NSString *moduleid;
@property (nonatomic, copy) NSString *did;
@property (nonatomic, strong) NSString *externStr;
@property (nonatomic, copy) NSString *linkagetype;
@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *familyid;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *roomid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *flag;
@property (nonatomic, strong) NSArray<ModuleDevice> *moduledev;
@property (nonatomic, copy) NSString *order;
@property (nonatomic, copy) NSString *moduletype;
@property (nonatomic, copy) NSString *scenetype;
@property (nonatomic, copy) NSString *followdev;
@property (nonatomic, copy) NSString *extend;
@end

@interface LinkageInfo : NSObject

@property (nonatomic, copy) NSString *familyid;
@property (nonatomic, copy) NSString *createtime;
@property (nonatomic, assign) int delay;
@property (nonatomic, assign) int enable;
@property (nonatomic, assign) int ruletype;
@property (nonatomic, copy) NSString *ruleid;
@property (nonatomic, copy) NSString *characteristicinfo;
@property (nonatomic, strong) NSArray<NSString *> *subscribe;
@property (nonatomic, copy) NSString *locationinfo;
@property (nonatomic, copy) NSString *modulename;
@property (nonatomic, strong) NSArray<NSString *> *moduleid;
@property (nonatomic, copy) NSString *modulecontent;
@property (nonatomic, copy) NSString *devcontent;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, strong) LinkageDevices *linkagedevices;
//@property (nonatomic, copy) NSString *templateid;

@end
