//
//  BLlinkageInfo.m
//  ihc
//
//  Created by Stone on 2018/3/16.
//  Copyright © 2018年 broadlink. All rights reserved.
//

#import "LinkageInfo.h"
@implementation ModuleDevice

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation LinkageDevices

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

+ (NSDictionary *)BLS_modelCustomPropertyMapper {
    
    return @{
             @"moduleid" : @"moduleid",
             @"did" : @"did",
             @"externStr" : @"extern",
             @"linkagetype" : @"linkagetype",
             @"userid" : @"userid",
             @"familyid" : @"familyid",
             @"version" : @"version",
             @"roomid" : @"roomid",
             @"name" : @"name",
             @"icon" : @"icon",
             @"flag" : @"flag",
             @"moduledev" : @"moduledev",
             @"order" : @"order",
             @"moduletype" : @"moduletype",
             @"scenetype" : @"scenetype",
             @"followdev" : @"followdev",
             @"extend" : @"extend"
             };
}

@end


@implementation LinkageInfo

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end
