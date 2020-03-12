# ZZQRCode
​		通过原生API封装的二维码扫描与识别组件，可以扫描二维码、识别二维码图片、生成自定义二维码功能，并具有微信的开启闪光灯、镜头缩放等功能。 

## 使用前

在项目的 info.plist 中添加权限申请的描述字段：

| key                                                 | value              |
| :-------------------------------------------------- | ------------------ |
| Privacy - Camera Usage Description                  | 是否允许使用相机？ |
| Privacy - Photo Library Additions Usage Description | 是否允许访问相册？ |
| Privacy - Photo Library Usage Description           | 是否允许写入相册？ |

## 实现功能

- [x] 二维码扫描
- [x] 二维码生成
- [x] 带logo的二维码生成
- [x] 自定义扫描区域
- [x] 点击拉近镜头
- [x] 根据光暗提示开灯
- [x] 申请与判断权限

## TODO

- [ ] 自定义界面设置
- [ ] 根据二维码大小自动伸缩拉近镜头
- [ ] 横屏的适配
- [ ] 条形码的适配
- [ ] 彩色二维码的生成
- [ ] 字符串国际化

## 使用

**ZZQRCodeUtil.h** 

该文件封装了二维码相关的方法，如权限控制、二维码生成等方法。可根据需要导入使用。

```objective-c
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
```

**ZZQRCodeReaderView**

二维码的扫描图像界面，内部通过 **ZZQRCodeReader** 实现扫描和显示能能，自身可当做普通的 **UIView** 来使用。

```objective-c
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
```

使用示例：

```objective-c
ZZQRCodeReaderView *readerView = [ZZQRCodeReaderView QRCodeReaderViewWithFrame:self.view.bounds];
__weak typeof(self) weakSelf = self;
[readerView setHandler:^(NSString * _Nullable string, ZZQRCodeReaderView * _Nonnull readerView) {
		[weakSelf readerView:readerView didReadCode:string];
}];
[self.view addSubview:readerView];
```

**ZZQRCodeViewController.h**

内部添加了 **ZZQRCodeReaderView** 的仿微信扫描二维码的视图控制器，可直接使用或子类化添加自定义功能。目前只提供了一个接口，若不满足需求，可根据该界面逻辑通过 **ZZQRCodeReaderView** 重新创建试图控制器。

```objective-c
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZZQRCodeViewController : UIViewController

/// 扫描结果回调，通过`startScan()`重新开始扫描
@property (nonatomic, copy) void (^didReadQRCode)(NSString *string, void(^startScan)(void));

@end

NS_ASSUME_NONNULL_END
```

## 截图：

<img src="https://github.com/dearxiaomu/ZZQRCode/blob/master/Screenshots/IMG_1877.PNG" width="30%"><img src="https://github.com/dearxiaomu/ZZQRCode/blob/master/Screenshots/IMG_1878.PNG" width="30%"><img src="https://github.com/dearxiaomu/ZZQRCode/blob/master/Screenshots/IMG_1879.PNG" width="30%"><img src="https://github.com/dearxiaomu/ZZQRCode/blob/master/Screenshots/IMG_1881.PNG" width="30%">



## 注意事项：

* 使用前注意添加 info.plist 字段，使用中注意权限状态的判断。
* 在使用某些硬件相关的 API 如闪光灯时，一定要使用系统提供的加解锁操作 `[captureDevice lockForConfiguration:nil]`。
* 保存二维码是需要先将图片绘制一次，否则无法保存，例如 Demo 中的 `GenerateQRCodeViewController.m` 中的  `saveButtonAction` 方法。
