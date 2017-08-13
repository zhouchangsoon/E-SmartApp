//
//  PostCell.m
//  Instagram
//
//  Created by zcs on 2017/6/23.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import "PostCell.h"

@implementation PostCell
{
    CGFloat height;
}

- (void)awakeFromNib {
    [super awakeFromNib];
//    将头像设置为圆形
    self.avaImg.layer.cornerRadius = self.avaImg.frame.size.width / 2;
    self.avaImg.layer.masksToBounds = YES;
//    将likeBtn的字体设置为透明
    [self.likeBtn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


/**
 点击喜欢按钮，原来不喜欢就变成喜欢，喜欢则不变

 @param sender 按钮
 */
- (IBAction)likeBtn_clicked:(UIButton *)sender {
    if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"like"]) {
        AVQuery* likeQuery = [AVQuery queryWithClassName:@"Like"];
        [likeQuery whereKey:@"fromID" equalTo:[AVUser currentUser].objectId];
        [likeQuery whereKey:@"to" equalTo:self.puuidLbl.text];
        [likeQuery deleteAllInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error == nil) {
//                改变喜爱的图片并通知tableView
                [self.likeBtn setTitle:@"dislike" forState:UIControlStateNormal];
                [self.likeBtn setBackgroundImage:[UIImage imageNamed:@"dislike.png"] forState:UIControlStateNormal];
//                AVQuery* deleteLikeQuery = [AVQuery queryWithClassName:@"Likes"];
//                [deleteLikeQuery whereKey:@"fromID" equalTo:[AVUser currentUser].objectId];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil];
            }
            else {
                NSLog(@"取消喜爱出错, %@", error.localizedDescription);
            }
        }];
//        删除喜爱消息
        AVQuery* likeNewsQuery = [AVQuery queryWithClassName:@"News"];
        [likeNewsQuery whereKey:@"by" equalTo:[AVUser currentUser].username];
        [likeNewsQuery whereKey:@"detailID" equalTo:self.puuidLbl.text];
        [likeNewsQuery whereKey:@"to" equalTo:[self.usernameBtn titleForState:UIControlStateNormal]];
        [likeNewsQuery whereKey:@"type" equalTo:@"like"];
        [likeNewsQuery deleteAllInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        }];
    }
    else {
        AVObject* likeObject = [AVObject objectWithClassName:@"Like"];
        [likeObject setObject:[AVUser currentUser].username forKey:@"from"];
        [likeObject setObject:[AVUser currentUser].objectId forKey:@"fromID"];
        [likeObject setObject:self.puuidLbl.text forKey:@"to"];
        [likeObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error == nil) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil];
                [self.likeBtn setTitle:@"like" forState:UIControlStateNormal];
                [self.likeBtn setBackgroundImage:[UIImage imageNamed:@"love.png"] forState:UIControlStateNormal];
            }
            else {
                NSLog(@"添加喜爱出错,%@", error.localizedDescription);
            }
        }];
//        将喜爱的消息上传
        AVObject* likeNews = [AVObject objectWithClassName:@"News"];
        [likeNews setObject:[AVUser currentUser].username forKey:@"by"];
        [likeNews setObject:[self.usernameBtn titleForState:UIControlStateNormal] forKey:@"to"];
        [likeNews setObject:self.puuidLbl.text forKey:@"detailID"];
        [likeNews setObject:@"no" forKey:@"checked"];
        [likeNews setObject:@" " forKey:@"message"];
        [likeNews setObject:[[AVUser currentUser] objectForKey:@"ava"] forKey:@"ava"];
        [likeNews setObject:@"like" forKey:@"type"];
        [likeNews setObject:[self.usernameBtn titleForState:UIControlStateNormal] forKey:@"owner"];
        [likeNews saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                NSLog(@"上传发生错误");
            }
        }];
    }
}

@end
