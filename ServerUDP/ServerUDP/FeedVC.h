//
//  FeedVC.h
//  Instagram
//
//  Created by zcs on 2017/7/3.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVOSCloud/AVOSCloud.h>
#import "KILabel.h"
#import "PostCell.h"
#import "HomeVC.h"
#import "GuestVC.h"

@interface FeedVC : UITableViewController

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) UIRefreshControl *refreasher;

- (IBAction)usernameBtn_clicked:(UIButton *)sender;
- (IBAction)commentBtn_clicked:(UIButton *)sender;
- (IBAction)moreBtn_clicked:(UIButton *)sender;
@end
