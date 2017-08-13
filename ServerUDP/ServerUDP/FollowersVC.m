//
//  FollowersVC.m
//  Instagram
//
//  Created by zcs on 2017/6/12.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import "FollowersVC.h"

@interface FollowersVC ()

@end

@implementation FollowersVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.show;
    if ([self.show isEqualToString:@"粉 丝"]) {
        [self loadFollowers];
    }
    else {
        [self loadFollowees];
    }
    [self.navigationItem hidesBackButton];
    UIBarButtonItem* backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
//    向右滑动返回
    UISwipeGestureRecognizer* swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(back)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipe];
//    去除多余的分割线
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back {
    if ([self.followersArray count] > 0) {
        [self.followersArray removeLastObject];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.followersArray count];
}

//加载粉丝数据
- (void)loadFollowers {
    [[AVUser currentUser] getFollowers:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            self.followersArray = [NSMutableArray arrayWithArray:objects];
            [self.tableView reloadData];
        }
        else {
            NSLog(@"加载Followers时发生错误: %@", error.localizedDescription);
        }
    }];
}

//加载我们关注的人数据
- (void)loadFollowees {
    [[AVUser currentUser] getFollowees:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            self.followersArray = [NSMutableArray arrayWithArray:objects];
            [self.tableView reloadData];
        }
        else {
            NSLog(@"加载Followees时发生错误: %@", error.localizedDescription);
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FollowersCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.usernameLbl.text = self.followersArray[indexPath.row].username;
    cell.user = self.followersArray[indexPath.row];
    if ([cell.usernameLbl.text isEqualToString:[AVUser currentUser].username]) {
        cell.followBtn.hidden = YES;
    }
    AVFile* avaFile = [self.followersArray[indexPath.row] objectForKey:@"ava"];
    [avaFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error == nil) {
            cell.avaImg.image = [UIImage imageWithData:data];
        }
        else {
            NSLog(@"加载图片出错，%@", error.localizedDescription);
        }
    }];
    AVQuery* query = [[self.followersArray objectAtIndex:indexPath.row] followeeQuery];
    [query whereKey:@"user" equalTo:[AVUser currentUser]];
    [query whereKey:@"followee" equalTo:[self.followersArray objectAtIndex:indexPath.row]];
    [query countObjectsInBackgroundWithBlock:^(NSInteger number, NSError * _Nullable error) {
        if (error == nil) {
            if (number == 0) {
                [cell.followBtn setTitle:@"关 注" forState:UIControlStateNormal];
                [cell.followBtn setBackgroundColor:[UIColor lightGrayColor]];
            }
            else {
                [cell.followBtn setTitle:@"已关注" forState:UIControlStateNormal];
                [cell.followBtn setBackgroundColor:[UIColor greenColor]];
            }
        }
        else  {
            NSLog(@"查询用户之间的关系出错 FollowersCV cellForRowAtIndexPath,%@", error.localizedDescription);
        }
    }];
    return cell;
}

//用户选择了其中一个TableCell后跳转到GuestVC界面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //获取用户点击的单元格
    FollowersCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.usernameLbl.text isEqualToString:[AVUser currentUser].username]) {
        HomeVC* home = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
        [self.navigationController pushViewController:home animated:YES];
    }
    else {
        GuestVC* guestVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GuestVC"];
        guestVC.username = [self.followersArray objectAtIndex:indexPath.row].username;
        [guestVC.guestArray addObject:[self.followersArray objectAtIndex:indexPath.row]];
        guestVC.user = [self.followersArray objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:guestVC animated:YES];
    }
}

//设置表格中单元格的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size.width / 4;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
