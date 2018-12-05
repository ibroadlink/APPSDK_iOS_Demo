//
//  Picker.h
//  BLAppApi
//
//  Created by milliwave-Zs on 16/2/22.
//  Copyright © 2016年 broadlink. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <BLLetBase/BLLetBase.h>

@interface BLPicker : NSObject

@property (nonatomic, strong) NSString *userId;

@property (nonatomic, strong) NSString *license;

+ (instancetype)sharedPickerWithLicenseId:(NSString *)licenseId License:(NSString *)license;

+ (instancetype _Nullable)sharedPicker;
/**
 开启数据统计上报模块
 */
- (void)startPick;

/*  追踪页面的开始时间，配合trackPageEnd可以得到页面实际停留时间
 *  该接口需要在viewWillAppear或者viewDidAppear中调用
 *  pageName为您自定义的页面名称，由英文／数字／下划线组成，且第一个字符不能为数字，最大64字节
 *  该接口必须与trackPageEnd成对出现，否则无法追踪停留时间,且不纪录
 */
- (void)trackPageBegin:(NSString * __nonnull)pageName;

/*  追踪页面的结束时间，配合trackPageBegin可以得到页面实际停留时间
 *  该接口需要在viewWillDisappear或者viewDidDisappear中调用
 *  pageName为您自定义的页面名称，由英文／数字／下划线组成，且第一个字符不能为数字，最大64字节
 *  该接口必须与trackPageBegin成对出现，否则无法追踪停留时间，且不记录
 */
- (void)trackPageEnd:(NSString *__nonnull)pageName;

/*  设置APP当前所在位置的经纬度
 *  设置经纬度之后，您可以更加清晰的了解用户群的所在位置
 *  若不设置该接口，则默认采用联网的IP地址来确定APP所在位置，有一定的误差存在
 */
- (void)setLatitude:(NSString *__nonnull)latitude longitude:(NSString *__nonnull)longitude;

/*  追踪自定义的事件，如购买动作
 *  eventId:    事件的名称 (自定义),不能为nil
 */
- (void)trackEvent:(NSString * __nonnull)eventId;

/*  追踪带有标签的事件，如购买broadlink的产品
 *  eventId:    事件的名称 (自定义),不能为nil
 *  eventLabel: 事件的标签 (自定义)
 */
- (void)trackEvent:(NSString * __nonnull)eventId label:(NSString * __nullable)eventLabel;

/*  追踪带有二级参数的自定义事件，如购买broadlink的产品，并附带了购买产品的型号，价格等等
 *  eventId:    事件的名称 (自定义),不能为nil
 *  eventLabel: 事件的标签 (自定义)
 *  parameters: 事件参数   (key与value都只支持NSString)
 */
- (void)trackEvent:(NSString * __nonnull)eventId label:(NSString *__nullable)eventLabel parameters:(NSDictionary *__nullable)parameters;

/**
 追踪错误信息

 @param err 错误码
 @param msg 错误信息
 @param function 对应功能函数
 @param externData 扩展信息
 */
- (void)trackErrorWithErrorNo:(NSInteger)err msg:(NSString * __nonnull)msg function:(NSString * __nonnull)function externData:(NSDictionary *__nullable)externData;

/*  结束追踪并上报数据
 *  App请合理安排上报的时间点，若上报不成功，则下次会一起上报。
 *  数据上报未出错时，error为nil。
 */
- (void)finish:( nullable void (^)(NSData * __nonnull data, NSError * __nullable error) )result;
@end
