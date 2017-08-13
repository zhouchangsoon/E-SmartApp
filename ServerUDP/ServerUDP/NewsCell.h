//
//  NewsCell.h
//  Instagram
//
//  Created by zcs on 2017/7/8.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsCell : UITableViewCell

//storyboard上的组件
@property (strong, nonatomic) IBOutlet UIImageView *avaImg;
@property (strong, nonatomic) IBOutlet UIButton *usernameBtn;
@property (strong, nonatomic) IBOutlet UILabel *infoLbl;
@property (strong, nonatomic) IBOutlet UILabel *dateLbl;

- (void)autoLayout;

@end
