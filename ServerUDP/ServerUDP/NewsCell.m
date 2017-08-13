//
//  NewsCell.m
//  Instagram
//
//  Created by zcs on 2017/7/8.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import "NewsCell.h"

@implementation NewsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avaImg.layer.cornerRadius = self.avaImg.frame.size.width / 2;
    [self.avaImg.layer setMasksToBounds:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


/**
 为newscell添加位置约束
 */
- (void)autoLayout {
    //    使用自动布局
    self.avaImg.translatesAutoresizingMaskIntoConstraints = NO;
    self.usernameBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.infoLbl.translatesAutoresizingMaskIntoConstraints = NO;
    self.dateLbl.translatesAutoresizingMaskIntoConstraints = NO;
    
//    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[ava(30)]-10-[username(75)]-7-[info]-[date(50)]-15-|" options:0 metrics:nil views:[NSDictionary dictionaryWithObjectsAndKeys:self.avaImg, @"ava", self.usernameBtn, @"username", self.infoLbl, @"info", self.dateLbl, @"date", nil]]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[date(50)]-10-|" options:0 metrics:nil views:[NSDictionary dictionaryWithObjectsAndKeys:self.dateLbl, @"date", nil]]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[ava(30)]-40-|" options:0 metrics:nil views:[NSDictionary dictionaryWithObjectsAndKeys:self.avaImg, @"ava", nil]]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[username(30)]" options:0 metrics:nil views:[NSDictionary dictionaryWithObjectsAndKeys:self.usernameBtn, @"username", nil]]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[info(30)]" options:0 metrics:nil views:[NSDictionary dictionaryWithObjectsAndKeys:self.infoLbl, @"info", nil]]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[date(30)]" options:0 metrics:nil views:[NSDictionary dictionaryWithObjectsAndKeys:self.dateLbl, @"date", nil]]];
}

@end
