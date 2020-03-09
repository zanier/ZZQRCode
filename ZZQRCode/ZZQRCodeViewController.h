//
//  ZZQRCodeViewController.h
//  AQTQRCode
//
//  Created by zz on 2019/11/1.
//  Copyright © 2019 zz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZZQRCodeViewController : UIViewController

/// 扫描结果回调，通过`startScan()`重新开始扫描
@property (nonatomic, copy) void (^didReadQRCode)(NSString *string, void(^startScan)(void));

@end

NS_ASSUME_NONNULL_END
