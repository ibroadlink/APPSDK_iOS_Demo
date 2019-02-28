//
//  BLProductCategoryModel.h
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/2/26.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,BLBrandDevType) {
    BLBrandDevTypeOther = 0,//其他
    BLBrandDevTypeTV = 1,//电视
    BLBrandDevTypeTopBox,//机顶盒
    BLBrandDevTypeCloudAC,//云空调
    BLBrandDevTypeCloudCurtain,//云电机
    BLBrandDevTypeSwitch,//灯控开关
    BLBrandDevTypeLamp,//遥控灯
    BLBrandDevTypeDoor,//遥控门
    BLBrandDevTypeLockstitch,//遥控锁
    BLBrandDevTypeFan,//风扇
    BLBrandDevTypeSmartTopBox = 10,//智能电视盒子
    BLBrandDevTypeProjector,//投影仪
    BLBrandDevTypeLoudspeakerBox,//音响
    BLBrandDevTypeAutoDoor,//自动门
    BLBrandDevTypePowerAmplifier,//功放
    BLBrandDevTypeDVD = 15,//DVD播放机
    BLBrandDevTypeAirCleaner,//空气净化器
};

@interface BLProductCategoryModel : NSObject

@property (nonatomic, copy) NSString *categoryid;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *product;
@property (nonatomic, strong) NSNumber *rank;
@property (nonatomic, assign) BLBrandDevType devType;//用于下载品牌

@end
NS_ASSUME_NONNULL_END
