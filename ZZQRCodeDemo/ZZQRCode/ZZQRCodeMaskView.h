//
//  ZZQRCodeMaskView.h
//  AQTQRCode
//
//  Created by zz on 2019/10/31.
//  Copyright © 2019 杭州电梯安全通. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZZQRCodeMaskView : UIView

/// 扫描区域
@property (nonatomic, assign) CGRect scanArea;
/// 扫描线动画时间，默认 2s
@property (nonatomic, assign) NSTimeInterval duration;
/// 边角宽度，默认 2.f
@property (nonatomic, assign) CGFloat cornerWidth;
/// 扫描区周边颜色的 alpha 值，默认 0.2f
@property (nonatomic, assign) CGFloat backgroundAlpha;
/// 边框颜色，默认 white
@property (nonatomic, strong) UIColor *borderColor;
/// 边角颜色，默认微信绿色
@property (nonatomic, strong) UIColor *cornerColor;
/// 开始定时器动画
- (void)startScanAnimation;
/// 停止定时器动画
- (void)stopScanAnimation;
/// 闪光灯按钮
@property (readonly) UIButton *lightButton;
/// 显示闪光灯按钮
- (void)showLightButton;
/// 隐藏闪光灯按钮
- (void)hideLightButton;

@end

NS_ASSUME_NONNULL_END
