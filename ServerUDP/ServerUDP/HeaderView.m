//
//  HeaderView.m
//  Instagram
//
//  Created by zcs on 2017/6/1.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import "HeaderView.h"

@implementation HeaderView

- (void)awakeFromNid {
    [super awakeFromNib];
}

- (void)initFrame {
    
    //获取当前主屏幕的宽度
    int width = UIScreen.mainScreen.bounds.size.width;
    
    //设置头像、帖子数目、粉丝数目和关注数目的位置
    int tempWidth = width / 4 * 3 - 45;
    self.avaImg.frame = CGRectMake(15, 15, width / 4, width / 4);
    self.posts.frame = CGRectMake(30 + width / 4, 15, 50, 30);
    self.followers.frame = CGRectMake(self.posts.frame.origin.x + tempWidth / 2 - 25, 15, 50, 30);
    self.followings.frame = CGRectMake(self.posts.frame.origin.x + tempWidth - 50, 15, 50, 30);
    
    //设置帖子、粉丝、关注文本框的位
    self.postLabel.center = CGPointMake(self.posts.center.x, self.posts.center.y + 20);
    self.followerLabel.center = CGPointMake(self.followers.center.x, self.followers.center.y + 20);
    self.followingLabel.center = CGPointMake(self.followings.center.x, self.followings.center.y + 20);
    
    //设置按钮的布局
    self.button.frame = CGRectMake(self.postLabel.frame.origin.x, self.postLabel.center.y + 20, width - self.postLabel.frame.origin.x - 15, 30);
    self.fullNameLabel.frame = CGRectMake(self.avaImg.frame.origin.x, self.avaImg.frame.origin.y + self.avaImg.frame.size.height, width - 30, 30);
    self.webTxt.frame = CGRectMake(self.avaImg.frame.origin.x - 5, self.fullNameLabel.frame.origin.y + 30, width - 30, 30);
    self.bioTxt.frame = CGRectMake(self.avaImg.frame.origin.x, self.webTxt.frame.origin.y + 30, width - 30, 30);
    
    //    设置按钮为圆角
    self.button.layer.cornerRadius = self.button.frame.size.width / 50;
    [self.button.layer setMasksToBounds:YES];
    
//    设置头像为圆角
    self.avaImg.layer.cornerRadius = self.avaImg.frame.size.width / 2;
    [self.avaImg.layer setMasksToBounds:YES];
}
@end
