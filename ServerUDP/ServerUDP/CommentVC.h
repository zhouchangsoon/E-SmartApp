//
//  CommentVC.h
//  Instagram
//
//  Created by zcs on 2017/6/26.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVOSCloud/AVOSCloud.h>
#import "CommentCell.h"
#import "HomeVC.h"
#import "GuestVC.h"
#import "KILabel.h"
#import "HashtagsVC.h"

@interface CommentVC : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

//控件
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextView *commentTxt;
@property (strong, nonatomic) IBOutlet UIButton *sendBtn;
//刷新
@property (strong, nonatomic) UIRefreshControl *refreash;
//位置信息
@property (assign, nonatomic)CGFloat tableViewHeight;
@property (assign, nonatomic)CGFloat commentY;
@property (assign,nonatomic)CGFloat commentHeight;
//用户信息
@property (strong, nonatomic)NSMutableArray<NSString *>* commentUuidArray;
@property (strong, nonatomic)NSMutableArray<NSString *>* commentOwnerArray;
@property (strong, nonatomic)NSString* commentUuid;
@property (strong, nonatomic)NSString* commentOwner;
//键盘位置
@property (assign, nonatomic)CGRect keyboardFrame;
//从云端获取的用户信息
@property (strong, nonatomic)NSMutableArray<NSString *>* usernameArray;
@property (strong, nonatomic)NSMutableArray<AVFile *>* avaArray;
@property (strong, nonatomic)NSMutableArray<NSString *>* commentArray;
@property (strong, nonatomic)NSMutableArray<NSDate *>* dateArray;
//每次载入的帖子数目
@property (assign, nonatomic)int pages;
//点击发送按钮
- (IBAction)sendBtn_clicked:(UIButton *)sender;
- (IBAction)username_clicked:(UIButton *)sender;
- (void)postInitData;
- (void)feedInitData;
@end
