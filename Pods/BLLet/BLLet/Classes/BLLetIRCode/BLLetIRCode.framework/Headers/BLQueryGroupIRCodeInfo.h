//
//  BLQueryGroupIRCodeInfo.h
//  BLLetIRCode
//
//  Created by hongkun.bai on 2018/11/2.
//  Copyright © 2018 hongkun.bai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLIRDataInfo.h"

@interface BLQueryGroupIRCodeInfo : NSObject
@property (nonatomic, strong) NSString *endpointId;
@property (nonatomic, strong) NSString *codeDesc;
@property (nonatomic, strong) NSMutableArray<BLIRDataInfo*> *irData;
@end



