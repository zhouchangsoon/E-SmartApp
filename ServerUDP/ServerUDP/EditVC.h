//
//  EditVC.h
//  Instagram
//
//  Created by zcs on 2017/6/17.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVOSCloud/AVOSCloud.h>

@interface EditVC : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

//滚动窗口
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

//取消按钮、保存按钮
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *savaBtn;

//取消动作、保存动作
- (IBAction)cancel_clicked:(UIBarButtonItem *)sender;
- (IBAction)save_clicked:(UIBarButtonItem *)sender;

//头像
@property (strong, nonatomic) IBOutlet UIImageView *avaImg;

//姓名、用户名、网站、个人简介
@property (strong, nonatomic) IBOutlet UITextField *fullnameTxt;
@property (strong, nonatomic) IBOutlet UITextField *usernameTxt;
@property (strong, nonatomic) IBOutlet UITextField *websiteTxt;
@property (strong, nonatomic) IBOutlet UITextView *bioTxt;

//私人信息title
@property (strong, nonatomic) IBOutlet UILabel *titleLbl;

//电子邮件、移动电话、性别
@property (strong, nonatomic) IBOutlet UITextField *emailTxt;
@property (strong, nonatomic) IBOutlet UITextField *phoneTxt;
@property (strong, nonatomic) IBOutlet UITextField *sexTxt;


@end
