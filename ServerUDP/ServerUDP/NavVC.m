//
//  NavVC.m
//  Instagram
//
//  Created by zcs on 2017/6/25.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import "NavVC.h"

@interface NavVC ()

@end

@implementation NavVC

- (void)viewDidLoad {
    [super viewDidLoad];
//    将导航栏的title字体设置为白色
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
//    设置按钮颜色
    [self.navigationBar setTintColor:[UIColor whiteColor]];
//    导航栏背景颜色
    [self.navigationBar setBarTintColor:[UIColor colorWithRed:18.0 / 255.0 green:86.0 / 255.0 blue:136.0 / 255.0 alpha:1.0]];
//    使导航栏变得不透明，默认是半透明的
    [self.navigationBar setTranslucent:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 是状态栏的字体颜色变成白色

 @return 深色背景，白色字体
 */
- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
