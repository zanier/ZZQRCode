//
//  ZZQRCodeReaderView.h
//  AQTQRCode
//
//  Created by zz on 2019/10/30.
//  Copyright © 2019 zz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZZQRCodeReaderView : UIView

/// 创建二维码扫描界面
+ (instancetype)QRCodeReaderViewWithFrame:(CGRect)frame;

/// 初始化扫描界面
/// @param frame 界面 frame
/// @param area 扫描区域，传入 CGRectZero 则设置为默认的区域
/// @param types 扫码的类型
/// @param handler 扫码的回调
- (instancetype)initWithFrame:(CGRect)frame scanArea:(CGRect)area scanTypes:(nullable NSArray<AVMetadataObjectType> *)types handler:(nullable void (^)(NSString * _Nullable string, ZZQRCodeReaderView * _Nonnull readerView))handler;

/// 扫描区域
@property (nonatomic, assign) CGRect scanArea;

/// 扫描状态
@property (readonly) BOOL isScanning;

/// 开始扫描
- (void)startScan;

/// 停止扫描
- (void)stopScan;

/// 设置扫描成功的回调
- (void)setHandler:(void (^)(NSString * _Nullable string, ZZQRCodeReaderView * _Nonnull readerView))handler;

/// 设置亮度变化的回调
- (void)setBrightnessHandler:(void (^)(CGFloat brightness, ZZQRCodeReaderView * _Nonnull readerView))handler;

@end

NS_ASSUME_NONNULL_END
