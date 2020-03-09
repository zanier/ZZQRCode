//
//  ZZQRCodeReader.h
//  AQTQRCode
//
//  Created by zz on 2019/10/30.
//  Copyright © 2019 zz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZZQRCodeReader : NSObject

/// 初始化方法
+ (instancetype)readerWithMetadataObjectTypes:(NSArray *)metadataObjectTypes delegate:(id<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>)delegate;

// 设置扫描区域
@property (nonatomic, assign) CGRect scanArea;

/// 当前的识别格式
@property (nonatomic, strong) NSArray<AVMetadataObjectType> *metadataObjectTypes;

/// 预览层
@property (readonly) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, weak) id<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> delegate;

/// 扫描状态
@property (readonly) BOOL isScanning;

/// 设置镜头的缩放系数
@property (readonly) CGFloat videoZoomFactor;
- (void)setVideoZoomFactor:(CGFloat)factor;
- (void)changeVideoZoomFactor;

/// 开始扫描
- (void)startScan;
/// 停止扫描
- (void)stopScan;

@end

NS_ASSUME_NONNULL_END
