//
//  HomeVC.m
//  Instagram
//
//  Created by zcs on 2017/6/1.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import "HomeVC.h"

@interface HomeVC ()

@end

@implementation HomeVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.bookID = [[NSMutableArray alloc] init];
    self.picArray = [[NSMutableArray alloc] init];
    self.page = 12;
    self.navigationItem.title = [[[AVUser currentUser] objectForKey:@"username"] uppercaseString];
    self.refresher = [[UIRefreshControl alloc] init];
    [self.refresher addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refresher];
    [self loadPosts];
    [self.collectionView setBounces:YES];
    [self.collectionView setAlwaysBounceVertical:YES];
//    接受是否更新了个人信息通知，若更新了个人信息，则reload Header
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload:) name:@"reload" object:nil];
//    接受是否更新了Post的信息，若更新了信息，则upload Post
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploaded:) name:@"uploaded" object:nil];
//    设置collectionView布局代理
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//更新个人信息（也就是更新表头的数据)
- (void)reload:(NSNotification *)notification {
//    [self loadPosts];
    [self.collectionView reloadData];
}


/**
 当用户上传了Post后，更新Collection Cell
 */
- (void)uploaded:(NSNotification *)notification {
    [self loadPosts];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    HeaderView* header = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header" forIndexPath:indexPath];
    header.fullNameLabel.text = [[[AVUser currentUser] objectForKey:@"fullname"] uppercaseString];
    header.webTxt.text = [[AVUser currentUser] objectForKey:@"web"];
    header.bioTxt.text = [[AVUser currentUser] objectForKey:@"bio"];
    [header.bioTxt sizeToFit];
    [header initFrame];
    AVFile* avaQuery = [[AVUser currentUser] objectForKey:@"ava"];
    [avaQuery getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error == nil) {
            if (data != nil) {
                header.avaImg.image = [UIImage imageWithData:data];
            }
        }
        else {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"加载错误" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    AVUser* currentUser = [AVUser currentUser];
    AVQuery* postsQuery = [AVQuery queryWithClassName:@"Book"];
    [postsQuery whereKey:@"userID" equalTo:currentUser.objectId];
    [postsQuery countObjectsInBackgroundWithBlock:^(NSInteger number, NSError * _Nullable error) {
        if (error == nil) {
            header.posts.text = [NSString stringWithFormat:@"%ld",(long)number];
        }
        else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    AVQuery* followeeQuery = [AVQuery queryWithClassName:@"_Followee"];
    [followeeQuery whereKey:@"user" equalTo:currentUser];
    [followeeQuery countObjectsInBackgroundWithBlock:^(NSInteger number, NSError * _Nullable error) {
        if (error == nil) {
            header.followings.text = [NSString stringWithFormat:@"%ld", (long)number];
        }
        else {
            NSLog(@"%@", error.description);
        }
    }];
    AVQuery* followerQuery = [AVQuery queryWithClassName:@"_Follower"];
    [followerQuery whereKey:@"user" equalTo:currentUser];
    [followerQuery countObjectsInBackgroundWithBlock:^(NSInteger number, NSError * _Nullable error) {
        if (error == nil) {
            header.followers.text = [NSString stringWithFormat:@"%ld", (long)number];
        }
        else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    UITapGestureRecognizer* followersTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFollowers:)];
    [followersTap setNumberOfTouchesRequired:1];
    [followersTap setNumberOfTapsRequired:1];
    [header.followers setUserInteractionEnabled:YES];
    [header.followers addGestureRecognizer:followersTap];
    UITapGestureRecognizer* followeringsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFollowings:)];
    [followeringsTap setNumberOfTapsRequired:1];
    [followeringsTap setNumberOfTouchesRequired:1];
    [header.followings setUserInteractionEnabled:YES];
    [header.followings addGestureRecognizer:followeringsTap];
    UITapGestureRecognizer* postsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPosts:)];
    [postsTap setNumberOfTouchesRequired:1];
    [postsTap setNumberOfTapsRequired:1];
    [header.posts setUserInteractionEnabled:YES];
    [header.posts addGestureRecognizer:postsTap];
    return header;
}


/**
 更新collectionView信息

 @param refresher 下拉刷新
 */
- (void)refresh:(UIRefreshControl *)refresher {
    [self loadPosts];
    [self.collectionView reloadData];
    [refresher endRefreshing];
    
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


/**
 当用户滑动到页面底部的时候，加载更多的数据

 @param scrollView 滑动窗口
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height) {
        [self loadMore];
    }
}


/**
 下拉加载更多内容
 */
- (void)loadMore {
    if ([self.picArray count] >= self.page) {
        AVQuery* loadMorePostQuery = [AVQuery queryWithClassName:@"Book"];
        [loadMorePostQuery whereKey:@"userID" equalTo:[AVUser currentUser].objectId];
        [loadMorePostQuery setLimit:12];
        [loadMorePostQuery setSkip:self.page];
        [loadMorePostQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (error == nil && [objects count]) {
                for (id object in objects) {
                    [self.picArray addObject:[object objectForKey:@"pic"]];
                    [self.bookID addObject:[object objectForKey:@"bookname"]];
                }
                [self.collectionView reloadData];
            }
            else {
                [self alert:@"警告" message:error.localizedDescription];
            }
        }];
        self.page += 12;
    }
}

/**
 从leanCloud加载Posts存放到self.picArray和self.puuid两个数组中
 */
- (void)loadPosts {
    AVQuery* query = [AVQuery queryWithClassName:@"Book"];
    [query whereKey:@"userID" equalTo:[AVUser currentUser].objectId];
    query.limit = self.page;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil && [objects count] > 0) {
            [self.bookID removeAllObjects];
            [self.picArray removeAllObjects];
            for (id object in objects) {
                [self.bookID addObject:[object objectForKey:@"bookname"]];
                [self.picArray addObject:[object objectForKey:@"pic"]];
            }
            [self.collectionView reloadData];
        }
    }];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.picArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
     PictureCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [cell initFrame];
    if ([self.picArray count] == 0) {
        NSLog(@"NetWork Error");
    }
    else {
        [[self.picArray objectAtIndex:indexPath.row] getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            if (error == nil) {
                cell.picImg.image = [UIImage imageWithData:data];
            }
            else {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    }
    return cell;
}

//点击Posts后滑动到第一个collectionCell，也就是第一张图片的顶部。
- (void)tapPosts:(UITapGestureRecognizer *)gesture {
    if ([self.picArray count] != 0) {
        NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.collectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
}

//点击Followers后跳到FollowersVC，其中要传输数据包括用户名，标题，还有AVUser信息
- (void)tapFollowers:(UITapGestureRecognizer *)gesture {
    FollowersVC* follower = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowersVC"];
    follower.name = [AVUser currentUser].username;
    follower.name = [AVUser currentUser].objectId;
    follower.show = @"粉 丝";
    [self.navigationController pushViewController:follower animated:YES];
}

- (void)tapFollowings:(UITapGestureRecognizer *)gesture {
    FollowersVC* followings = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowersVC"];
    followings.name = [AVUser currentUser].username;
    followings.userID = [AVUser currentUser].objectId;
    followings.show = @"关 注";
    [self.navigationController pushViewController:followings animated:YES];
}

#pragma mark <UICollectionViewDelegateFlowLayout>

/**
 设置cell的大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeMake(self.view.frame.size.width / 3.0 - 4, self.view.frame.size.width / 3.0 - 4);
    return size;
}


/**
 设置行间距
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 6;
}


/**
 设置列间距
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 6;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


/**
 选中某一个cell后跳转到PostVC

 @param collectionView 集合视图
 @param indexPath 哪个cell
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PostVC* postVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PostVC"];
    postVC.post = [self.bookID objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:postVC animated:YES];
}

//退出登录
- (IBAction)logout:(UIBarButtonItem *)sender {
    //首先在云端推出登录
    [AVUser logOut];
    //然后将在UserDefault中记录的用户名去除
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //获取将要跳转的控制器
    SignInVC* signInVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SignInVC"];
    //跳转到该控制器
    AppDelegate* app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.window.rootViewController = signInVC;
}

@end
