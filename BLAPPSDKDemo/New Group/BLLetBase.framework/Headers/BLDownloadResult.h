//
//  DownloadResult.h
//  Let
//
//  Created by yzm on 16/5/17.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

@interface BLDownloadResult : BLBaseResult

/**
 Download file store path
 */
@property (nonatomic, strong, getter=getSavePath) NSString *savePath;

@end
