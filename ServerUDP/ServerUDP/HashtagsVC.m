//
//  HashtagsVC.m
//  Instagram
//
//  Created by zcs on 2017/6/30.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import "HashtagsVC.h"

@interface HashtagsVC ()

@end

@implementation HashtagsVC
{
    NSMutableArray<NSString *>* puuidArray;
    NSMutableArray<NSString *>*  filterArray;
    NSMutableArray<AVFile *>* picArray;
}



- (void)viewDidLoad {
    [super viewDidLoad];
//    初始化信息
    [self initData];
//    加载刷新器
    [self loadRefresher];
//    向右滑动返回上一级
    [self swipeBack];
//    垂直方向可以伸缩
    [self.collectionView setAlwaysBounceVertical:YES];
//    当下拉到底时加载更多的数据
    if (self.collectionView.contentOffset.y >= self.collectionView.contentSize.height - self.collectionView.frame.size.height) {
        [self loadMore];
    }
//    加载数据
    [self loadData];
//    设置代理
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
//    设置导航栏的标题
    self.navigationItem.title = [NSString stringWithFormat:@"#%@", self.hashtag];
//    重新设置返回按钮
    [self.navigationItem hidesBackButton];
    UIBarButtonItem* backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back:(UIBarButtonItem *)item {
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 滑动返回
 */
- (void)swipeBack {
    UISwipeGestureRecognizer* gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(back)];
    [gesture setNumberOfTouchesRequired:1];
    [gesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.collectionView addGestureRecognizer:gesture];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 加载数据
 */
- (void)loadData {
    AVQuery* query = [AVQuery queryWithClassName:@"Hashtags"];
    [query whereKey:@"hashtag" equalTo:[self.hashtagArray lastObject]];
    [query setLimit:self.pages];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil && [objects count] > 0) {
            [filterArray removeAllObjects];
            for (AVObject* object in objects) {
                [filterArray addObject:[object objectForKey:@"to"]];
            }
            AVQuery* picQuery = [AVQuery queryWithClassName:@"Posts"];
            [picQuery whereKey:@"puuid" containedIn:filterArray];
            [picQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if (error == nil && [objects count] > 0) {
                    [picArray removeAllObjects];
                    [puuidArray removeAllObjects];
                    for (AVObject* object in objects) {
                        [picArray addObject:[object objectForKey:@"pic"]];
                        [puuidArray addObject:[object objectForKey:@"puuid"]];
                    }
                    [self.collectionView reloadData];
                    [self.refresh endRefreshing];
                }
                else {
                    [self alert:@"Alert" message:error.localizedDescription];
                }
            }];
        }
        else {
            [self alert:@"Alert" message:error.localizedDescription];
        }
    }];
}


/**
 加载更多的数据
 */
- (void)loadMore {
    if (self.pages <= [filterArray count]) {
        self.pages += 12;
        AVQuery* hashtagQuery = [AVQuery queryWithClassName:@"Hashtags"];
        [hashtagQuery whereKey:@"hashtag" equalTo:[self.hashtagArray lastObject]];
        [hashtagQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (error == nil && [objects count] > 0) {
                [filterArray removeAllObjects];
                for (AVObject* object in objects) {
                    [filterArray addObject:[object objectForKey:@"to"]];
                }
                AVQuery* postQuery = [AVQuery queryWithClassName:@"Posts"];
                [postQuery whereKey:@"puuid" containedIn:filterArray];
                [postQuery setLimit:self.pages];
                [postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                    if (error == nil && [objects count] > 0) {
                        [picArray removeAllObjects];
                        [puuidArray removeAllObjects];
                        for (AVObject* object in objects) {
                            [picArray addObject:[object objectForKey:@"pic"]];
                            [puuidArray addObject:[object objectForKey:@"puuid"]];
                        }
                    }
                    [self.collectionView reloadData];
                }];
            }
        }];
    }
}


/**
 显示警告信息

 @param title 标题
 @param message 信息
 */
- (void)alert:(NSString *)title message:(NSString *)message {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

/**
 加载刷新器
 */
- (void)loadRefresher {
    self.refresh = [[UIRefreshControl alloc] init];
    [self.refresh addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refresh];
}


/**
 初始化信息
 */
- (void)initData {
    self.hashtagArray = [[NSMutableArray alloc] init];
    [self.hashtagArray addObject:self.hashtag];
    filterArray = [[NSMutableArray alloc] init];
    picArray = [[NSMutableArray alloc] init];
    puuidArray = [[NSMutableArray alloc] init];
    self.pages = 12;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [picArray count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.frame.size.width / 3.0 - 4, self.view.frame.size.width / 3.0 - 4);
}


/**
 设置每一个cell的内容

 @param collectionView collectionView
 @param indexPath indexPath
 @return return PictureCell
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PictureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [cell initFrame];
    AVFile* picFile = [picArray objectAtIndex:indexPath.row];
    [picFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error == nil) {
            cell.picImg.image = [UIImage imageWithData:data];
        }
        else {
            [self alert:@"Alert" message:error.localizedDescription];
        }
    }];
    return cell;
}



/**
 当用户点击cell时跳转到对应的PostVC，显示相应的图片

 @param collectionView collectionView
 @param indexPath indexPath
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PostVC* postVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PostVC"];
    postVC.post = [puuidArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:postVC animated:YES];
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


/**
 设置上下左右内边距,其中上边距为10pt，其它都为0

 @param collectionView collectionView
 @param collectionViewLayout collectionViewLayout
 @param section section
 @return return value
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 0, 0, 0);
}


@end
