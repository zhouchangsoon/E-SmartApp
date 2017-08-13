//
//  NewsVC.m
//  Instagram
//
//  Created by zcs on 2017/7/8.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import "NewsVC.h"

@interface NewsVC ()

@end

@implementation NewsVC
{
    NSMutableArray<NSString *> *byArray;
    NSMutableArray<NSString *> *toArray;
    NSMutableArray<NSString *> *puuidArray;
    NSMutableArray<AVFile *> *avaImgArray;
    NSMutableArray<NSString *> *typeArray;
    NSMutableArray<NSDate *> *dateArray;
    NSMutableArray<NSString *> *ownerArray;
    NSMutableArray<NSString *> *idArray;
    UIRefreshControl *refresher;
    int page;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    数据初始化
    [self initData];
//    加载刷新器
    [refresher addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:refresher];
//    去掉多余的分割线
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    //    加载数据
    [self loadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"check" object:nil];
}

/**
 数据初始化
 */
- (void)initData {
    byArray = [[NSMutableArray alloc] init];
    toArray = [[NSMutableArray alloc] init];
    puuidArray = [[NSMutableArray alloc] init];
    avaImgArray = [[NSMutableArray alloc] init];
    typeArray = [[NSMutableArray alloc] init];
    dateArray = [[NSMutableArray alloc] init];
    refresher = [[UIRefreshControl alloc] init];
    ownerArray = [[NSMutableArray alloc] init];
    idArray = [[NSMutableArray alloc] init];
    page = 10;
}


/**
 加载数据
 */
- (void)loadData {
    AVQuery* newsQuery = [AVQuery queryWithClassName:@"News"];
    [newsQuery whereKey:@"to" equalTo:[AVUser currentUser].username];
    [newsQuery setLimit:page];
    [newsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            [byArray removeAllObjects];
            [toArray removeAllObjects];
            [puuidArray removeAllObjects];
            [avaImgArray removeAllObjects];
            [typeArray removeAllObjects];
            [dateArray removeAllObjects];
            [idArray removeAllObjects];
            for (AVObject* object in objects) {
                [byArray addObject:[object objectForKey:@"by"]];
                [toArray addObject:[object objectForKey:@"to"]];
                [puuidArray addObject:[object objectForKey:@"detailID"]];
                [avaImgArray addObject:[object objectForKey:@"ava"]];
                [typeArray addObject:[object objectForKey:@"type"]];
                [dateArray addObject:[object objectForKey:@"createdAt"]];
                [ownerArray addObject:[object objectForKey:@"owner"]];
                [idArray addObject:[object objectForKey:@"objectId"]];
                [object setObject:@"yes" forKey:@"checked"];
                [object saveEventually];
            }
            [self.tableView reloadData];
            [refresher endRefreshing];
        }
        else {
            [self alert:@"Alert" message:error.localizedDescription];
        }
    }];
}

- (void)loadMoreData {
    if (page <= [toArray count]) {
        page += 10;
        AVQuery* newsQuery = [AVQuery queryWithClassName:@"News"];
        [newsQuery whereKey:@"to" equalTo:[AVUser currentUser].username];
        [newsQuery setLimit:page];
        [newsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (error == nil) {
                [byArray removeAllObjects];
                [toArray removeAllObjects];
                [puuidArray removeAllObjects];
                [avaImgArray removeAllObjects];
                [typeArray removeAllObjects];
                [dateArray removeAllObjects];
                [idArray removeAllObjects];
                for (AVObject* object in objects) {
                    [byArray addObject:[object objectForKey:@"by"]];
                    [toArray addObject:[object objectForKey:@"to"]];
                    [puuidArray addObject:[object objectForKey:@"detailID"]];
                    [avaImgArray addObject:[object objectForKey:@"ava"]];
                    [typeArray addObject:[object objectForKey:@"type"]];
                    [dateArray addObject:[object objectForKey:@"createdAt"]];
                    [ownerArray addObject:[object objectForKey:@"owner"]];
                    [idArray addObject:[object objectForKey:@"objectId"]];
                    [object setObject:@"yes" forKey:@"checked"];
                    [object saveEventually];
                }
                [self.tableView reloadData];
            }
            else {
                [self alert:@"Alert" message:error.localizedDescription];
            }
        }];
    }
}


/**
 下拉刷新

 @param scrollView scrollView description
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y >= self.tableView.contentSize.height - self.view.frame.size.height) {
        [self loadMoreData];
    }
}

/**
 显示警告信息

 @param title 警告标题
 @param message 警告信息
 */
- (void)alert:(NSString *)title message:(NSString *)message {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [toArray count];
}



/**
 设置表格内容
 
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
//    设置cell布局
    [cell autoLayout];
    
//    设置用户名
    [cell.usernameBtn setTitle:[byArray objectAtIndex:indexPath.row] forState:UIControlStateNormal];
    
//    设置头像
    [[avaImgArray objectAtIndex:indexPath.row] getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error == nil) {
            cell.avaImg.image = [UIImage imageWithData:data];
        }
        else {
            [self alert:@"Alert" message:error.localizedDescription];
        }
    }];
    
//    设置消息
    NSString* type = [typeArray objectAtIndex:indexPath.row];
    if ([type isEqualToString:@"mention"]) {
        cell.infoLbl.text = @"@mention了你";
    }
    else if ([type isEqualToString:@"comment"]) {
        cell.infoLbl.text = @"评论了你的帖子";
    }
    else if ([type isEqualToString:@"like"]) {
        cell.infoLbl.text = @"喜欢你的帖子";
    }
    else if ([type isEqualToString:@"follow"]) {
        cell.infoLbl.text = @"关注了你";
    }
    
//    设置时间
    NSDate *now = [NSDate date];
    NSDate *from = [dateArray objectAtIndex:indexPath.row];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitWeekOfMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents* component = [calendar components:unit fromDate:from toDate:now options:NSCalendarMatchStrictly];
    if (component.weekOfMonth > 0) {
        cell.dateLbl.text = [NSString stringWithFormat:@"%lu周", component.weekOfMonth];
    }
    else if (component.day > 0) {
        cell.dateLbl.text = [NSString stringWithFormat:@"%lu天", component.day];
    }
    else if (component.hour > 0) {
        cell.dateLbl.text = [NSString stringWithFormat:@"%lu小时", component.hour];
    }
    else if (component.minute > 0) {
        cell.dateLbl.text = [NSString stringWithFormat:@"%lu分钟", component.minute];
    }
    else if (component.second > 0) {
        cell.dateLbl.text = [NSString stringWithFormat:@"%lu秒", component.second];
    }
    else {
        cell.dateLbl.text = @"现在";
    }
    
//    设置用户按钮的indexPath，为点击跳转做准备
    [cell.usernameBtn.layer setValue:indexPath forKey:@"index"];
    
    return cell;
}
//end cellForRowAtIndexpath


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString* message = cell.infoLbl.text;
    if ([message isEqualToString:@"@mention了你"] || [message isEqualToString:@"评论了你的帖子"]) {
        CommentVC* commentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentVC"];
        [self hidesBottomBarWhenPushed];
        commentVC.commentUuid = [puuidArray objectAtIndex:indexPath.row];
        commentVC.commentOwner = [ownerArray objectAtIndex:indexPath.row];
        [commentVC feedInitData];
        [self.navigationController pushViewController:commentVC animated:YES];
        [self setHidesBottomBarWhenPushed:NO];
    }
    else if ([message isEqualToString:@"喜欢你的帖子"]) {
        PostVC* postVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PostVC"];
        postVC.post = [puuidArray objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:postVC animated:YES];
    }
    else if ([message isEqualToString:@"关注了你"]) {
        GuestVC* guestVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GuestVC"];
        AVQuery* userQuery = [AVUser query];
        [userQuery whereKey:@"username" equalTo:[byArray objectAtIndex:indexPath.row]];
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (error == nil) {
                if ([objects count] == 0) {
                    [self alert:@"提示" message:[NSString stringWithFormat:@"小编用尽洪荒之力也没有发现%@用户存在", [byArray objectAtIndex:indexPath.row]]];
                }
                else {
                    guestVC.user = [objects lastObject];
                    guestVC.username = [byArray objectAtIndex:indexPath.row];
                    [self.navigationController pushViewController:guestVC animated:YES];
                }
            }
        }];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction* delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        AVQuery* query = [AVQuery queryWithClassName:@"News"];
        [query whereKey:@"objectId" equalTo:[idArray objectAtIndex:indexPath.row]];
        [query deleteAllInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        }];
        [byArray removeObjectAtIndex:indexPath.row];
        [toArray removeObjectAtIndex:indexPath.row];
        [puuidArray removeObjectAtIndex:indexPath.row];
        [avaImgArray removeObjectAtIndex:indexPath.row];
        [idArray removeObjectAtIndex:indexPath.row];
        [typeArray removeObjectAtIndex:indexPath.row];
        [dateArray removeObjectAtIndex:indexPath.row];
        [ownerArray removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }];
    return @[delete];
}

- (IBAction)usernameBtn_clicked:(UIButton *)sender {
    NSIndexPath *index = [sender.layer valueForKey:@"index"];
    NewsCell* cell = [self.tableView cellForRowAtIndexPath:index];
    NSString* username = [cell.usernameBtn titleForState:UIControlStateNormal];
    if ([username isEqualToString:[AVUser currentUser].username]) {
        HomeVC* home = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
        [self.navigationController pushViewController:home animated:YES];
    }
    else {
        AVQuery* userQuery = [AVUser query];
        [userQuery whereKey:@"username" equalTo:username];
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (error == nil) {
                if ([objects count] == 0) {
                    [self alert:@"提示" message:[NSString stringWithFormat:@"小编用尽洪荒之力也没有发现%@用户存在", username]];
                }
                else {
                    GuestVC* guest = [self.storyboard instantiateViewControllerWithIdentifier:@"GuestVC"];
                    guest.user = [objects lastObject];
                    guest.username = username;
                    [self.navigationController pushViewController:guest animated:YES];
                }
            }
        }];
    }
}



@end
