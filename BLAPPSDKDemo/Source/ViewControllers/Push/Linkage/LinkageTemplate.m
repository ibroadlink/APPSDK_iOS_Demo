//
//  LinkageTemplate.m
//  ihc
//
//  Created by Stone on 2018/3/9.
//  Copyright © 2018年 broadlink. All rights reserved.
//

#import "LinkageTemplate.h"

@implementation TemplateName

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
@end

@implementation TemplateEvent

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
@end


@implementation LinkageTemplate

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end
