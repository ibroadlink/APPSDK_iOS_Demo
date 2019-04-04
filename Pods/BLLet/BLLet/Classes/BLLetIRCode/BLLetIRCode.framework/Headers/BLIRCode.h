//
//  BLIRCodeData.h
//  Let
//
//  Created by 白洪坤 on 2017/10/10.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BLLetBase/BLLetBase.h>


@interface BLIRCode : NSObject

/**
 Get BLIRCode Object

 @return Object
 */
+ (nullable instancetype)sharedIrdaCode;

/**
 Start RM New Sub Device Work, add some block into sdk.
 */
- (void)startRMSubDeviceWork;

/**
 IRService common request
 
 @param urlPath urlPath
 @param head head
 @param body body
 @param completionHandler completionHandler
 */
- (void)commonIRServiceRequestWith:(NSString *_Nonnull)urlPath head:(NSDictionary *_Nullable)head body:(NSDictionary *_Nullable)body completionHandler:(nullable void (^)(BLBaseBodyResult * _Nonnull result))completionHandler;
/**
 Query all support ircode device types. Like AC, TV, STB ...
 
 @param completionHandler   Callback with query result
 */
- (void)requestIRCodeDeviceTypesCompletionHandler:(nullable void (^)(BLBaseBodyResult * _Nonnull result))completionHandler;

/**
 Query all support ircode device brands with type.
 
 @param deviceType          Device type ID
 @param completionHandler   Callback with query result
 */
- (void)requestIRCodeDeviceBrandsWithType:(NSUInteger)deviceType completionHandler:(nullable void (^)(BLBaseBodyResult * _Nonnull result))completionHandler;

/**
 Query ircode download url with type and brand and verison.
 
 @param deviceType          Device type ID
 @param deviceBrand         Device brand ID
 @param completionHandler   Callback with query result with download url and randkey
 */
- (void)requestIRCodeScriptDownloadUrlWithType:(NSUInteger)deviceType brand:(NSUInteger)deviceBrand completionHandler:(nullable void (^)(BLBaseBodyResult * _Nonnull result))completionHandler;

/**
 Query ircode download url with type and brand and verison. Download file is gz.
 
 @param deviceType          Device type ID
 @param deviceBrand         Device brand ID
 @param completionHandler   Callback with query result with download url and randkey
 */
- (void)requestIRCodeCloudScriptDownloadUrlWithType:(NSUInteger)deviceType brand:(NSUInteger)deviceBrand completionHandler:(nullable void (^)(BLBaseBodyResult * _Nonnull result))completionHandler;

/**
 Query ircode download url with recognize ircode hex string.
 Only support AC ircode.
 
 @param hexString           ircode hex string
 @param completionHandler   Callback with query result
 */
- (void)recognizeIRCodeWithHexString:(NSString *_Nonnull)hexString completionHandler:(nullable void (^)(BLBaseBodyResult * _Nonnull result))completionHandler;

/**
 Gets the list of regions under the specified region ID
 if ID = 0, get all countries‘ ids
 if isleaf = 0, you need call this interface again to get the list of regions.
 if isleaf = 1, don't need get again.
 
 @param locateid            Region ID
 @param completionHandler   Callback with response includes {subArea ID, isleaf}
 */
- (void)requestSubAreaWithLocateid:(NSUInteger)locateid completionHandler:(nullable void (^)(BLBaseBodyResult * _Nonnull result))completionHandler;

/**
 Get the details of the specified region ID
 
 @param locateid            Region ID
 @param completionHandler   Callback with detail infos
 */
- (void)requestAreaInfoWithLocateid:(NSUInteger)locateid completionHandler:(nullable void (^)(BLBaseBodyResult * _Nonnull result))completionHandler;

/**
 Get a list of set-top box providers
 
 @param locateid            Region ID
 @param completionHandler   Callback with provider ids
 */
- (void)requestSTBProviderWithLocateid:(NSUInteger)locateid completionHandler:(nullable void (^)(BLBaseBodyResult * _Nonnull result))completionHandler;


/**
 Get a list of set-top box brands

 @param completionHandler Callback with brand infos
 */
- (void)requestSTBBrandsWithCompletionHandler:(nullable void (^)(BLBaseBodyResult * _Nonnull result))completionHandler;

/**
 Get the set-top box ircode download URL
 
 @param locateid            Region ID
 @param providerid          Provider ID
 @param completionHandler   Callback with download url
 */
- (void)requestSTBIRCodeScriptDownloadUrlWithLocateid:(NSUInteger)locateid providerid:(NSUInteger)providerid brandId:(NSUInteger)brandId completionHandler:(nullable void (^)(BLBaseBodyResult * _Nonnull result))completionHandler;

/**
 根据地区名称机顶盒供应商列表
 
 @param country 国家
 @param province 省份
 @param city 城市
 @param completionHandler callback
 */
- (void)requestSTBProviderWithCountry:(NSString *_Nonnull)country province:(NSString *_Nonnull)province city:(NSString *_Nonnull)city completionHandler:(nullable void (^)(BLBaseBodyResult * _Nonnull result))completionHandler;

/**
 Query STB Provider Channels
 
 @param locateid 地区ID
 @param providerid 供应商ID
 @param completionHandler callback
 */
- (void)requestSTBChannelListWithLocateid:(NSUInteger)locateid providerid:(NSUInteger)providerid completionHandler:(nullable void (^)(BLBaseBodyResult * _Nonnull result))completionHandler;

/**
 Download ircode script
 
 @param urlString           Download url
 @param path                Ircode script store path
 @param randkey             Ircode script decrypted key
 @param completionHandler   Callback with Ircode script decrypted key
 */
- (void)downloadIRCodeScriptWithUrl:(NSString *_Nonnull)urlString savePath:(NSString *_Nonnull)path randkey:(NSString *_Nullable)randkey completionHandler:(nullable void (^)(BLDownloadResult * _Nonnull result))completionHandler;

/**
 Query ircode script infomation.
 This infomation include ircode support device name, ircode support operate, ircode support data range...
 
 @param script              Ircode script store path
 @return                    Callback with query result
 */
- (BLIRCodeInfoResult *_Nonnull)queryIRCodeInfomationWithScript:(NSString *_Nonnull)script deviceType:(BLIRCodeDeviceTypeEnum)deviceType;


/**
 Query AC ircode hex string
 
 @param script              Ircode script store path
 @param params              AC status to change
 @return                    Query result with ircode hex string
 */
- (BLIRCodeDataResult *_Nonnull)queryACIRCodeDataWithScript:(NSString *_Nonnull)script params:(BLQueryIRCodeParams *_Nonnull)params;

/**
 waveCode Change To UnitCode

 @param waveCode waveCode
 @return UnitCode
 */
- (NSString *_Nullable)waveCodeChangeToUnitCode:(NSString *_Nonnull)waveCode;

/**
 unitCode Change To WaveCode
 
 @param unitCode unitCode
 @return WaveCode
 */
- (NSString *_Nullable)unitCodeChangeToWaveCode:(NSString *_Nonnull)unitCode;

/**
 IRCode Match Tree
 
 @param countrycode 国家码
 @param devtypeid 产品类型id
 @param brandid 品牌id
 @param completionHandler callback
 */
- (void)getMatchTreeWithCountry:(NSString *_Nonnull)countrycode devtypeid:(NSUInteger)devtypeid brandid:(NSUInteger)brandid completionHandler:(nullable void (^)(BLBaseBodyResult * _Nonnull result))completionHandler;

/**
 Download ircode script with ircode id
 
 @param ircodeid          Ircode id
 @param mtag              " ":普通红码文件,"xz":空调xz文件,"gz":空调gz文件。电视机顶盒默认为json,空调为lua,其他为脚本
 @param path              Ircode script store path
 @param completionHandler   Callback with Ircode script decrypted key
 */
- (void)downloadIRCodeScriptWithIRCodeid:(NSString *_Nonnull)ircodeid mtag:(NSString *_Nonnull)mtag savePath:(NSString *_Nonnull)path completionHandler:(nullable void (^)(BLDownloadResult * _Nonnull result))completionHandler;

@end
