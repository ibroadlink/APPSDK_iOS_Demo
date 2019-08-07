// BLLinkageTemplate.m

#import "LinkageTemplate.h"



NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private model interfaces


@implementation LinkageTemplate

+ (NSDictionary *)BLS_modelContainerPropertyGenericClass {
    
    return @{
             @"linkages":[Linkage class]
             };
}

@end

@implementation Linkage



@end

@implementation Linkagedevices

+ (NSDictionary *)BLS_modelCustomPropertyMapper {
    
    return @{
             @"linkagedevicesExtern": @"extern",
             };
}


@end

NS_ASSUME_NONNULL_END
