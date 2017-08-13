//
//  PictureCell.m
//  Instagram
//
//  Created by zcs on 2017/6/1.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import "PictureCell.h"

@implementation PictureCell

- (void)awakeFromNid {
    [super awakeFromNib];
}


/**
 初始化图片的位置
 */
- (void)initFrame {
    int width = UIScreen.mainScreen.bounds.size.width;
    self.picImg.frame = CGRectMake(0, 0, width / 3.0 - 4, width / 3.0 - 4);
}

@end
