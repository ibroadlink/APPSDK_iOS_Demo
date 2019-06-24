// BLTemplate.m

#import "BLTemplate.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private model interfaces

@implementation BLTemplate

+ (NSDictionary *)BLS_modelContainerPropertyGenericClass {
    
    return @{
             @"templates":[BLTemplateElement class]
             };
}

@end

@implementation BLTemplateElement

+ (NSDictionary *)BLS_modelContainerPropertyGenericClass {
    
    return @{
             @"events":[BLEvent class],
             @"templatename":[BLTemplatename class],
             @"action":[BLAction class]
             };
}

@end

@implementation BLAction

@end

@implementation BLAlicloud

@end

@implementation BLMail

@end

@implementation BLConditionsinfo

@end

@implementation BLEvent

@end

@implementation BLTemplatename

@end

NS_ASSUME_NONNULL_END
