// BLLinkageTemplate.m

#import "BLLinkageTemplate.h"



NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private model interfaces


@implementation BLLinkageTemplate

+ (NSDictionary *)BLS_modelContainerPropertyGenericClass {
    
    return @{
             @"linkages":[BLLinkage class]
             };
}

@end

@implementation BLLinkage



@end

@implementation BLLinkagedevices

+ (NSDictionary *)BLS_modelCustomPropertyMapper {
    
    return @{
             @"linkagedevicesExtern": @"extern",
             };
}


@end

NS_ASSUME_NONNULL_END
