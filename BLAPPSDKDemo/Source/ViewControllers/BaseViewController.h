//
//  BaseViewController.h
//  BLDNAKitTool
//
//  Created by junjie.zhu on 16/6/15.
//  Copyright © 2016年 Broadlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BLLetBase/BLLetBase.h>
#import <BLLetCore/BLLetCore.h>
#import "Tools.h"

@interface BaseViewController : UIViewController

- (void)showIndicatorOnWindow;
- (void)showIndicatorOnWindowWithMessage:(NSString *)message;
- (void)hideIndicatorOnWindow;
- (void)showTextOnly:(NSString *)text;

- (void)setExtraCellLineHidden:(UITableView *)tableView;

/// 在后台执行 block，主线程自动隐藏 HUD；可选自动展示 HUD
- (void)runInBackgroundWithHUD:(nullable NSString *)message
                         block:(void (^)(void))block
                    completion:(nullable void (^)(void))completion;

/// 统一 TextField 收起键盘
- (void)resignFirstResponderForTextFields:(NSArray<UITextField *> *)fields;

@end
