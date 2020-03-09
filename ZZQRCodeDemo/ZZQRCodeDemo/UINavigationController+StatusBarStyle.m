//
//  UINavigationController+StatusBarStyle.m
//  ZZQRCodeDemo
//
//  Created by ZZ on 2019/12/15
//  Copyright © 2019 zz. All rights reserved.
//

#import "UINavigationController+StatusBarStyle.h"

@implementation UINavigationController (StatusBarStyle)

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.visibleViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.visibleViewController;
}

@end
