//
//  TabBarVC.h
//  Instagram
//
//  Created by zcs on 2017/6/25.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVOSCloud/AVOSCloud.h>
#import "NavVC.h"

@interface TabBarVC : UITabBarController

//    创建tabbar中通知的上角标
@property (strong, nonatomic) UIScrollView *icons;
//    三角形
@property (strong, nonatomic) UIImageView *corner;

@end
