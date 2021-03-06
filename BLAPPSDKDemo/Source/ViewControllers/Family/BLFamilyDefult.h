//
//  BLSFamilyManager.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/19.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BLSFamily/BLSFamily.h>


NS_ASSUME_NONNULL_BEGIN

@interface BLFamilyDefult : NSObject

@property (nonatomic, strong)BLSFamilyInfo *currentFamilyInfo;
@property (nonatomic, strong)BLSEndpointInfo *currentEndpointInfo;
@property (nonatomic, copy)NSArray *endpointList;
@property (nonatomic, copy)NSArray *roomList;

+ (instancetype)sharedFamily;


@end

NS_ASSUME_NONNULL_END
