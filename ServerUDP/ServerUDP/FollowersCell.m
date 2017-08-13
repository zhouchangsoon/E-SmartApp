//
//  FollowersCell.m
//  Instagram
//
//  Created by zcs on 2017/6/12.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import "FollowersCell.h"

@implementation FollowersCell

//表格Cell的初始化
- (void)awakeFromNib {
    [super awakeFromNib];
    
    //获取当前屏幕的宽度
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    //设置头像的位置
    self.avaImg.frame = CGRectMake(10, 10, width / 5.3, width / 5.3);
    
    //将头像设置成圆形
    self.avaImg.layer.cornerRadius = self.avaImg.frame.size.width / 2;
    self.avaImg.layer.masksToBounds = YES;
    
    //设置用户名和按钮的位置
    self.usernameLbl.frame = CGRectMake(self.avaImg.frame.size.width + 20, 30, width / 3.2, 30);
    self.followBtn.frame = CGRectMake(width - width / 3.5 - 20, 30, width / 3.5, 30);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)followBtn_click:(UIButton *)sender {
    NSString* title = self.followBtn.currentTitle;
    if ([title isEqualToString:@"关 注"]) {
        [[AVUser currentUser] follow:self.user.objectId andCallback:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded && self.user != nil) {
                [self.followBtn setTitle:@"已关注" forState:UIControlStateNormal];
                [self.followBtn setBackgroundColor:[UIColor greenColor]];
                AVObject* followNews = [AVObject objectWithClassName:@"News"];
                [followNews setObject:[AVUser currentUser].username forKey:@"by"];
                [followNews setObject:self.user.username forKey:@"to"];
                [followNews setObject:[[AVUser currentUser] objectForKey:@"ava"] forKey:@"ava"];
                [followNews setObject:@" " forKey:@"detailID"];
                [followNews setObject:@"follow" forKey:@"type"];
                [followNews setObject:@"no" forKey:@"checked"];
                [followNews setObject:@" " forKey:@"owner"];
                [followNews setObject:@" " forKey:@"message"];
                [followNews saveEventually];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reload" object:nil];
            }
            else {
                NSLog(@"关注失败, %@", error.localizedDescription);
            }
        }];
    }
    else {
        [[AVUser currentUser] unfollow:self.user.objectId andCallback:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [self.followBtn setTitle:@"关 注" forState:UIControlStateNormal];
                [self.followBtn setBackgroundColor:[UIColor lightGrayColor]];
                AVQuery* followQuery = [AVQuery queryWithClassName:@"News"];
                [followQuery whereKey:@"byID" equalTo:[AVUser currentUser].objectId];
                [followQuery whereKey:@"toID" equalTo:self.user.objectId];
                [followQuery whereKey:@"type" equalTo:@"follow"];
                [followQuery deleteAllInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                }];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reload" object:nil];
            }
            else {
                NSLog(@"取消关注失败, %@",error.localizedDescription);
            }
        }];
    }
}
@end
