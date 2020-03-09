//
//  ZZQRCodeUtil.h
//  AQTQRCode
//
//  Created by zz on 2019/10/30.
//  Copyright © 2019 杭州电梯安全通. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

#ifndef kScreenWidth
#define kScreenWidth ([[UIScreen mainScreen] bounds].size.width)
#endif

#ifndef kScreenHeight
#define kScreenHeight ([[UIScreen mainScreen] bounds].size.height)
#endif

#ifndef AVCaptureDeviceLock
#define AVCaptureDeviceLock \
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];\
    [captureDevice lockForConfiguration:nil];
#endif

#ifndef AVCaptureDeviceUnLock
#define AVCaptureDeviceUnLock \
    [captureDevice unlockForConfiguration];
#endif

@interface ZZQRCodeUtil : NSObject

/// 默认的识别格式，支持二维码扫描和条形码扫描
+ (NSArray *)defaultMetadataObjectTypes;

/// 闪光灯是否开启
+ (BOOL)isLightActive;
/// 开始闪光灯 📸
+ (void)openFlashLight;
/// 关闭闪光灯 📷
+ (void)closeFlashLight;

/// 相机使用权限
+ (AVAuthorizationStatus)avAuthStatus;
/// 是否拥有相机使用权限
+ (BOOL)isAVAuthorized;
/// 请求获取相机使用权限
+ (void)requestAVAuthorization:(void (^)(BOOL granted))handler;

/// 相册使用权限
+ (PHAuthorizationStatus)phAuthStatus;
/// 是否拥有相册使用权限
+ (BOOL)isPHAuthorized;
/// 请求获取相机使用权限
+ (void)requestPHAuthorization:(void (^)(BOOL granted))handler;

+ (BOOL)isAvailable;

+ (NSBundle *)bundle;

/// 坐标转换为比例
/// * 坐标需转换为横屏坐标，即将设备逆时针旋转90°，左上角为起点
/// * (kScreenWidth / 2, 0, kScreenWidth / 2, kScreenHeight) ->
/// * (0.000000, 0.000000, 1.000000, 0.500000)
+ (CGRect)outputRectOfInterestWithArea:(CGRect)area;

/// 识别图片中的二维码
+ (NSArray<NSString *> *)detectQRCodeWithImage:(UIImage *)image;

/// 生成普通的二维码
/// @param string 字符串
/// @param size 图片大小
+ (UIImage *)generateQRCodeImageWithString:(NSString *)string size:(CGFloat)size;

/// 生成普通的带 logo 的二维码
/// @param string 字符串
/// @param size 图片大小
/// @param logo logo 图片
+ (UIImage *)generateNormalLogoQRCodeImageWithString:(NSString *)string size:(CGFloat)size logo:(UIImage *)logo;

/// 生成二维码
/// @param string 字符串
/// @param size 图片大小
/// @param foregroundColor 前景颜色
/// @param backgroundColor 背景颜色
+ (UIImage *)generateQRCodeImageWithString:(NSString *)string size:(CGFloat)size foregroundColor:(UIColor *)foregroundColor backgroundColor:(UIColor *)backgroundColor;

/// 生成带 logo 的二维码
/// @param string 字符串
/// @param size 图片大小
/// @param foregroundColor 颜色
/// @param backgroundColor 背景颜色
/// @param logo logo 图片
/// @param ratio logo 图片相对整体的比例
/// @param radius logo 边框圆角
/// @param borderWidth logo 边框宽度
/// @param borderColor logo 边框颜色
+ (UIImage *)generateLogoQRCodeImageWithString:(NSString *)string size:(CGFloat)size foregroundColor:(UIColor *)foregroundColor backgroundColor:(UIColor *)backgroundColor logo:(UIImage *)logo ratio:(CGFloat)ratio radius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

@end

NS_ASSUME_NONNULL_END
