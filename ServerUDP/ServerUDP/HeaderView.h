//
//  HeaderView.h
//  Instagram
//
//  Created by zcs on 2017/6/1.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderView : UICollectionReusableView
@property (strong, nonatomic) IBOutlet UIImageView *avaImg;
@property (strong, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (strong, nonatomic) IBOutlet UITextView *webTxt;
@property (strong, nonatomic) IBOutlet UILabel *bioTxt;
@property (strong, nonatomic) IBOutlet UILabel *posts;
@property (strong, nonatomic) IBOutlet UILabel *followers;
@property (strong, nonatomic) IBOutlet UILabel *followings;
@property (strong, nonatomic) IBOutlet UILabel *postLabel;
@property (strong, nonatomic) IBOutlet UILabel *followerLabel;
@property (strong, nonatomic) IBOutlet UILabel *followingLabel;
@property (strong, nonatomic) IBOutlet UIButton *button;

- (void)initFrame;

@end
