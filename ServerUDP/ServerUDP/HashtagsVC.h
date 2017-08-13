//
//  HashtagsVC.h
//  Instagram
//
//  Created by zcs on 2017/6/30.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureCell.h"
#import <AVOSCloud/AVOSCloud.h>
#import "PostVC.h"

@interface HashtagsVC : UICollectionViewController<UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSString* hashtag;
@property (nonatomic, strong) NSMutableArray<NSString *>* hashtagArray;
@property (nonatomic, strong) UIRefreshControl* refresh;
@property (assign, nonatomic) int pages;


@end
