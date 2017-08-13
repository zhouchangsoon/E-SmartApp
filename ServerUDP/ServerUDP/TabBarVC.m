//
//  TabBarVC.m
//  Instagram
//
//  Created by zcs on 2017/6/25.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import "TabBarVC.h"

@interface TabBarVC ()

@end

@implementation TabBarVC


- (void)viewDidLoad {
    [super viewDidLoad];
//    加载上角标
//    [self badge];
//    设置标签栏中的字体为白色
    [self.tabBar setTintColor:[UIColor whiteColor]];
//    设置标签栏的背景为黑色
    [self.tabBar setBarTintColor:[UIColor colorWithRed:37.0 / 255.0 green:39.0 / 255.0 blue:42.0 / 255.0 alpha:1]];
//    设置标签栏为不透明
    [self.tabBar setTranslucent:NO];
//    创建icon条
    self.icons = [[UIScrollView alloc] init];
    self.icons.frame = CGRectMake(self.view.frame.size.width / 5 * 3 + 10, self.view.frame.size.height - self.tabBar.frame.size.height * 2 - 3, 50, 35);
    [self.view addSubview:self.icons];
//    创建corner
    self.corner = [[UIImageView alloc] initWithFrame:CGRectMake(self.icons.frame.origin.x, self.icons.frame.origin.y + self.icons.frame.size.height - 2, 20, 16)];
    self.corner.center = CGPointMake(self.icons.center.x, self.corner.center.y);
    self.corner.image = [UIImage imageNamed:@"corner.png"];
    [self.corner setHidden:YES];
    [self.view addSubview:self.corner];
//    创建dot
//    dot = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 5 * 4 - 20, self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height + 5, 7, 7)];
//    dot.center = CGPointMake(self.view.frame.size.width / 5 * 3, dot.center.y);
//    dot.layer.cornerRadius = dot.frame.size.width / 2;
//    [dot.layer setMasksToBounds:YES];
//    dot.backgroundColor = [UIColor redColor];
//    [dot setHidden:YES];
//    [self.view addSubview:dot];
//    查询并显示所有的通知
    [self query:@[@"like"] image:[UIImage imageNamed:@"smallLove.png"]];
    [self query:@[@"follow"] image:[UIImage imageNamed:@"follow.png"]];
    [self query:@[@"smallComment", @"mention"] image:[UIImage imageNamed:@"smallComment.png"]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(check) name:@"check" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(check) name:@"hideView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show) name:@"showView" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)query:(NSArray *)type image:(UIImage *)image {
    AVQuery* query = [AVQuery queryWithClassName:@"News"];
    [query whereKey:@"to" equalTo:[AVUser currentUser].username];
    [query whereKey:@"checked" equalTo:@"no"];
    [query whereKey:@"type" containedIn:type];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            if ([objects count] > 0) {
                [self placeIcon:image text:[NSString stringWithFormat:@"%lu", [objects count]]];
            }
        }
    }];
}

- (void)placeIcon:(UIImage *)image text:(NSString *)text {
//    创建某个独立的提示
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(self.icons.contentSize.width, 0, 50, 35)];
    view.image = image;
    view.layer.cornerRadius = 3;
    [view.layer setMasksToBounds:YES];
    [self.icons addSubview:view];
//    创建Label
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(view.frame.size.width / 2 + 2, 0, view.frame.size.width / 2 - 2, view.frame.size.height)];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18]];
    label.text = text;
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor whiteColor];
    [view addSubview:label];
//    调整icons视图的frame
    self.icons.frame = CGRectMake(self.icons.frame.origin.x, self.icons.frame.origin.y, self.icons.frame.size.width + view.frame.size.width - 4, self.icons.frame.size.height);
    self.icons.contentSize = CGSizeMake(self.icons.contentSize.width + view.frame.size.width - 4, self.icons.contentSize.height);
    self.icons.center = CGPointMake(self.view.frame.size.width / 5 * 4 - (self.view.frame.size.width / 5) / 4, self.icons.center.y);
//    显示隐藏的控件
    [self.corner setHidden:NO];
//    [dot setHidden:NO];
}

- (void)check {
    [self.icons setHidden:YES];
    [self.corner setHidden:YES];
}

- (void)show {
    [self.icons setHidden:NO];
    [self.corner setHidden:NO];
}

//- (void)badge {
//    AVQuery* query = [AVQuery queryWithClassName:@"News"];
//    [query whereKey:@"to" equalTo:[AVUser currentUser].username];
//    [query whereKey:@"checked" equalTo:@"no"];
//    [query countObjectsInBackgroundWithBlock:^(NSInteger number, NSError * _Nullable error) {
//        if (error == nil) {
//            [[[self.tabBarController tabBar] items] objectAtIndex:3].badgeValue = [NSString stringWithFormat:@"%lu", number];
//            [[[self.tabBarController tabBar] items] objectAtIndex:3].badgeColor = [UIColor redColor];
//        }
//    }];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
