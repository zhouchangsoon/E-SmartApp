//
//  CommentCell.h
//  Instagram
//
//  Created by zcs on 2017/6/26.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KILabel.h"

@interface CommentCell : UITableViewCell
//视图中的各种组件
@property (strong, nonatomic) IBOutlet UIImageView *avaImg;
@property (strong, nonatomic) IBOutlet UIButton *usernameBtn;
@property (strong, nonatomic) IBOutlet KILabel *commentLbl;
@property (strong, nonatomic) IBOutlet UILabel *DateLbl;

@end
