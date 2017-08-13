//
//  FollowersCell.h
//  Instagram
//
//  Created by zcs on 2017/6/12.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVOSCloud/AVOSCloud.h>

@interface FollowersCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *avaImg;
@property (strong, nonatomic) IBOutlet UILabel *usernameLbl;
@property (strong, nonatomic) IBOutlet UIButton *followBtn;
@property (strong, nonatomic) AVUser* user;
- (IBAction)followBtn_click:(UIButton *)sender;

@end
