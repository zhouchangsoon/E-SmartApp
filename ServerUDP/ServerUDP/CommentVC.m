//
//  CommentVC.m
//  Instagram
//
//  Created by zcs on 2017/6/26.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import "CommentVC.h"

@interface CommentVC ()

@end

@implementation CommentVC
{
    int deta;
    CGRect tabBarFrame;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    布局
    [self alignment];
//    初始化
    if (self.commentUuidArray == nil) {
        self.commentUuidArray = [[NSMutableArray alloc] init];
    }
    if (self.commentOwnerArray == nil) {
        self.commentOwnerArray = [[NSMutableArray alloc] init];
    }
    if (self.commentArray == nil) {
        self.commentArray = [[NSMutableArray alloc] init];
    }
    if (self.usernameArray == nil) {
        self.usernameArray = [[NSMutableArray alloc] init];
    }
    if (self.avaArray == nil) {
        self.avaArray = [[NSMutableArray alloc] init];
    }
    if (self.usernameArray == nil) {
        self.usernameArray = [[NSMutableArray alloc] init];
    }
    if (self.dateArray == nil) {
        self.dateArray = [[NSMutableArray alloc] init];
    }
    self.commentY = self.commentTxt.frame.origin.y + deta;
    self.tableViewHeight = self.tableView.frame.size.height + deta;
    self.commentHeight = self.commentTxt.frame.size.height;
//    将存取数据
    [self.commentUuidArray addObject:self.commentUuid];
    [self.commentOwnerArray addObject:self.commentOwner];
//    设置导航栏
    self.navigationItem.title = @"评论";
    [self.navigationItem setHidesBackButton:YES];
    UIBarButtonItem* backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    [self.navigationItem setLeftBarButtonItem:backButtonItem];
//    滑动返回
    UISwipeGestureRecognizer* swipeBack = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeBack:)];
    [swipeBack setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeBack];
//    监听键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//    设置textView的代理
    [self.commentTxt setDelegate:self];
//    设置tableView的代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    首次载入的评论数目
    self.pages = 12;
//    加载数据
    [self loadComment];
//    点击空白处收起键盘
    UITapGestureRecognizer* tapHide = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [tapHide setNumberOfTapsRequired:1];
    [tapHide setNumberOfTouchesRequired:1];
    [self.tableView setUserInteractionEnabled:YES];
    [self.tableView addGestureRecognizer:tapHide];
//    隐藏多余的分割线
    [self.tableView setTableFooterView:[[UIView alloc] init]];
}

- (void)viewWillAppear:(BOOL)animated {
    //    设置tabBarFrame
    tabBarFrame = self.tabBarController.tabBar.frame;
//    隐藏标签栏
    [self.tabBarController.tabBar setHidden:YES];
    [self.tabBarController.tabBar setFrame:CGRectZero];
//    弹出键盘
    [self.commentTxt becomeFirstResponder];
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideView" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
//    收起键盘
    [self.commentTxt resignFirstResponder];
//    显示标签栏
    [self.tabBarController.tabBar setHidden:NO];
    [self.tabBarController.tabBar setFrame:tabBarFrame];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showView" object:nil];
}

- (void)hideKeyboard:(UITapGestureRecognizer *)gesture {
    [self.commentTxt resignFirstResponder];
}

- (void)showKeyboard:(UITapGestureRecognizer *)gesture {
    [self.commentTxt setUserInteractionEnabled:YES];
    [self.commentTxt setEditable:YES];
    [self.commentTxt becomeFirstResponder];
}

- (void)postInitData {
    deta = 0;
}

- (void)feedInitData {
    deta = 63;
}

//
/**
 UITablViewDataSource 使得每一个cell都可编辑（添加或者删除）

 @param tableView tableView description
 @param indexPath indexPath description
 @return YES
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    添加删除按钮
    UITableViewRowAction* delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        AVQuery* deleteQuery = [AVQuery queryWithClassName:@"comment"];
        [deleteQuery whereKey:@"to" equalTo:[self.commentUuidArray lastObject]];
        [deleteQuery whereKey:@"username" equalTo:[cell.usernameBtn titleForState:UIControlStateNormal]];
        [deleteQuery whereKey:@"comment" equalTo:[self.commentArray objectAtIndex:indexPath.row]];
        [deleteQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (error == nil) {
                for (AVObject* object in objects) {
                    [object deleteEventually];
                }
                [self.commentArray removeObjectAtIndex:indexPath.row];
                [self.usernameArray removeObjectAtIndex:indexPath.row];
                [self.avaArray removeObjectAtIndex:indexPath.row];
                [self.dateArray removeObjectAtIndex:indexPath.row];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView setEditing:NO animated:YES];
            }
            else {
                [self alert:@"Alert" message:error.localizedDescription];
            }
        }];
        AVQuery* hashTagObjQuery = [AVQuery queryWithClassName:@"Hashtag"];
        [hashTagObjQuery whereKey:@"from" equalTo:[cell.usernameBtn titleForState:UIControlStateNormal]];
        [hashTagObjQuery whereKey:@"to" equalTo:[self.commentUuidArray lastObject]];
        [hashTagObjQuery whereKey:@"comment" equalTo:[cell.commentLbl.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        [hashTagObjQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (error == nil) {
                NSLog(@"找到的个数:%lu", [objects count]);
                for (AVObject* object in objects) {
                    [object deleteEventually];
                }
            }
            else {
                [self alert:@"Alert" message:error.localizedDescription];
            }
        }];
        AVQuery* newsQuery = [AVQuery queryWithClassName:@"News"];
        [newsQuery whereKey:@"by" equalTo:[cell.usernameBtn titleForState:UIControlStateNormal]];
//        [newsQuery whereKey:@"to" equalTo:[self.commentUuidArray lastObject]];
        [newsQuery whereKey:@"owner" equalTo:[self.commentOwnerArray lastObject]];
        [newsQuery whereKey:@"detailID" equalTo:[self.commentUuidArray lastObject]];
        [newsQuery whereKey:@"message" equalTo:[cell.commentLbl.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        [newsQuery whereKey:@"type" containedIn:@[@"comment", @"mention"]];
        [newsQuery deleteAllInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        }];
        
    }];
//    添加@按钮
    UITableViewRowAction* address = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"@" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        self.commentTxt.text = [NSString stringWithFormat:@"%@@"@"%@", self.commentTxt.text, [self.usernameArray objectAtIndex:indexPath.row]];
        [self.sendBtn setEnabled:YES];
        [self.tableView setEditing:NO animated:YES];
    }];
    address.backgroundColor = [UIColor greenColor];
//    添加投诉按钮
    UITableViewRowAction* complain = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"投诉" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        AVObject* complain = [AVObject objectWithClassName:@"complain"];
        [complain setObject:[AVUser currentUser].username forKey:@"by"];
        [complain setObject:cell.commentLbl.text forKey:@"to"];
        [complain setObject:[self.commentUuidArray lastObject] forKey:@"detailID"];
        [complain setObject:[cell.usernameBtn titleForState:UIControlStateNormal] forKey:@"owner"];
        [complain saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error == nil) {
                [self alert:@"提示" message:@"投诉已经处理了！"];
                [self.tableView setEditing:NO animated:YES];
            }
            else {
                [self alert:@"Alert" message:error.localizedDescription];
            }
        }];
    }];
//    如果当前用户是发表评论的本人
    if ([[AVUser currentUser].username isEqualToString:[cell.usernameBtn titleForState:UIControlStateNormal]]) {
        return @[delete, address, complain];
    }
//    如果当前用户是发表帖子本人
    else if ([[self.commentOwnerArray lastObject] isEqualToString:[AVUser currentUser].username]) {
        return @[delete, address, complain];
    }
//    如果是其他用户
    else {
        return @[address, complain];
    }
}

/**
 首次加载评论数据
 */
- (void)loadComment {
//    首先查找一幅图片的评论总数
    AVQuery* commentQuery = [AVQuery queryWithClassName:@"comment"];
    [commentQuery whereKey:@"to" equalTo:[self.commentUuidArray lastObject]];
    [commentQuery countObjectsInBackgroundWithBlock:^(NSInteger number, NSError * _Nullable error) {
        if (error == nil) {
//            如果评论总数多于加载的评论
            if (self.pages < number) {
//                添加下拉刷新
                self.refreash = [[UIRefreshControl alloc] init];
                [self.refreash addTarget:self action:@selector(loadMore) forControlEvents:UIControlEventValueChanged];
                [self.tableView addSubview:self.refreash];
//                加载评论数据
                AVQuery* query = [AVQuery queryWithClassName:@"comment"];
                [query whereKey:@"to" equalTo:[self.commentUuidArray lastObject]];
//                跳过前面number-self.pages个评论，加载最后pages个评论
                [query setSkip:number - self.pages];
//                升序，日期从最早的开始，排到最晚
                [query addAscendingOrder:@"createdAt"];
//                获取数据
                [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                    if (error == nil) {
                        [self.usernameArray removeAllObjects];
                        [self.avaArray removeAllObjects];
                        [self.commentArray removeAllObjects];
                        [self.dateArray removeAllObjects];
                        for (AVObject* object in objects) {
                            [self.usernameArray addObject:[object objectForKey:@"username"]];
                            [self.avaArray addObject:[object objectForKey:@"ava"]];
                            [self.commentArray addObject:[object objectForKey:@"comment"]];
                            [self.dateArray addObject:[object objectForKey:@"createdAt"]];
                        }
//                        加载完数据后刷新tableView，并让tableView滚动到最后一个cell，也就是最新的一个评论
                        [self.tableView reloadData];
                        if ([self.commentArray count] > 0) {
                            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.commentArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                        }
                    }
                    else {
                        [self alert:@"警告" message:error.localizedDescription];
                    }
                }];
            }
            else {
                AVQuery* query = [AVQuery queryWithClassName:@"comment"];
                [query whereKey:@"to" equalTo:[self.commentUuidArray lastObject]];
                [query addAscendingOrder:@"createdAt"];
                [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                    if (error == nil) {
                        [self.usernameArray removeAllObjects];
                        [self.avaArray removeAllObjects];
                        [self.commentArray removeAllObjects];
                        [self.dateArray removeAllObjects];
                        for (AVObject* object in objects) {
                            [self.usernameArray addObject:[object objectForKey:@"username"]];
                            [self.avaArray addObject:[object objectForKey:@"ava"]];
                            [self.commentArray addObject:[object objectForKey:@"comment"]];
                            [self.dateArray addObject:[object objectForKey:@"createdAt"]];
                        }
//                        加载完数据后刷新tableView，并让tableView滚动到最后一个cell，也就是最新的一个评论
                        [self.tableView reloadData];
                        if ([self.commentArray count] > 0) {
                            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.commentArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                        }
                    }
                    else {
                        [self alert:@"警告" message:error.localizedDescription];
                    }
                }];
            }
        }
        else {
            [self alert:@"警告" message:error.localizedDescription];
        }
    }];
}


/**
 加载更多的数据
 */
- (void)loadMore {
    AVQuery* commentsQuery = [AVQuery queryWithClassName:@"comment"];
    [commentsQuery whereKey:@"to" equalTo:[self.commentUuidArray lastObject]];
    [commentsQuery countObjectsInBackgroundWithBlock:^(NSInteger number, NSError * _Nullable error) {
        if (self.pages >= number) {
            [self.refreash removeFromSuperview];
        }
        else {
            self.pages += 12;
            AVQuery* query =[AVQuery queryWithClassName:@"comment"];
            [query whereKey:@"to" equalTo:[self.commentUuidArray lastObject]];
            [query setSkip:number - self.pages];
            [query addAscendingOrder:@"createdAt"];
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if (error == nil) {
                    [self.usernameArray removeAllObjects];
                    [self.avaArray removeAllObjects];
                    [self.commentArray removeAllObjects];
                    [self.dateArray removeAllObjects];
                    for (AVObject* object in objects) {
                        [self.usernameArray addObject:[object objectForKey:@"username"]];
                        [self.avaArray addObject:[object objectForKey:@"ava"]];
                        [self.commentArray addObject:[object objectForKey:@"comment"]];
                        [self.dateArray addObject:[object objectForKey:@"createdAt"]];
                    }
                    [self.tableView reloadData];
                    if ([self.commentArray count] > 0) {
                        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.commentArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                    }
                }
                else {
                    [self alert:@"警告" message:error.localizedDescription];
                }
            }];
        }
    }];
}

//当键盘出现的时候输入框上移
- (void)keyboardWillShow:(NSNotification *)notification {
    self.keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.4 animations:^{
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableViewHeight - self.keyboardFrame.size.height);
        self.commentTxt.frame = CGRectMake(self.commentTxt.frame.origin.x, self.commentY - self.keyboardFrame.size.height, self.commentTxt.frame.size.width, self.commentTxt.frame.size.height);
        self.sendBtn.frame = CGRectMake(self.sendBtn.frame.origin.x, self.commentTxt.frame.origin.y, self.sendBtn.frame.size.width, self.sendBtn.frame.size.height);
        [self.tableView reloadData];
        if ([self.commentArray count] > 0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.commentArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }];
}

//当键盘消失的时候输入框下移
- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.4 animations:^{
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableViewHeight);
        self.commentTxt.frame = CGRectMake(self.commentTxt.frame.origin.x, self.commentY, self.commentTxt.frame.size.width, self.commentTxt.frame.size.height);
        self.sendBtn.frame = CGRectMake(self.sendBtn.frame.origin.x, self.commentTxt.frame.origin.y, self.sendBtn.frame.size.width, self.sendBtn.frame.size.height);
    }];
    [self.tableView reloadData];
    if ([self.commentArray count] > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.commentArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

//滑动返回上一级
- (void)swipeBack:(UISwipeGestureRecognizer *)gesture {
    if ([self.commentUuidArray count] > 0) {
        [self.commentUuidArray removeLastObject];
    }
    if ([self.commentOwnerArray count] > 0) {
        [self.commentOwnerArray removeLastObject];
    }
    self.commentUuid = nil;
    self.commentOwner = nil;
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

//返回上一级
- (void)back:(UIBarButtonItem *)item {
    if ([self.commentUuidArray count] > 0) {
        [self.commentUuidArray removeLastObject];
    }
    if ([self.commentOwnerArray count] > 0) {
        [self.commentOwnerArray removeLastObject];
    }
    self.commentUuid = nil;
    self.commentOwner = nil;
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.commentArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


/**
 UITableViewDelegate,估算每个表格的高度，如果表格的高度是可变的，则需要花费很多时间去估算整个表格的高度，用估算的方法可以推迟这些计算，从而提高用户的使用体验
 */
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
//    获取用户名
    [cell.usernameBtn setTitle:[self.usernameArray objectAtIndex:indexPath.row] forState:UIControlStateNormal];
//    获取头像
    [[self.avaArray objectAtIndex:indexPath.row] getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error == nil) {
            cell.avaImg.image = [UIImage imageWithData:data];
        }
        else {
            [self alert:@"警告" message:error.localizedDescription];
        }
    }];
//    获取日期
    NSDate* from = [self.dateArray objectAtIndex:indexPath.row];
    NSDate* now = [NSDate date];
    NSCalendarUnit unit = NSCalendarUnitWeekOfMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:unit fromDate:from toDate:now options:0];
    if (components.weekOfMonth > 0) {
        cell.DateLbl.text = [NSString stringWithFormat:@"%ld周", components.weekOfMonth];
    }
    else if (components.day > 0) {
        cell.DateLbl.text = [NSString stringWithFormat:@"%ld天", components.day];
    }
    else if (components.hour > 0) {
        cell.DateLbl.text = [NSString stringWithFormat:@"%ld小时", components.hour];
    }
    else if (components.minute > 0) {
        cell.DateLbl.text = [NSString stringWithFormat:@"%ld分钟", components.minute];
    }
    else if (components.second > 0) {
        cell.DateLbl.text = [NSString stringWithFormat:@"%ld秒", components.second];
    }
    else {
        cell.DateLbl.text = @"现在";
    }
//    设置评论内容
    cell.commentLbl.text = [self.commentArray objectAtIndex:indexPath.row];
//   setCancelsTouchesInView当此属性为YES（默认值）并且接收者识别其手势时，未挂载的手势的触摸不会传递到视图，并且先前传送的触摸将通过touchesCancelled：withEvent：消息发送到视图而被取消。如果手势识别器无法识别其手势，或者该属性的值为否，则该视图将接收多点触摸序列中的所有触摸
    [[self.tableView.gestureRecognizers lastObject] setCancelsTouchesInView:NO];
//    当用户点击@mention的时候发生跳转
    [cell.commentLbl setUserHandleLinkTapHandler:^(KILabel *label, NSString *string, NSRange range) {
//        截取掉第一个@字符
        NSString* message = [string substringFromIndex:1];
//        如果@的是自己，则跳到自己的主页
        if ([message.lowercaseString isEqualToString:[AVUser currentUser].username]) {
            HomeVC* home = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
            [self.navigationController pushViewController:home animated:YES];
        }
//        如果不是自己的主页，则跳到访客页面
        else {
            AVQuery* query = [AVUser query];
            [query whereKey:@"username" equalTo:message];
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if (error == nil && [objects count] > 0) {
                    GuestVC* guest = [self.storyboard instantiateViewControllerWithIdentifier:@"GuestVC"];
                    guest.user = [objects lastObject];
                    guest.username = [[objects lastObject] objectForKey:@"username"];
                    [self.navigationController pushViewController:guest animated:YES];
                }
                else if ([objects count] == 0) {
                    [self alert:@"提示" message:[NSString stringWithFormat:@"小编用尽洪荒之力也没有发现%@用户存在", message]];
                }
            }];
        }
    }];
//    当用户点击hashtag内容时，跳转到所有有关hashtag的内容页面
    [cell.commentLbl setHashtagLinkTapHandler:^(KILabel* label, NSString* string, NSRange range) {
        HashtagsVC* hashtagsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HashtagsVC"];
        hashtagsVC.hashtag = [string substringFromIndex:1];
        [self.navigationController pushViewController:hashtagsVC animated:YES];
    }];
//    为用户名button添加信息
    [cell.usernameBtn.layer setValue:indexPath forKey:@"index"];
    return cell;
}

/**
 布局
 */
- (void)alignment {
//    获取窗口的高度和宽度
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
//     设置表格的高度
    self.tableView.frame = CGRectMake(0, 0, width, height / 1.096 - self.navigationController.navigationBar.frame.size.height - 20);
//    设置评论区的位置
    self.commentTxt.frame = CGRectMake(10, self.tableView.frame.size.height + height / 56, width / 1.306, 33);
//    设置发送按钮的位置
    self.sendBtn.frame = CGRectMake(self.commentTxt.frame.origin.x + self.commentTxt.frame.size.width + width / 32, self.commentTxt.frame.origin.y, width - self.commentTxt.frame.origin.x - self.commentTxt.frame.size.width - width / 32 * 2, self.commentTxt.frame.size.height);
//    记录初始值
    self.tableViewHeight = self.tableView.frame.size.height;
    self.commentY = self.commentTxt.frame.origin.y;
    self.commentHeight = self.commentTxt.frame.size.height;
//    动态调整单元格的高度
    [self.tableView setEstimatedRowHeight:width / 5.33];
    [self.tableView setRowHeight:UITableViewAutomaticDimension];
//    设置输入框为圆角
    [self.commentTxt.layer setCornerRadius:self.commentTxt.frame.size.width / 50];
    [self.commentTxt.layer setMasksToBounds:YES];
    [self.commentTxt.layer setBorderWidth:1];
    [self.commentTxt.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [self.commentTxt setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
}


/**
 1.当用户在评论文本框中没有输入文本时，禁用上传按钮
 2.根据输入内容的长度动态调整commentTxt的高度

 @param textView commentTxt
 */
- (void)textViewDidChange:(UITextView *)textView {
//    1.当用户在评论文本框中没有输入文本时，禁用上传按钮
    if ([self.commentTxt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] == nil) {
        [self.sendBtn setEnabled:NO];
    }
    else {
        [self.sendBtn setEnabled:YES];
    }
//    2.根据输入内容的长度动态调整commentTxt的高度
    CGSize contentSize = CGSizeMake(textView.frame.size.width, MAXFLOAT);
    CGFloat height = ceilf([textView sizeThatFits:contentSize].height);
    NSLog(@"测试文本高度的变化: %f", height);
    if (height > textView.frame.size.height && height <= 88) {
//        文本内容与文本框高度的差
        CGFloat different = height - textView.frame.size.height;
//        调整文本框的高度（向上调整）
        textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y - different, textView.frame.size.width, height);
//        由于文本框向上调整，tableView也要跟着向上调整
        if (textView.frame.size.height + self.keyboardFrame.size.height + self.commentY >= self.tableView.frame.size.height) {
            self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height - different);
        }
        [textView setScrollEnabled:NO];
    }
    else if (height < textView.frame.size.height) {
//        文本框与文本内容高度的差
        if (height < 33) {
            height = 33;
        }
        CGFloat different = textView.frame.size.height - height;
//        调整文本框的高度（向下调整）
        textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y + different, textView.frame.size.width, height);
//        由于文本框向下调整，tableView也要跟着向下调整
        if (textView.contentSize.height + self.commentY + self.keyboardFrame.size.height > self.tableView.frame.size.height) {
            self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height + different);
        }
    }
    if (height >= 88) {
        height = 102;
        CGFloat different = height - textView.frame.size.height;
        //        调整文本框的高度（向上调整）
        textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y - different, textView.frame.size.width, height);
        //        由于文本框向上调整，tableView也要跟着向上调整
        if (textView.frame.size.height + self.keyboardFrame.size.height + self.commentY >= self.tableView.frame.size.height) {
            self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height - different);
        }
        [textView setScrollEnabled:YES];
    }
}

//显示警告信息
- (void)alert:(NSString *)title message:(NSString *)message {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}


/**
 点击发送按钮

 @param sender 发送按钮
 */
- (IBAction)sendBtn_clicked:(UIButton *)sender {
//    评论消息
    NSString* message = [self.commentTxt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    发送hashTag到云端
//    将句子拆分成单词
    NSArray* words = [self.commentTxt.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    for (NSString* word in words) {
//    模式为#接着一个或多个非#
        NSString* pattern = @"#[^#]+";
        NSRegularExpression* regular = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray<NSTextCheckingResult *> *results = [regular matchesInString:word options:NSMatchingReportProgress range:NSMakeRange(0, [word length])];
        for (NSTextCheckingResult* result in results) {
            NSString* hashWord = [word substringWithRange:result.range];
            if ([hashWord hasPrefix:@"#"]) {
                hashWord = [hashWord stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
                hashWord = [hashWord stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]];
                AVObject* hashTagObj = [AVObject objectWithClassName:@"Hashtag"];
                [hashTagObj setObject:self.commentUuidArray.lastObject forKey:@"to"];
                [hashTagObj setObject:[AVUser currentUser].username forKey:@"from"];
                [hashTagObj setObject:hashWord forKey:@"hashtag"];
                [hashTagObj setObject:[self.commentTxt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"comment"];
                [hashTagObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (error == nil) {
                        NSLog(@"hashTag 已创建");
                    }
                    else {
                        [self alert:@"Alert" message:error.localizedDescription];
                    }
                }];
            }
        }
    }
//    将评论送到云端后刷新表格
    AVObject* comment = [AVObject objectWithClassName:@"comment"];
    [comment setObject:[AVUser currentUser].username forKey:@"username"];
    [comment setObject:[AVUser currentUser].objectId forKey:@"userID"];
    [comment setObject:[[AVUser currentUser] objectForKey:@"ava"] forKey:@"ava"];
    [comment setObject:[self.commentUuidArray lastObject] forKey:@"to"];
    [comment setObject:message forKey:@"comment"];
    [comment setObject:[AVUser currentUser].objectId forKey:@"userID"];
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error == nil) {
            [self.usernameArray addObject:[AVUser currentUser].username];
            [self.avaArray addObject:[[AVUser currentUser] objectForKey:@"ava"]];
            [self.commentArray addObject:message];
            [self.dateArray addObject:[NSDate date]];
            self.commentTxt.text = nil;
            self.commentTxt.frame = CGRectMake(self.commentTxt.frame.origin.x, self.sendBtn.frame.origin.y, self.commentTxt.frame.size.width, self.commentHeight);
            self.tableView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.tableViewHeight - self.keyboardFrame.size.height);
            [self loadComment];
        }
    }];
    
    for (NSString* word in words) {
        NSString* pattern = @"@[^@]+";
        NSRegularExpression* regular = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray<NSTextCheckingResult *> *results = [regular matchesInString:word options:NSMatchingReportProgress range:NSMakeRange(0, [word length])];
        for (NSTextCheckingResult* result in results) {
            NSString* mentionWord = [word substringWithRange:result.range];
            if ([mentionWord hasPrefix:@"@"]) {
                mentionWord = [mentionWord stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
                mentionWord = [mentionWord stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]];
                AVObject* news = [AVObject objectWithClassName:@"News"];
                [news setObject:[AVUser currentUser].username forKey:@"by"];
                [news setObject:mentionWord forKey:@"to"];
                [news setObject:[self.commentOwnerArray lastObject] forKey:@"owner"];
                [news setObject:@"mention" forKey:@"type"];
                [news setObject:@"no" forKey:@"checked"];
                [news setObject:[[AVUser currentUser] objectForKey:@"ava"] forKey:@"ava"];
                [news setObject:[self.commentUuidArray lastObject] forKey:@"detailID"];
                [news setObject:message forKey:@"message"];
                [news saveEventually];
                if (![[AVUser currentUser].username isEqualToString:[self.commentOwnerArray lastObject]]) {
                    AVObject* newsComment = [AVObject objectWithClassName:@"News"];
                    [newsComment setObject:[AVUser currentUser].username forKey:@"by"];
                    [newsComment setObject:mentionWord forKey:@"to"];
                    [newsComment setObject:[self.commentOwnerArray lastObject] forKey:@"owner"];
                    [newsComment setObject:@"comment" forKey:@"type"];
                    [newsComment setObject:@"no" forKey:@"checked"];
                    [newsComment setObject:[[AVUser currentUser] objectForKey:@"ava"] forKey:@"ava"];
                    [newsComment setObject:[self.commentUuidArray lastObject] forKey:@"detailID"];
                    [newsComment setObject:message forKey:@"message"];
                    [newsComment saveEventually];
                }
            }
        }
    }
}

- (IBAction)username_clicked:(UIButton *)sender {
    CommentCell* cell = [self.tableView cellForRowAtIndexPath:[sender.layer valueForKey:@"index"]];
    if ([[cell.usernameBtn titleForState:UIControlStateNormal] isEqualToString:[AVUser currentUser].username]) {
        HomeVC* home = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
        [self.navigationController pushViewController:home animated:YES];
    }
    else {
        AVQuery* query = [AVUser query];
        [query whereKey:@"username" equalTo:[sender titleForState:UIControlStateNormal]];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (error == nil) {
                GuestVC* guest = [self.storyboard instantiateViewControllerWithIdentifier:@"GuestVC"];
                guest.username = [sender titleForState:UIControlStateNormal];
                guest.user = [objects lastObject];
                [self.navigationController pushViewController:guest animated:YES];
            }
            else {
                [self alert:@"警告" message:error.localizedDescription];
            }
        }];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return  YES;
}


@end
