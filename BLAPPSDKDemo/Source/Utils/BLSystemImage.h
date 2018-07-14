//
//  getSystemImage.h
//  e-Control4
//
//  Created by milliwave-Zs on 15/5/5.
//  Copyright (c) 2015年 broadlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef void (^getSystemImageBlack)(UIImage *image);

@interface BLSystemImage : NSObject <UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    getSystemImageBlack imageblack;
    BOOL allowsEditing;
    UIViewController *controller;
}
-(void) getImageWithActionSheetAllowsEditing:(BOOL)editing showGallery:(BOOL)showGallery inViewController:(UIViewController*)viewController block:(getSystemImageBlack) black;
@end
