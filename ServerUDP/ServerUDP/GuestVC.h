//
//  GuestVC.h
//  Instagram
//
//  Created by zcs on 2017/6/13.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVOSCloud/AVOSCloud.h>
#import "PictureCell.h"
#import "HeaderView.h"
#import "FollowersVC.h"
#import "PostVC.h"



@interface GuestVC : UICollectionViewController <UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) AVUser* user;
@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSMutableArray<AVUser*>* guestArray;
@property (strong, nonatomic) NSMutableArray<NSString*>* puuidArray;
@property (strong, nonatomic) NSMutableArray<AVFile*>* picArray;
@property (strong, nonatomic) UIRefreshControl* refresher;
@property (assign, nonatomic) int page;
- (IBAction)button_clicked:(UIButton *)sender;

@end
