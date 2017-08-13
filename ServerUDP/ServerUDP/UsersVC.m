//
//  UsersVC.m
//  Instagram
//
//  Created by zcs on 2017/7/4.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import "UsersVC.h"

@interface UsersVC ()

@end

@implementation UsersVC
{
//    存储从云端下载下来的信息
    NSMutableArray<NSString *> *usernameArray;
    NSMutableArray<AVFile *> *avaArray;
//    搜索栏
    UISearchBar* searchBar;
//    首次加载的数目
    int pages;
    int postPages;
//    集合视图
    UICollectionView* collectionView;
//    存储集合视图从云端中下载下来的信息
    NSMutableArray<AVFile *> *picArray;
    NSMutableArray<NSString *> *puuidArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    初始化数据
    usernameArray = [[NSMutableArray alloc] init];
    avaArray = [[NSMutableArray alloc] init];
    searchBar = [[UISearchBar alloc] init];
    picArray = [[NSMutableArray alloc] init];
    puuidArray = [[NSMutableArray alloc] init];
    pages = 10;
    postPages = 12;
    searchBar.showsCancelButton = YES;
    searchBar.delegate = self;
//    设置搜索栏
    searchBar.frame = CGRectMake(searchBar.frame.origin.x, searchBar.frame.origin.y, self.view.frame.size.width - 30, searchBar.frame.size.height);
    UIBarButtonItem* searchBarItem = [[UIBarButtonItem alloc] initWithCustomView:searchBar];
    [self.navigationItem setLeftBarButtonItem:searchBarItem];
//    加载数据
    [self loadData];
    [self loadPost];
    [self collectionViewLaunch];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 加载数据(用户名和头像)
 */
- (void)loadData {
    AVQuery* userQuery = [AVUser query];
    [userQuery addDescendingOrder:@"CreatedAt"];
    [userQuery setLimit:10];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil && [objects count] > 0) {
            [usernameArray removeAllObjects];
            [avaArray removeAllObjects];
            for (AVUser* user in objects) {
                [usernameArray addObject:user.username];
                [avaArray addObject:[user objectForKey:@"ava"]];
            }
            [self.tableView reloadData];
        }
        else if (error) {
            [self alert:@"Alert" message:error.localizedDescription];
        }
    }];
}


/**
 加载更多的数据
 */
- (void)loadMore {
    if (pages <= [usernameArray count]) {
        AVQuery* userQuery = [AVUser query];
        [userQuery addDescendingOrder:@"CreatedAt"];
        [userQuery setSkip:pages];
        [userQuery setLimit:10];
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (error == nil && [objects count] > 0) {
                for (AVUser* user in objects) {
                    [usernameArray addObject:user.username];
                    [avaArray addObject:[user objectForKey:@"ava"]];
                }
                [self.tableView reloadData];
            }
            else if (error) {
                [self alert:@"Alert" message:error.localizedDescription];
            }
        }];
        pages += 10;
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

#pragma mark UISearchBarDelegate

/**
 当用户搜索时显示加载相关内容

 @param searchBar searchBar description
 @param searchText searchText description
 */
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //    首先在用户名中搜索
    AVQuery* userQuery = [AVUser query];
    [userQuery whereKey:@"username" matchesRegex:[NSString stringWithFormat:@"(?i)%@", searchText]];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            [usernameArray removeAllObjects];
            [avaArray removeAllObjects];
            if ([objects count] > 0) {
                for (AVUser* user in objects) {
                    [usernameArray addObject:user.username];
                    [avaArray addObject:[user objectForKey:@"ava"]];
                }
            }
            //            如果在用户名中没有找到，则在fullname中继续搜索
            else {
                AVQuery* fullnameQuery = [AVQuery queryWithClassName:@"fullname"];
                [fullnameQuery whereKey:@"username" matchesRegex:[NSString stringWithFormat:@"(?i)%@", searchText]];
                [fullnameQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                    if (error == nil && [objects count] > 0) {
                        for (AVUser* user in objects) {
                            [usernameArray addObject:user.username];
                            [avaArray addObject:[user objectForKey:@"ava"]];
                        }
                    }
                    else {
                        [self alert:@"Alert" message:error.localizedDescription];
                    }
                }];
            }
            [self.tableView reloadData];
        }
        else {
            [self alert:@"Alert" message:error.localizedDescription];
        }
    }];
}


/**
 当用户取消搜索的时候，显示collectionView

 @param searchBar searchBar
 */
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [collectionView setHidden:NO];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [collectionView setHidden:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

/**
 下滑到底部刷新

 @param scrollView scrollView description
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - self.tableView.frame.size.height) {
        if ([collectionView isHidden] == false) {
            [self loadMorePost];
        }
        else {
            [self loadMore];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [usernameArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FollowersCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.usernameLbl.text = [usernameArray objectAtIndex:indexPath.row];
    [[avaArray objectAtIndex:indexPath.row] getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error == nil) {
            cell.avaImg.image = [UIImage imageWithData:data];
        }
    }];
    cell.followBtn.hidden = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FollowersCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.usernameLbl.text isEqualToString:[AVUser currentUser].username]) {
        HomeVC *home = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
        [self.navigationController pushViewController:home animated:YES];
    }
    else {
        AVQuery* userQuery = [AVUser query];
        [userQuery whereKey:@"username" equalTo:cell.usernameLbl.text];
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (error == nil) {
                AVUser* user = [objects lastObject];
                GuestVC* guest = [self.storyboard instantiateViewControllerWithIdentifier:@"GuestVC"];
                guest.user = user;
                guest.username = user.username;
                [self.navigationController pushViewController:guest animated:YES];
            }
            else {
                [self alert:@"Alert" message:error.localizedDescription];
            }
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size.width / 4;
}


#pragma mark UICollectionView


/**
 加载collectionView
 */
- (void)collectionViewLaunch {
//    创建layout来控制cell的布局
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setItemSize:CGSizeMake(self.view.frame.size.width / 3 - 4, self.view.frame.size.width / 3 - 4)];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 6;
    layout.minimumInteritemSpacing = 6;
//    layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 30);
//    设置collectionView的位置,其高度大小为屏幕的高度减去导航栏的高度减去标签栏的高度减去状态栏的高度（20）
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - self.tabBarController.tabBar.frame.size.height - 20);
    collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
//    设置垂直滚动，则水平宽度是一个定值，高度随着内容的改变而改变
    [collectionView setAlwaysBounceVertical:YES];
//    设置代理
    [collectionView setDelegate:self];
    [collectionView setDataSource:self];
//    设置背景
    [collectionView setBackgroundColor:[UIColor whiteColor]];
//    cell和header加入可复用队列，以便复用
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
//    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
//    加入视图
    [self.view addSubview:collectionView];
}



/**
 设置行间距为6px

 @return 6
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 6;
}


/**
 设置列间距为6
 
 @return 6
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 6;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [picArray count];
}


/**
 设置cell的数据和样式

 @return cell
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    UIImageView* picView = [[UIImageView alloc] init];
    picView.frame = CGRectMake(0, 0, self.view.frame.size.width / 3 - 4, self.view.frame.size.width / 3 - 4);
    [[picArray objectAtIndex:indexPath.row] getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error == nil) {
            picView.image = [UIImage imageWithData:data];
        }
        else {
            [self alert:@"Alert" message:error.localizedDescription];
        }
    }];
    [cell addSubview:picView];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PostVC* postVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PostVC"];
    postVC.post = [puuidArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:postVC animated:YES];
}

/**
 加载collectionView的数据
 */
- (void)loadPost {
    AVQuery* postQuery = [AVQuery queryWithClassName:@"Book"];
    [postQuery setLimit:postPages];
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            NSLog(@"测试接受到帖子的数量，%lu", [objects count]);
            [picArray removeAllObjects];
            [puuidArray removeAllObjects];
            for (AVObject* object in objects) {
                [picArray addObject:[object objectForKey:@"pic"]];
                [puuidArray addObject:[object objectForKey:@"bookname"]];
            }
            [collectionView reloadData];
        }
        else {
            [self alert:@"Alert" message:error.localizedDescription];
        }
    }];
}


/**
 加载更多的collectionView的数据
 */
- (void)loadMorePost {
    if (postPages <= [picArray count]) {
        AVQuery* postQuery = [AVQuery queryWithClassName:@"Detail"];
        [postQuery setSkip:postPages];
         postPages += 12;
        [postQuery setLimit:12];
        [postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (error == nil) {
                NSLog(@"测试接受到帖子的数量，%lu", [objects count]);
                for (AVObject* object in objects) {
                    [picArray addObject:[object objectForKey:@"pic"]];
                    [puuidArray addObject:[object objectForKey:@"bookname"]];
                }
                [collectionView reloadData];
            }
            else {
                [self alert:@"Alert" message:error.localizedDescription];
            }
        }];
    }
}

@end
