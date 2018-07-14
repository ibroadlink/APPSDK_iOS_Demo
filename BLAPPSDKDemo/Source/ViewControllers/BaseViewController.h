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

@interface BaseViewController : UIViewController

- (void)showIndicatorOnWindow;

- (void)showIndicatorOnWindowWithMessage:(NSString *)message;

- (void)hideIndicatorOnWindow;

- (void)showTextOnly:(NSString *)text;

- (void)setExtraCellLineHidden: (UITableView *)tableView;

@end
