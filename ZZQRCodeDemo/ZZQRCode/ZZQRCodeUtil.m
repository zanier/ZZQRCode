//
//  ZZQRCodeUtil.m
//  AQTQRCode
//
//  Created by zz on 2019/10/30.
//  Copyright © 2019 杭州电梯安全通. All rights reserved.
//

#import "ZZQRCodeUtil.h"
#import <AVFoundation/AVFoundation.h>

@implementation ZZQRCodeUtil

/// MARK: - 相机使用权限

/// 相机是否可用
+ (BOOL)isAvailable {
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!captureDevice) return NO;
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!deviceInput || error) return NO;
    return YES;
}

/// 相机使用权限
+ (AVAuthorizationStatus)avAuthStatus {
    return [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];;
}

/// 是否拥有相机使用权限
+ (BOOL)isAVAuthorized {
    return ([self avAuthStatus] == AVAuthorizationStatusAuthorized);
}

/// 请求获取相机使用权限
///
/// @param handler 请求结束的回调
/// * granted: 是否获得相机使用权限
+ (void)requestAVAuthorization:(void (^)(BOOL granted))handler {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:handler];
}

/// MARK: - 相册使用权限

/// 相册使用权限
+ (PHAuthorizationStatus)phAuthStatus {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!device) return PHAuthorizationStatusNotDetermined;
    return PHPhotoLibrary.authorizationStatus;
}

/// 是否拥有相册使用权限
+ (BOOL)isPHAuthorized {
    return ([self phAuthStatus] == PHAuthorizationStatusAuthorized);
}

/// 请求获取相机使用权限
///
/// @param handler 请求结束的回调
/// * granted: 是否获得相机使用权限
+ (void)requestPHAuthorization:(void (^)(BOOL granted))handler {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (handler) {
            handler(status == PHAuthorizationStatusAuthorized);
        }
    }];
}

//+ (void)setVideoScale:(CGFloat)scale {
//    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
//    [_input.device lockForConfiguration:nil];
//    
//    //获取放大最大倍数
//    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
//    CGFloat maxScaleAndCropFactor = ([[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor])/16;
//    
//    if (scale > maxScaleAndCropFactor)
//        scale = maxScaleAndCropFactor;
//    
//    CGFloat zoom = scale / videoConnection.videoScaleAndCropFactor;
//    
//    videoConnection.videoScaleAndCropFactor = scale;
//    
//    [_input.device unlockForConfiguration];
//    
//    CGAffineTransform transform = _videoPreView.transform;
//    [CATransaction begin];
//    [CATransaction setAnimationDuration:.025];
//    
//     _videoPreView.transform = CGAffineTransformScale(transform, zoom, zoom);
//    
//    [CATransaction commit];
//
//    
//    
//    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//    [captureDevice lockForConfiguration:nil];
//    
//    AVCaptureConnection *connection = [];
//    
//    [captureDevice unlockForConfiguration];
//
//}
 

/// MARK: - 闪光灯
/// 闪光灯是否开启
+ (BOOL)isLightActive {
    BOOL isLightActive = NO;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([captureDevice hasTorch]) {
        [captureDevice lockForConfiguration:nil];
        isLightActive = [captureDevice isTorchActive];
        [captureDevice unlockForConfiguration];
    }
    return isLightActive;
}

/// 开始闪光灯 📸
+ (void)openFlashLight {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        if ([captureDevice hasTorch]) {
            BOOL locked = [captureDevice lockForConfiguration:&error];
            if (locked) {
                [captureDevice setTorchMode:AVCaptureTorchModeOn];
                [captureDevice unlockForConfiguration];
            }
        }
    });
}

/// 关闭闪光灯 📷
+ (void)closeFlashLight {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([captureDevice hasTorch]) {
            [captureDevice lockForConfiguration:nil];
            [captureDevice setTorchMode:AVCaptureTorchModeOff];
            [captureDevice unlockForConfiguration];
        }
    });
}

/// MARK: - Managing the Orientation
+ (AVCaptureVideoOrientation)videoOrientationFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
        default:
            return AVCaptureVideoOrientationPortraitUpsideDown;
    }
}

/// 坐标转换为比例
/// * 坐标需转换为横屏坐标，即将设备逆时针旋转90°，左上角为起点
/// * (kScreenWidth / 2, 0, kScreenWidth / 2, kScreenHeight) ->
/// * (0.000000, 0.000000, 1.000000, 0.500000)
+ (CGRect)outputRectOfInterestWithArea:(CGRect)area {
    return CGRectMake(CGRectGetMinY(area) / kScreenHeight,
                      (kScreenWidth - CGRectGetMaxX(area)) / kScreenWidth,
                      CGRectGetHeight(area) / kScreenHeight,
                      CGRectGetWidth(area) / kScreenWidth);
}

/// 缩小尺寸比较大的图片
+ (UIImage *)zlqr_resizeImage:(UIImage *)image {
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    if (imageWidth <= kScreenWidth && imageHeight <= kScreenHeight) {
        return image;
    }
    CGFloat max = MAX(imageWidth, imageHeight);
    CGFloat scale = max / (kScreenHeight * 2.0);
    CGSize size = CGSizeMake(imageWidth / scale, imageHeight / scale);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/// 识别图片中的二维码
+ (NSArray<NSString *> *)detectQRCodeWithImage:(UIImage *)image {
    // 若图片尺寸过大则压缩图片
    UIImage *resizedIamge = [self zlqr_resizeImage:image];
    // CIDetector(CIDetector可用于人脸识别)进行图片解析，从而使我们可以便捷的从相册中获取到二维码
    // 声明一个 CIDetector，并设定识别类型 CIDetectorTypeQRCode
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                              context:nil
                                              options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    // 取得识别结果
    NSArray<CIFeature *> *features = [detector featuresInImage:[CIImage imageWithCGImage:resizedIamge.CGImage]];
    NSMutableArray *results = [NSMutableArray array];
    [features enumerateObjectsUsingBlock:^(CIFeature * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CIQRCodeFeature *feature = (CIQRCodeFeature *)obj;
        [results addObject:feature.messageString];
    }];
    return results;
}

/// 生成普通的二维码
/// @param string 字符串
/// @param size 图片大小
+ (UIImage *)generateQRCodeImageWithString:(NSString *)string size:(CGFloat)size {
    return [self generateQRCodeImageWithString:string size:size foregroundColor:UIColor.blackColor backgroundColor:UIColor.whiteColor];
}

/// 生成普通的带 logo 的二维码
/// @param string 字符串
/// @param size 图片大小
/// @param logo logo 图片
+ (UIImage *)generateNormalLogoQRCodeImageWithString:(NSString *)string size:(CGFloat)size logo:(UIImage *)logo {
    return [self generateLogoQRCodeImageWithString:string size:size foregroundColor:UIColor.blackColor backgroundColor:UIColor.whiteColor logo:logo ratio:0.25 radius:0.5 borderWidth:0.5 borderColor:UIColor.whiteColor];
}

/// 生成二维码
/// @param string 字符串
/// @param size 图片大小
/// @param foregroundColor 前景颜色
/// @param backgroundColor 背景颜色
+ (UIImage *)generateQRCodeImageWithString:(NSString *)string size:(CGFloat)size foregroundColor:(UIColor *)foregroundColor backgroundColor:(UIColor *)backgroundColor {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    // 1. 二维码滤镜
    CIFilter *datafilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [datafilter setValue:data forKey:@"inputMessage"];
    [datafilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    CIImage *ciImage = datafilter.outputImage;
    // 2. 颜色滤镜
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"];
    [colorFilter setValue:ciImage forKey:@"inputImage"];
    [colorFilter setValue:[CIColor colorWithCGColor:foregroundColor.CGColor] forKey:@"inputColor0"];
    [colorFilter setValue:[CIColor colorWithCGColor:backgroundColor.CGColor] forKey:@"inputColor1"];
    // 3. 生成处理
    CIImage *outImage = colorFilter.outputImage;
    CGFloat scale = size / outImage.extent.size.width;
    outImage = [outImage imageByApplyingTransform:CGAffineTransformMakeScale(scale, scale)];
    return [UIImage imageWithCIImage:outImage];
}

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
+ (UIImage *)generateLogoQRCodeImageWithString:(NSString *)string size:(CGFloat)size foregroundColor:(UIColor *)foregroundColor backgroundColor:(UIColor *)backgroundColor logo:(UIImage *)logo ratio:(CGFloat)ratio radius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
    // 1. 生成普通二维码图片
    UIImage *image = [self generateQRCodeImageWithString:string size:size foregroundColor:foregroundColor backgroundColor:backgroundColor];
    if (!logo) return image;
    // 2. 计算尺寸
    if (ratio < 0 || ratio > 0.5) ratio = 0.25;
    if (radius < 0 || radius > 10) radius = 5;
    if (borderWidth < 0 || borderWidth > 10) borderWidth = 5;
    CGFloat logoW = ratio * size;
    CGFloat logoH = logoW;
    CGFloat logoX = (image.size.width - logoW) * 0.5;
    CGFloat logoY = (image.size.height - logoH) * 0.5;
    CGRect logoRect = CGRectMake(logoX, logoY, logoW, logoH);
    // 3. 绘制 logo
    UIGraphicsBeginImageContextWithOptions(image.size, false, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:logoRect cornerRadius:radius];
    path.lineWidth = borderWidth;
    [borderColor setStroke];
    [path stroke];
    [path addClip];
    [logo drawInRect:logoRect];
    UIImage *qrCodeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return qrCodeImage;
}

/// MARK: - 默认的识别格式
+ (NSArray *)defaultMetadataObjectTypes {
    return @[
             AVMetadataObjectTypeQRCode,
             AVMetadataObjectTypeEAN13Code,
             AVMetadataObjectTypeEAN8Code,
             AVMetadataObjectTypeCode128Code,
             ];
}

/// MARK: -
+ (NSBundle *)bundle {
    // 静态库 url 的获取
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"ZZQRCode" withExtension:@"bundle"];
    if (!url) {
        // 动态库 url 的获取
        url = [[NSBundle bundleForClass:[self class]] URLForResource:@"ZZQRCode" withExtension:@"bundle"];
    }
    return [NSBundle bundleWithURL:url];
}

@end

/*
static inline CGPoint BXQRCodeLandscapeRightPointFromPortraitPoint(CGPoint portraitPoint) {
    return CGPointMake(portraitPoint.y, (kScreenWidth - portraitPoint.x));
}

static inline CGPoint BXQRCodePortraitPointFromLandscapeRightPoint(CGPoint landscapeRightPoint) {
    return CGPointMake((kScreenWidth - landscapeRightPoint.y), landscapeRightPoint.x);
}

static inline CGPoint BXQRCodeProportionPointWithPoint(CGPoint point, CGSize inSize) {
    return CGPointMake(point.x / inSize.width, point.y / inSize.height);
}

static inline CGPoint BXQRCodePointWithProportionPoint(CGPoint pointWithPoint, CGSize inSize) {
    return CGPointMake(pointWithPoint.x * inSize.width, pointWithPoint.y * inSize.height);
}

static inline CGRect BXQRCodeLandscapeRightRectFromPortraitRect(CGRect portraitRect) {
    return CGRectMake(CGRectGetMinY(portraitRect),
                      (kScreenWidth - CGRectGetWidth(portraitRect) - CGRectGetMinX(portraitRect)),
                      CGRectGetHeight(portraitRect),
                      CGRectGetWidth(portraitRect));
}

static inline CGRect BXQRCodePortraitRectFromLandscapeRightRect(CGRect landscapeRightRect) {
    return CGRectMake((kScreenHeight - CGRectGetHeight(landscapeRightRect) - CGRectGetMinY(landscapeRightRect)),
                      CGRectGetMinX(landscapeRightRect),
                      CGRectGetHeight(landscapeRightRect),
                      CGRectGetWidth(landscapeRightRect));
}

static inline CGRect BXQRCodeProportionRectWithRect(CGRect rect, CGRect inRect) {
    return CGRectMake(CGRectGetMinX(rect) / CGRectGetWidth(inRect),
                      CGRectGetMinY(rect) / CGRectGetHeight(inRect),
                      CGRectGetWidth(rect) / CGRectGetWidth(inRect),
                      CGRectGetHeight(rect) / CGRectGetHeight(inRect));
}

static inline CGRect BXQRCodeRectWithProportionRect(CGRect proportionRect, CGRect inRect) {
    return CGRectMake(CGRectGetMinX(proportionRect) * CGRectGetWidth(inRect),
                      CGRectGetMinY(proportionRect) * CGRectGetHeight(inRect),
                      CGRectGetWidth(proportionRect) * CGRectGetWidth(inRect),
                      CGRectGetHeight(proportionRect) * CGRectGetHeight(inRect));
}
*/
