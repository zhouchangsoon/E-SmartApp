//
//  CommentCell.m
//  Instagram
//
//  Created by zcs on 2017/6/26.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import "CommentCell.h"

@implementation CommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
//    使用自动布局布局
    [self.commentLbl setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor redColor],} forLinkType:KILinkTypeUserHandle];
    self.avaImg.translatesAutoresizingMaskIntoConstraints = NO;
    self.usernameBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.commentLbl.translatesAutoresizingMaskIntoConstraints = NO;
    self.DateLbl.translatesAutoresizingMaskIntoConstraints = NO;
//    自动布局垂直方向
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[username]-(-2)-[comment]-5-|" options:0 metrics:nil views:@{@"username":self.usernameBtn, @"comment":self.commentLbl}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[date]" options:0 metrics:nil views:[NSDictionary dictionaryWithObjectsAndKeys:self.DateLbl, @"date", nil]]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[ava(40)]" options:0 metrics:nil views:[NSDictionary dictionaryWithObjectsAndKeys:self.avaImg, @"ava", nil]]];
//    自动布局水平方向
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[ava(40)]-13-[comment]-20-|" options:0 metrics:nil views:[NSDictionary dictionaryWithObjectsAndKeys:self.avaImg, @"ava", self.commentLbl, @"comment", nil]]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[ava]-13-[username]" options:0 metrics:nil views:[NSDictionary dictionaryWithObjectsAndKeys:self.avaImg, @"ava", self.usernameBtn, @"username", nil]]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[date]-10-|" options:0 metrics:nil views:[NSDictionary dictionaryWithObjectsAndKeys:self.DateLbl, @"date", nil]]];
//    将头像框设置为圆形
    self.avaImg.layer.cornerRadius = self.avaImg.layer.frame.size.width / 2;
    self.avaImg.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
