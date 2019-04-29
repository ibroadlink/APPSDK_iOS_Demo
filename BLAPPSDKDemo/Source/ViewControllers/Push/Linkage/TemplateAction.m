//
//  TemplateAction.m
//  ihc
//
//  Created by Stone on 2018/3/9.
//  Copyright © 2018年 broadlink. All rights reserved.
//

#import "TemplateAction.h"


@implementation ActionInfo

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
@end

@implementation TemplateAction

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end
