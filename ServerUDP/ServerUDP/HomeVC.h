//
//  HomeVC.h
//  Instagram
//
//  Created by zcs on 2017/6/1.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVOSCloud/AVOSCloud.h>
#import "PictureCell.h"
#import "HeaderView.h"
#include "FollowersVC.h"
#import "AppDelegate.h"
#import "SignInVC.h"
#import "PostVC.h"
@interface HomeVC : UICollectionViewController<UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIRefreshControl* refresher;
@property (nonatomic, assign) int page;
@property (nonatomic, strong) NSMutableArray* bookID;
@property (nonatomic, strong) NSMutableArray* picArray;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *logout;
- (IBAction)logout:(UIBarButtonItem *)sender;

@end
