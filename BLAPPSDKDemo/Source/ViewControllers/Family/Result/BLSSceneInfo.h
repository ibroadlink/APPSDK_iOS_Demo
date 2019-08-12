//
//  BLSSceneInfo.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/20.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLSSceneDevContent : NSObject

@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSArray *cmdParamList;
@property (nonatomic, assign)NSUInteger delay;

@end

@interface BLSSceneDev : NSObject

@property (nonatomic, copy)NSString *endpointId;
@property (nonatomic, copy)NSString *gatewayId;
@property (nonatomic, copy)NSString *content;
@property (nonatomic, assign)NSInteger order;

@end


@interface BLSSceneInfo : NSObject

@property (nonatomic, copy)NSString *sceneId;
@property (nonatomic, copy)NSString *friendlyName;
@property (nonatomic, copy)NSString *icon;
@property (nonatomic, copy)NSString *familyId;
@property (nonatomic, assign)NSInteger order;
@property (nonatomic, copy)NSString *extend;
@property (nonatomic, copy)NSArray *scenedev;

@end

NS_ASSUME_NONNULL_END
