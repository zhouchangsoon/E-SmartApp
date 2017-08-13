//
//  FollowersVC.h
//  Instagram
//
//  Created by zcs on 2017/6/12.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVOSCloud/AVOSCloud.h>
#import "FollowersCell.h"
#import "GuestVC.h"
#import "HomeVC.h"

@interface FollowersVC : UITableViewController

@property (strong, nonatomic) NSString* userID;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* show;
@property (strong, nonatomic) NSMutableArray<AVUser *>* followersArray;

@end
