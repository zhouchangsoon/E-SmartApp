//
//  PictureCell.h
//  Instagram
//
//  Created by zcs on 2017/6/1.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *picImg;

- (void)initFrame;

@end
