//
//  PostCell.h
//  Instagram
//
//  Created by zcs on 2017/6/23.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVOSCloud/AVOSCloud.h>
#import "KILabel.h"

@interface PostCell : UITableViewCell<UITextViewDelegate>

//视图中各种组件
@property (strong, nonatomic) IBOutlet UIImageView *avaImg;
@property (strong, nonatomic) IBOutlet UIButton *usernameBtn;
@property (strong, nonatomic) IBOutlet UILabel *dateLbl;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIButton *likeBtn;
@property (strong, nonatomic) IBOutlet UIButton *commentBtn;
@property (strong, nonatomic) IBOutlet UIButton *moreBtn;
@property (strong, nonatomic) IBOutlet UILabel *puuidLbl;
@property (strong, nonatomic) IBOutlet UILabel *likeLbl;
@property (strong, nonatomic) IBOutlet KILabel *titleLbl;


//点击喜爱按钮
- (IBAction)likeBtn_clicked:(UIButton *)sender;

@end
