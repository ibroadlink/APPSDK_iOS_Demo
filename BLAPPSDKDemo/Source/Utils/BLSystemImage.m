//
//  getSystemImage.m
//  e-Control4
//
//  Created by milliwave-Zs on 15/5/5.
//  Copyright (c) 2015年 broadlink. All rights reserved.
//

#import "BLSystemImage.h"
#import "Tools.h"

static BLSystemImage* systemImage = nil;


@interface BLSystemImage ()

@end


@implementation BLSystemImage

- (id)init {
    if (self = [super init]) {
        systemImage = self;
    }
    return self;
}

- (void)dealloc {
    controller = nil;
    imageblack = nil;
}

- (void)getImageWithActionSheetAllowsEditing:(BOOL)editing
                                 showGallery:(BOOL)showGallery
                            inViewController:(UIViewController*)viewController
                                       block:(getSystemImageBlack) black
{
    imageblack = black;
    allowsEditing = editing;
    controller = viewController;
    UIActionSheet *actionSheet = nil;
    if (showGallery) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:@"str_common_cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"str_common_take_photo", @"str_common_choose_from_photos",@"str_common_choose_from_gallery", nil];
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                         cancelButtonTitle:@"取消"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"拍照", @"从手机相册中选择", nil];
    }
    
    [actionSheet showInView:controller.view];
}

- (void)getImageWithType:(UIImagePickerControllerSourceType) sourceType {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:sourceType];
    [imagePicker setAllowsEditing:allowsEditing];
    [imagePicker setDelegate:self];
    [controller presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark -
#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *image = nil;
        if (allowsEditing) {
            image = [info objectForKey:UIImagePickerControllerEditedImage];
        } else {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        image = [Tools imageWithImage:image scaledToSize:image.size compressionQuality:0.3];
        
        if (imageblack) {
            imageblack (image);
            systemImage = nil;
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (imageblack) {
        systemImage = nil;
    }
}

#pragma mark -
#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.cancelButtonIndex == buttonIndex) {
        return;
    } else if (0 == buttonIndex) {
        [self getImageWithType:UIImagePickerControllerSourceTypeCamera];
    } else if (1 == buttonIndex) {
        [self getImageWithType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

@end
