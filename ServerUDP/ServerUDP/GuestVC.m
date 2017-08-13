//
//  GuestVC.m
//  Instagram
//
//  Created by zcs on 2017/6/13.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import "GuestVC.h"

@interface GuestVC ()

@end

@implementation GuestVC

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
//    初始化
    if (self.guestArray == nil) {
        self.guestArray = [[NSMutableArray alloc] init];
    }
    if (self.picArray == nil) {
        self.picArray = [[NSMutableArray alloc] init];
    }
    if (self.puuidArray == nil) {
        self.puuidArray = [[NSMutableArray alloc] init];
    }
    [self.guestArray addObject:self.user];
//    设置标题
    [self.navigationItem setTitle:[self.guestArray lastObject].username];
//    首次加载图片的个数
    self.page = 12;
//    设置collectionView的样式
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView setBounces:YES];
    [self.collectionView setAlwaysBounceVertical:YES];
//    重新设置返回标题
    [self.navigationItem setHidesBackButton:YES];
    UIBarButtonItem* backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = backBtn;
//    向右滑动返回上一级
    UISwipeGestureRecognizer* backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
    [backSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:backSwipe];
//    设置下拉刷新
    self.refresher = [[UIRefreshControl alloc] init];
    [self.refresher addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.collectionView reloadData];
    [self loadPosts];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.frame.size.width / 3 - 4, self.view.frame.size.width / 3 - 4);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 6;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 6;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.picArray count];
}


/**
 用户点击单元格后显示图片

 @param collectionView collectionView description
 @param indexPath indexPath description
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PostVC* postVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PostVC"];
    postVC.post = [self.puuidArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:postVC animated:YES];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PictureCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [[self.picArray objectAtIndex:indexPath.row] getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error == nil) {
            cell.picImg.image = [UIImage imageWithData:data];
            [cell initFrame];
        }
        else {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            }
    }];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    HeaderView* header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header" forIndexPath:indexPath];
    [header initFrame];
    //查询搞用户的基本信息，包括其名字，简介，头像，网址
    AVQuery* query = [AVQuery queryWithClassName:@"_User"];
    [query whereKey:@"username" equalTo:self.username];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            if ([objects count] > 0) {
                for (NSDictionary* object in objects) {
                    header.fullNameLabel.text = [object objectForKey:@"username"];
                    header.bioTxt.text = [object objectForKey:@"bio"];
                    header.webTxt.text = [object objectForKey:@"web"];
                    AVFile* avaFile = [object objectForKey:@"ava"];
                    [avaFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                        if (error == nil) {
                            header.avaImg.image = [UIImage imageWithData:data];
                        }
                        else {
                            NSLog(@"加载图片出错，GuestVC类viewForSupplementaryElementOfKind, %@", error.localizedDescription);
                        }
                    }];
                }
            }
            else {  //如果没有在数据库中找到该用户
                [self alert:@"提示" message:[NSString stringWithFormat:@"小编用尽洪荒之力都没有找到%@用户", self.username]];
                return;
            }
        }
        else {
            [self alert:@"Alert" message:error.localizedDescription];
        }
    }];
    
    //如果现在的用户关注了目前访问的用户，则显示已关注，否则显示关注
    AVQuery* followeeQuery = [[AVUser currentUser] followeeQuery];
    [followeeQuery whereKey:@"user" equalTo:[AVUser currentUser].username];
    [followeeQuery whereKey:@"followee" equalTo:[self.guestArray lastObject]];
    [followeeQuery countObjectsInBackgroundWithBlock:^(NSInteger number, NSError * _Nullable error) {
        if (error == nil) {
            if (number == 0) {
                [header.button setTitle:@"关 注" forState:UIControlStateNormal];
                [header.button setBackgroundColor:[UIColor lightGrayColor]];
            }
            else {
                [header.button setTitle:@"已关注" forState:UIControlStateNormal];
                [header.button setBackgroundColor:[UIColor greenColor]];
            }
        }
        else {
            NSLog(@"获取关注信息失败GuestVC类viewForSupplementaryElementOfKind, %@",error.localizedDescription);
        }
    }];
    
    //查询该用户的帖子数目
    AVQuery* postQuery = [AVQuery queryWithClassName:@"Book"];
    [postQuery whereKey:@"username" equalTo:self.username];
    [postQuery countObjectsInBackgroundWithBlock:^(NSInteger number, NSError * _Nullable error) {
        if (error == nil) {
            header.posts.text = [NSString stringWithFormat:@"%lu", number];
        }
        else {
            NSLog(@"获取Book数目出错GuestVC类viewForSupplementaryElementOfKind, %@", error.localizedDescription);
        }
    }];
    
    //查询该用户的粉丝数目
    AVQuery* followersQuery = [AVUser followerQuery:[self.user objectId]];
    [followersQuery countObjectsInBackgroundWithBlock:^(NSInteger number, NSError * _Nullable error) {
        if (error == nil) {
            header.followers.text = [NSString stringWithFormat:@"%lu", number];
        }
        else {
            NSLog(@"获取followers数目出错GuestVC类viewForSupplementaryElementOfKind, %@", error.localizedDescription);
        }
    }];
    
    //查询该用户关注的数目
    AVQuery* followingsQuery = [AVUser followeeQuery:[self.user objectId]];
    [followingsQuery countObjectsInBackgroundWithBlock:^(NSInteger number, NSError * _Nullable error) {
        if (error == nil) {
            header.followings.text = [NSString stringWithFormat:@"%lu", number];
        }
        else {
            NSLog(@"获取followings数目出错GuestVC类viewForSupplementaryElementOfKind, %@", error.localizedDescription);
        }
    }];
    
    //给Posts添加点击事件（点击后跳到第一个Post）
    UITapGestureRecognizer* tapPosts = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postsTap:)];
    [tapPosts setNumberOfTapsRequired:1];
    [tapPosts setNumberOfTouchesRequired:1];
    [header.posts setUserInteractionEnabled:YES];
    [header.posts addGestureRecognizer:tapPosts];
    
    //给Followers添加点击事件（点击后跳到FollowersVC界面）
    UITapGestureRecognizer* tapFollowers = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followersTap:)];
    [header.followers setUserInteractionEnabled:YES];
    [tapFollowers setNumberOfTouchesRequired:1];
    [tapFollowers setNumberOfTapsRequired:1];
    [header.followers addGestureRecognizer:tapFollowers];
    
    //给Followings添加点击事情（点击后跳到FollowersVC界面）
    UITapGestureRecognizer* tapFollowings = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followingsTap:)];
    [header.followings setUserInteractionEnabled:YES];
    [tapFollowings setNumberOfTapsRequired:1];
    [tapFollowings setNumberOfTouchesRequired:1];
    [header.followings addGestureRecognizer:tapFollowings];
    
    return header;
}

//点击Posts后滑动到第一个collectionCell，也就是第一张图片的顶部。
- (void)postsTap:(UITapGestureRecognizer *)gesture {
    if ([self.picArray count] > 0) {
        NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.collectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
}

//点击Followers后跳到FollowersVC，其中要传输数据包括用户名，标题，还有AVUser信息
- (void)followersTap:(UITapGestureRecognizer *)gesture {
    FollowersVC* followersVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowersVC"];
    followersVC.name = [self.guestArray lastObject].username;
    followersVC.show = @"粉 丝";
    [self.navigationController pushViewController:followersVC animated:YES];
}

//点击Followings后跳到FollowersVC，其中要传输数据包括用户名，标题，还有AVUser信息
-(void)followingsTap:(UITapGestureRecognizer *)gesture {
    FollowersVC* followersVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowersVC"];
    followersVC.name = [self.guestArray lastObject].username;
    followersVC.show = @"关 注";
    [self.navigationController pushViewController:followersVC animated:YES];
}

//点击返回键后返回到上一层界面
- (void)back:(UIBarButtonItem*)item {
    if ([self.guestArray count] != 0) {
        [self.guestArray removeLastObject];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

//下拉刷新
- (void)refresh {
    [self.collectionView reloadData];
    [self.refresher endRefreshing];
}

//加载帖子
- (void)loadPosts {
    AVQuery* query = [AVQuery queryWithClassName:@"Book"];
    [query whereKey:@"username" equalTo:[self.guestArray lastObject].username];
    [query setLimit:self.page];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            [self.puuidArray removeAllObjects];
            [self.picArray removeAllObjects];
            for (NSDictionary* object in objects) {
                [self.puuidArray addObject:[object objectForKey:@"bookname"]];
                [self.picArray addObject:[object objectForKey:@"pic"]];
            }
            [self.collectionView reloadData];
        }
        else {
            NSLog(@"加载Book出错，GuestVC类中的loadPost方法, %@", error.localizedDescription);
        }
    }];
}


/**
 当用户滚动视图到底部时加载更多的内容

 @param scrollView 滑动窗口
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height && self.page <= [self.picArray count]) {
        [self loadMore];
    }
}

- (void)loadMore {
    if (self.page <= [self.picArray count]) {
        AVQuery* loadMorePostsQuery = [AVQuery queryWithClassName:@"Book"];
        [loadMorePostsQuery setLimit:12];
        [loadMorePostsQuery setSkip:self.page];
        [loadMorePostsQuery whereKey:@"username" equalTo:[self.guestArray lastObject]];
        [loadMorePostsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (error == nil) {
                for (id object in objects) {
                    [self.picArray addObject:[object objectForKey:@"pic"]];
                    [self.puuidArray addObject:[object objectForKey:@"bookname"]];
                }
                self.page += 12;
                [self.collectionView reloadData];
            }
            else {
                [self alert:@"提示" message:error.localizedDescription];
            }
        }];
    }
}

- (void)alert:(NSString *)title message:(NSString *)message {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark <UICollectionViewDelegate>

- (IBAction)button_clicked:(UIButton *)sender {
    if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"关 注"]) {
        [[AVUser currentUser] follow:self.user.objectId andCallback:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded && self.user != nil) {
                [sender setTitle:@"已关注" forState:UIControlStateNormal];
                [sender setBackgroundColor:[UIColor greenColor]];
                AVObject* followNews = [AVObject objectWithClassName:@"News"];
                [followNews setObject:[AVUser currentUser].username forKey:@"by"];
                [followNews setObject:self.user.username forKey:@"to"];
                [followNews setObject:[[AVUser currentUser] objectForKey:@"ava"] forKey:@"ava"];
                [followNews setObject:@" " forKey:@"detailID"];
                [followNews setObject:@"follow" forKey:@"type"];
                [followNews setObject:@"no" forKey:@"checked"];
                [followNews setObject:@" " forKey:@"owner"];
                [followNews setObject:@" " forKey:@"message"];
                [followNews saveEventually];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reload" object:nil];
            }
            else {
                NSLog(@"关注失败, %@", error.localizedDescription);
            }
        }];
    }
    else if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"已关注"]) {
        [[AVUser currentUser] unfollow:self.user.objectId andCallback:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [sender setTitle:@"关 注" forState:UIControlStateNormal];
                [sender setBackgroundColor:[UIColor lightGrayColor]];
                AVQuery* followQuery = [AVQuery queryWithClassName:@"News"];
                [followQuery whereKey:@"by" equalTo:[AVUser currentUser].username];
                [followQuery whereKey:@"to" equalTo:self.username];
                [followQuery whereKey:@"type" equalTo:@"follow"];
                [followQuery deleteAllInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                }];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reload" object:nil];
            }
            else {
                NSLog(@"取消关注失败, %@",error.localizedDescription);
            }
        }];
    }
}
@end
