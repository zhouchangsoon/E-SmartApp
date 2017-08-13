//
//  PostVC.m
//  Instagram
//
//  Created by zcs on 2017/6/23.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import "PostVC.h"

@interface PostVC ()

@end

@implementation PostVC
{
    NSMutableArray<NSNumber *> *heightArray;
    NSMutableArray<NSNumber *> *titleHeightArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    初始化所有MutableArray
    [self initArray];
//    隐藏默认的返回按钮，新建一个返回按钮
    [self.navigationItem hidesBackButton];
    UIBarButtonItem* backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
//    向右滑动的时候返回上一层
    UISwipeGestureRecognizer* swipeBack = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeBack:)];
    [swipeBack setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:swipeBack];
//    设置tableView的高度
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 550;
//    加载数据
    AVQuery* postsQuery = [AVQuery queryWithClassName:@"Detail"];
    [postsQuery whereKey:@"bookname" equalTo:[self.postuuid lastObject]];
    [postsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
//            清空数组内的所有内容
            [self.avaArray removeAllObjects];
            [self.usernameArray removeAllObjects];
            [self.dateArray removeAllObjects];
            [self.booknameArray removeAllObjects];
            [self.puuidArray removeAllObjects];
            [self.titleArray removeAllObjects];
            [self.textArray removeAllObjects];
//            给每个数组赋值
            for (id object in objects) {
                [self.avaArray addObject:[object objectForKey:@"ava"]];
                [self.usernameArray addObject:[object objectForKey:@"username"]];
                [self.dateArray addObject:[object objectForKey:@"createdAt"]];
                [self.booknameArray addObject:[object objectForKey:@"bookname"]];
                [self.puuidArray addObject:[object objectForKey:@"objectId"]];
                [self.titleArray addObject:[object objectForKey:@"title"]];
                [self.textArray addObject:[object objectForKey:@"text"]];
            }
//            重新加载数据
            [self heightForTextView];
            [self.tableView reloadData];
        }
        else {
            [self alert:@"警告" message:error.localizedDescription];
        }
    }];
//    监听喜爱信息是否改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:@"reloadData" object:nil];
//    单机其他地方时键盘消失
    UITapGestureRecognizer* hideTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [hideTap setNumberOfTapsRequired:1];
    [hideTap setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:hideTap];

}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

/**
 初始化数组
 */
- (void)initArray {
    self.avaArray = [[NSMutableArray alloc] init];
    self.postuuid = [[NSMutableArray alloc] init];
    self.usernameArray = [[NSMutableArray alloc] init];
    self.dateArray = [[NSMutableArray alloc] init];
    self.textArray = [[NSMutableArray alloc] init];
    self.puuidArray = [[NSMutableArray alloc] init];
    self.titleArray = [[NSMutableArray alloc] init];
    self.booknameArray = [[NSMutableArray alloc] init];
    heightArray = [[NSMutableArray alloc] init];
    titleHeightArray = [[NSMutableArray alloc] init];
    [self.postuuid addObject:self.post];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)swipeBack:(UISwipeGestureRecognizer *)gesture {
    if ([self.postuuid count] > 0) {
        [self.postuuid removeLastObject];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 点击返回按钮返回上一层

 @param item 坐上角的返回按钮
 */
- (void)back:(UIBarButtonItem *)item {
    if ([self.postuuid count] > 0) {
        [self.postuuid removeLastObject];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.usernameArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
//    加载头像
    [[self.avaArray objectAtIndex:indexPath.row] getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error == nil) {
            cell.avaImg.image = [UIImage imageWithData:data];
        }
        else {
            [self alert:@"警告" message:error.localizedDescription];
        }
    }];
//    加载用户名
    [cell.usernameBtn setTitle:[self.usernameArray objectAtIndex:indexPath.row] forState:UIControlStateNormal];
    NSLog(@"输出用户名:%@", cell.usernameBtn.titleLabel.text);
//    加载帖子发布了多久
    NSDate* from = [self.dateArray objectAtIndex:indexPath.row];
    NSDate* to = [NSDate date];
    NSCalendarUnit unit = NSCalendarUnitWeekOfMonth | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* dateComponents = [calendar components:unit fromDate:from toDate:to options:0];
    if (dateComponents.weekOfMonth > 0) {
        cell.dateLbl.text = [NSString stringWithFormat:@"%ld周", dateComponents.weekOfMonth];
    }
    else if (dateComponents.day > 0) {
        cell.dateLbl.text = [NSString stringWithFormat:@"%ld天", dateComponents.day];
    }
    else if (dateComponents.hour > 0) {
        cell.dateLbl.text = [NSString stringWithFormat:@"%ld小时", dateComponents.hour];
    }
    else if (dateComponents.minute > 0) {
        cell.dateLbl.text = [NSString stringWithFormat:@"%ld分钟", dateComponents.minute];
    }
    else if (dateComponents.second > 0) {
        cell.dateLbl.text = [NSString stringWithFormat:@"%ld秒", dateComponents.second];
    }
    else {
        cell.dateLbl.text = @"现在";
    }
//    加载文字
    cell.textView.text = [NSString stringWithFormat:@"%@", [self.textArray objectAtIndex:indexPath.row]];
//    加载标题
    cell.titleLbl.text = [self.titleArray objectAtIndex:indexPath.row];
//    加载puuid
    cell.puuidLbl.text = [self.puuidArray objectAtIndex:indexPath.row];
//    动态调整usernameBtn和titleLbl的大小
    [cell.usernameBtn sizeToFit];
    [cell.titleLbl sizeToFit];
//    根据用户是否喜爱来维护likeBtn按钮
    AVQuery* didLike = [AVQuery queryWithClassName:@"Like"];
    [didLike whereKey:@"from" equalTo:[AVUser currentUser].username];
    [didLike whereKey:@"to" equalTo:cell.puuidLbl.text];
    [didLike countObjectsInBackgroundWithBlock:^(NSInteger number, NSError * _Nullable error) {
        if (error == nil) {
            if (number > 0) {
                [cell.likeBtn setTitle:@"like" forState:UIControlStateNormal];
                [cell.likeBtn setBackgroundImage:[UIImage imageNamed:@"love.png"] forState:UIControlStateNormal];
            }
            else {
                [cell.likeBtn setTitle:@"dislike" forState:UIControlStateNormal];
                [cell.likeBtn setBackgroundImage:[UIImage imageNamed:@"dislike.png"] forState:UIControlStateNormal];
            }
        }
        else {
            [self alert:@"警告" message:error.localizedDescription];
        }
    }];
//    统计喜爱总数
    AVQuery* likesQuery = [AVQuery queryWithClassName:@"Like"];
    [likesQuery whereKey:@"to" equalTo:cell.puuidLbl.text];
    [likesQuery countObjectsInBackgroundWithBlock:^(NSInteger number, NSError * _Nullable error) {
        if (error == nil) {
            cell.likeLbl.text = [NSString stringWithFormat:@"%ld", (long)number];
        }
        else {
            [self alert:@"警告" message:error.localizedDescription];
        }
    }];
//    当用户点击@的内容的时候
    [cell.titleLbl setUserHandleLinkTapHandler:^(KILabel *label, NSString *string, NSRange range) {
//        去除@，取@里面的内容
        NSString* message = [string substringFromIndex:1];
//        如果是当前用户本人，则跳到主页
        if ([message isEqualToString:[AVUser currentUser].username]) {
            HomeVC* home = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
            [self.navigationController pushViewController:home animated:YES];
        }
        else {
            AVQuery* userQuery = [AVUser query];
            [userQuery whereKey:@"username" equalTo:message];
            [userQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if (error == nil && [objects count] > 0) {
                    GuestVC* guestVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GuestVC"];
                    guestVC.user = [objects lastObject];
                    guestVC.username = [[objects lastObject] objectForKey:@"username"];
                }
                else if (error){
                    [self alert:@"Alert" message:error.localizedDescription];
                }
                else {
                    [self alert:@"提示" message:[NSString stringWithFormat:@"小编用尽洪荒之力都没有发现%@用户存在", message]];
                }
            }];
        }
    }];
//    当用户点击hashtag内容时，跳转到所有有关hashtag的内容页面
    [cell.titleLbl setHashtagLinkTapHandler:^(KILabel* label, NSString* string, NSRange range) {
        HashtagsVC* hashtagsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HashtagsVC"];
        hashtagsVC.hashtag = [string substringFromIndex:1];
        [self.navigationController pushViewController:hashtagsVC animated:YES];
    }];
//    设置userNameBtn的layer名字
    [cell.usernameBtn.layer setValue:indexPath forKey:@"index"];
//    设置commentBtn的layer名字
    [cell.commentBtn.layer setValue:indexPath forKey:@"index"];
//    设置moreBtn的layer名字
    [cell.moreBtn.layer setValue:indexPath forKey:@"index"];
////    动态调整位置
//    头像的位置
    cell.avaImg.frame = CGRectMake(10, 10, 30, 30);
    cell.avaImg.layer.cornerRadius = cell.avaImg.frame.size.width / 2;
    [cell.avaImg.layer masksToBounds];
//    用户名的位置
    cell.usernameBtn.frame = CGRectMake(cell.avaImg.frame.origin.x + cell.avaImg.frame.size.width + 10, 10, 208, 30);
//    日期的位置
    cell.dateLbl.frame = CGRectMake(self.view.frame.size.width - 60, 15, 50, 30);
//    文本的位置
    CGFloat height = [[heightArray objectAtIndex:indexPath.row] floatValue];
    cell.textView.frame = CGRectMake(0, cell.avaImg.frame.origin.y + cell.avaImg.frame.size.height + 10, self.view.frame.size.width, height);
    cell.textView.layer.borderWidth = 1;
    cell.textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    喜欢的位置
    cell.likeBtn.frame = CGRectMake(15, cell.textView.frame.origin.y + cell.textView.frame.size.height + 10, 25, 25);
//    喜欢likeLbl的位置
    cell.likeLbl.frame = CGRectMake(cell.likeBtn.frame.origin.x + cell.likeBtn.frame.size.width + 8, cell.textView.frame.origin.y + cell.textView.frame.size.height + 8, 42, 30);
//    评论commentBtn的位置
    cell.commentBtn.frame = CGRectMake(cell.likeLbl.frame.origin.x + cell.likeLbl.frame.size.width + 15, cell.textView.frame.origin.y + cell.textView.frame.size.height + 10, 25, 25);
//    更过moreBtn的位置
    cell.moreBtn.frame = CGRectMake(self.view.frame.size.width - 45, cell.textView.frame.origin.y + cell.textView.frame.size.height + 13, 30, 15);
//    设置title的位置
    CGFloat titleHeight = [titleHeightArray objectAtIndex:indexPath.row].floatValue;
    cell.titleLbl.frame = CGRectMake(0, cell.likeBtn.frame.origin.y + cell.likeBtn.frame.size.height + 5, self.view.frame.size.width, titleHeight);
    return cell;
}

/**
 弹出警告信息

 @param title 信息标题
 @param message 信息内容
 */
- (void)alert:(NSString *)title message:(NSString *)message {
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"表格高度: %f", heightArray[indexPath.row].floatValue);
    CGFloat height = 115 + heightArray[indexPath.row].floatValue + titleHeightArray[indexPath.row].floatValue;
    return height;
}

/**
 重新加载数据
 */
- (void)reloadData:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (IBAction)username_clicked:(UIButton *)sender {
    NSIndexPath* path = [sender.layer valueForKey:@"index"];
    PostCell* cell = [self.tableView cellForRowAtIndexPath:path];
    if ([[cell.usernameBtn titleForState:UIControlStateNormal] isEqualToString:[AVUser currentUser].username]) {
        HomeVC* home = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
        [self.navigationController pushViewController:home animated:YES];
    }
    else {
        GuestVC* guest = [self.storyboard instantiateViewControllerWithIdentifier:@"GuestVC"];
        [self.navigationController pushViewController:guest animated:YES];
    }
}

- (IBAction)commentBtn_clicked:(UIButton *)sender {
    NSIndexPath* path = [sender.layer valueForKey:@"index"];
    PostCell* cell = [self.tableView cellForRowAtIndexPath:path];
    CommentVC* comment = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentVC"];
    [comment postInitData];
    comment.commentUuid = cell.puuidLbl.text;
    comment.commentOwner = [cell.usernameBtn titleForState:UIControlStateNormal];
    comment.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:comment animated:YES];
}

- (IBAction)more_clicked:(UIButton *)sender {
    NSIndexPath* index = [sender.layer valueForKey:@"index"];
    PostCell* cell = [self.tableView cellForRowAtIndexPath:index];
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"选项" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//    删除选项
    UIAlertAction* delete = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//        删除相应的帖子
        AVQuery* postQuery = [AVQuery queryWithClassName:@"Detail"];
        [postQuery whereKey:@"objectId" equalTo:cell.puuidLbl.text];
        [postQuery deleteAllInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                [self alert:@"Alert" message:error.localizedDescription];
            }
            else {
                //        通知主界面更新
                [[NSNotificationCenter defaultCenter] postNotificationName:@"uploaded" object:nil];
                //        退到上一级
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
//        删除相应的评论
        AVQuery* commentQuery = [AVQuery queryWithClassName:@"comment"];
        [commentQuery whereKey:@"to" equalTo:cell.puuidLbl.text];
        [commentQuery deleteAllInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                [self alert:@"Alert" message:error.localizedDescription];
            }
        }];
//        删除相应的喜欢
        AVQuery* likeQuery = [AVQuery queryWithClassName:@"Like"];
        [likeQuery whereKey:@"to" equalTo:cell.puuidLbl.text];
        [likeQuery deleteAllInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                [self alert:@"Alert" message:error.localizedDescription];
            }
        }];
//        删除相应的Hashtag
        AVQuery* hashtagQuery = [AVQuery queryWithClassName:@"Hashtag"];
        [hashtagQuery whereKey:@"to" equalTo:cell.puuidLbl.text];
        [hashtagQuery deleteAllInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                [self alert:@"Alert" message:error.localizedDescription];
            }
        }];
//        删除相应的投诉
        AVQuery* complainQuery = [AVQuery queryWithClassName:@"complain"];
        [complainQuery whereKey:@"detailID" equalTo:cell.puuidLbl.text];
        [complainQuery deleteAllInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                [self alert:@"Alert" message:error.localizedDescription];
            }
        }];
//        删除相应的数据
        [self.postuuid removeLastObject];
        [self.avaArray removeObjectAtIndex:index.row];
        [self.usernameArray removeObjectAtIndex:index.row];
        [self.dateArray removeObjectAtIndex:index.row];
        [self.booknameArray removeObjectAtIndex:index.row];
        [self.puuidArray removeObjectAtIndex:index.row];
        [self.titleArray removeObjectAtIndex:index.row];
        [self.textArray removeObjectAtIndex:index.row];
    }];
//    投诉选项
    UIAlertAction* complain = [UIAlertAction actionWithTitle:@"投诉" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        先查询是否存在相同的投诉
        AVQuery* complainQuery = [AVQuery queryWithClassName:@"complain"];
        [complainQuery whereKey:@"detailID" equalTo:cell.puuidLbl.text];
        [complainQuery whereKey:@"by" equalTo:[AVUser currentUser].username];
        [complainQuery whereKey:@"owner" equalTo:[cell.usernameBtn titleForState:UIControlStateNormal]];
        [complainQuery whereKey:@"to" equalTo:cell.titleLbl.text];
        [complainQuery countObjectsInBackgroundWithBlock:^(NSInteger number, NSError * _Nullable error) {
            if (error == nil) {
//                若存在相同的投诉
                if (number > 0) {
                    [self alert:@"提示" message:@"你已经投诉过了"];
                }
//                若不存在相同的投诉，则添加此投诉
                else {
                    AVObject* complianObject = [AVObject objectWithClassName:@"complain"];
                    [complianObject setObject:cell.puuidLbl.text forKey:@"post"];
                    [complianObject setObject:[AVUser currentUser].username forKey:@"by"];
                    [complianObject setObject:[cell.usernameBtn titleForState:UIControlStateNormal]  forKey:@"owner"];
                    [complianObject setObject:cell.titleLbl.text forKey:@"to"];
                    [complianObject saveInBackground];
                    [self alert:@"提示" message:@"您的投诉已被处理"];
                }
            }
            else {
                [self alert:@"Alert" message:error.localizedDescription];
            }
        }];
    }];
//    取消按钮
    UIAlertAction* cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    if ([[AVUser currentUser].username isEqualToString:[cell.usernameBtn titleForState:UIControlStateNormal]]) {
        [alertController addAction:delete];
        [alertController addAction:cancle];
    }
    else {
        [alertController addAction:complain];
        [alertController addAction:cancle];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) heightForTextView {
    [heightArray removeAllObjects];
    [titleHeightArray removeAllObjects];
    for (int i = 0; i < [self.textArray count]; ++i) {
        UITextView* text = [[UITextView alloc] init];
        text.frame = CGRectMake(0, 0, self.view.frame.size.width, 35);
        [text setFont:[UIFont systemFontOfSize:15]];
        [text setTextAlignment:NSTextAlignmentLeft];
        text.text = [NSString stringWithFormat:@"%@", [self.textArray objectAtIndex:i]];
        CGFloat height = [text sizeThatFits:CGSizeMake(self.view.frame.size.width, MAXFLOAT)].height;
        NSNumber *number = [NSNumber numberWithDouble:height];
        [heightArray addObject:number];
    }
    for (int i = 0; i < [self.titleArray count]; ++i) {
        UITextView* text = [[UITextView alloc] init];
        text.frame = CGRectMake(0, 0, self.view.frame.size.width, 35);
        [text setFont:[UIFont systemFontOfSize:15]];
        [text setTextAlignment:NSTextAlignmentLeft];
        text.text = [NSString stringWithFormat:@"%@", [self.titleArray objectAtIndex:i]];
        CGFloat height = [text sizeThatFits:CGSizeMake(self.view.frame.size.width, MAXFLOAT)].height;
        NSNumber *number = [NSNumber numberWithDouble:height];
        [titleHeightArray addObject:number];
    }
}
@end
