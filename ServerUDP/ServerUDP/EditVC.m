//
//  EditVC.m
//  Instagram
//
//  Created by zcs on 2017/6/17.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import "EditVC.h"

@interface EditVC ()

@end

@implementation EditVC
{
    UIPickerView* sexPicker;
    NSArray* sex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //出现键盘时srcollView向上滑动以防被键盘阻挡，键盘消失时恢复原样，点击任意地方键盘消失
    [self keyBoard];
    
    //初始化性别选取器
    [self initSexPicker];
    
    //布局页面
    [self alignment];
    
    //点击头像的时候可以到相册选取照片
    [self selectAvaImg];
    
    //加载用户信息
    [self information];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//加载用户信息
- (void)information {
    
    //加载头像
    AVFile* avaFile = [[AVUser currentUser] objectForKey:@"ava"];
    [avaFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error == nil) {
            self.avaImg.image = [UIImage imageWithData:data];
        }
        else {
            NSLog(@"EditVC-information,加载头像错误, %@", error.localizedDescription);
        }
    }];
    
    //加载用户名，姓名，简介，邮箱
    self.usernameTxt.text = [AVUser currentUser].username;
    self.fullnameTxt.text = [[AVUser currentUser] objectForKey:@"fullname"];
    self.bioTxt.text = [[AVUser currentUser] objectForKey:@"bio"];
    self.websiteTxt.text = [[AVUser currentUser] objectForKey:@"web"];
    
    //加载私人信息（电子邮件、移动电话、性别)
    self.emailTxt.text = [AVUser currentUser].email;
    self.phoneTxt.text = [AVUser currentUser].mobilePhoneNumber;
    self.sexTxt.text = [[AVUser currentUser] objectForKey:@"gender"];
}

//弹窗警告
- (void)alert:(NSString *)error content:(NSString *)message {
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:error message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

//验证手机号码是否合理
- (BOOL)validPhone:(NSString *)phone {
    NSString* regex = @"[0]?(13|14|15|18)[0-9]{9}";
    NSRange range = [phone rangeOfString:regex options:NSRegularExpressionSearch];
    if (range.length == 0) {
        return NO;
    }
    else {
        return YES;
    }
}

//验证web地址是否合理
- (BOOL)validEmail:(NSString *)email {
    NSString* regex = @"[a-zA-Z0-9_-]+@[a-zA-Z0-0_-]+(\\.[a-zA-Z0-9_-])*";
    NSRange range = [email rangeOfString:regex options:NSRegularExpressionSearch];
    if (range.length == 0) {
        return NO;
    }
    else {
        return YES;
    }
}

//验证邮箱地址是否合理
- (BOOL)validWeb:(NSString *)web {
    NSString* regex = @"www\\.[a-zA-Z0-9_+%.]+\\.[A-Za-z]{2,14}";
    NSRange range = [web rangeOfString:regex options:NSRegularExpressionSearch];
    if (range.length == 0) {
        return NO;
    }
    else {
        return YES;
    }
}

//给头像加入点击行为，点击头像时进入avaTap方法
- (void)selectAvaImg {
    UITapGestureRecognizer* tapAva = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avaTap:)];
    [tapAva setNumberOfTapsRequired:1];
    [tapAva setNumberOfTouchesRequired:1];
    [self.avaImg setUserInteractionEnabled:YES];
    [self.avaImg addGestureRecognizer:tapAva];
}

//当点击了图片之后，进入相册选择相片
- (void)avaTap:(UITapGestureRecognizer *)gesture {
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

//UIImagePickerControllerDelegate 当在相册选好照片之后，将头像换成用户选择的照片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.avaImg.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}

//UIImagePickerControllerDelegate 当用户取消了选择照片之后，返回上一层
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//出现键盘时srcollView向上滑动以防被键盘阻挡，键盘消失时恢复原样，点击任意地方键盘消失
- (void)keyBoard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyBoard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyBoard:) name:UIKeyboardWillHideNotification object:nil];
    UITapGestureRecognizer* hideTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoardTap:)];
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:hideTap];
}

- (void)hideKeyBoardTap:(UITapGestureRecognizer *)recognizer {
    [self.view endEditing:YES];
}

//当点击键盘的时候，将滚动视图的内容的高度设置为控制视图的高度加上键盘高度的一半
- (void)showKeyBoard:(NSNotification *)notification {
    CGRect keyBoardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval timeInterval;
    [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&timeInterval];
    [UIView animateWithDuration:timeInterval animations:^{
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.scrollView.frame.size.height + keyBoardRect.size.height / 2);
    }];
}

//当键盘收起的时候，将滚动视图的内容的高度设置为0，这样滚动视图可以根据内容的高度来设置高度
- (void)hideKeyBoard:(NSNotification *)notification {
    NSTimeInterval timeInterval;
    [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&timeInterval];
    [UIView animateWithDuration:timeInterval animations:^{
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 0);
    }];
}

//初始化性别选取器
- (void)initSexPicker {
    
    //设置性别的选项,初始化sexPicker
    sex = [NSArray arrayWithObjects:@"男", @"女", nil];
    sexPicker = [[UIPickerView alloc] init];
    
    //设置选择器的代理
    sexPicker.delegate = self;
    sexPicker.dataSource = self;
    
    //设置选择器的背景颜色，并显示选择指示器
    sexPicker.backgroundColor = [UIColor groupTableViewBackgroundColor];
    sexPicker.showsSelectionIndicator = YES;
    
    //设置sexTxt选项的输入视图为sexPicker
    self.sexTxt.inputView = sexPicker;
}

//布局页面
-(void)alignment {
    
    //获取屏幕的高度和宽度
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    //设置滚动窗口的大小刚好是整个屏幕的大小
    self.scrollView.frame = CGRectMake(0, 0, width, height);
    
    //设置头像的位置和大小，并把它设置为圆形
    self.avaImg.frame = CGRectMake(width - 68 - 10, 15, 68, 68);
    self.avaImg.layer.cornerRadius = self.avaImg.frame.size.width / 2;
    [self.avaImg.layer setMasksToBounds:YES];
    
    //设置姓名、用户名、网站的位置
    self.fullnameTxt.frame = CGRectMake(10, self.avaImg.frame.origin.y, width - self.avaImg.frame.size.width - 30, 30);  //末尾与头像隔了20个像素
    self.usernameTxt.frame = CGRectMake(10, self.fullnameTxt.frame.origin.y + 40, width - self.avaImg.frame.size.width - 30, 30); //末尾与头像隔了20个像素
    self.websiteTxt.frame = CGRectMake(10, self.usernameTxt.frame.origin.y + 40, width - 20, 30);
    
    //设置简介的位置
    self.bioTxt.frame = CGRectMake(10, self.websiteTxt.frame.origin.y + 40, width - 20, 60);
    self.bioTxt.layer.borderWidth = 1;
    self.bioTxt.layer.borderColor = [[UIColor colorWithRed:230 / 255 green:230 / 255 blue:230 / 255 alpha:1] CGColor];
    self.bioTxt.layer.cornerRadius = self.bioTxt.frame.size.width / 50;
    self.bioTxt.layer.masksToBounds = YES;
    
    //设置私人信息标题的位置
    self.titleLbl.frame = CGRectMake(10, self.bioTxt.frame.origin.y + 100, width - 20, 30);
    
    //设置电子邮件、移动电话和性别的位置
    self.emailTxt.frame = CGRectMake(10, self.titleLbl.frame.origin.y + 40, width - 20, 30);
    self.phoneTxt.frame = CGRectMake(10, self.emailTxt.frame.origin.y + 40, width - 20, 30);
    self.sexTxt.frame = CGRectMake(10, self.phoneTxt.frame.origin.y + 40, width - 20, 30);
    
}

//UIPickerViewDataSource, 配置有多少个Components和多少个items
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [sex count];
}

//UIPickerViewDelegate，配置每一列Component的内容，相当于每一列的选项
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return sex[row];
}

//UIPickerViewDelegate,配置用户点击后产生的效果
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString* selectedSex = sex[row];
    self.sexTxt.text = selectedSex;
    [self.view endEditing:YES];
}

//点击取消按钮
- (IBAction)cancel_clicked:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//点击保存按钮
- (IBAction)save_clicked:(UIBarButtonItem *)sender {
    
    //检测内容是否为空，当内容为空时弹出警告，否则上传内容
    if (![self validEmail:self.emailTxt.text]) {
        [self alert:@"警告" content:@"请填入正确的Email信息"];
    }
    else if (![self validWeb:self.websiteTxt.text]) {
        [self alert:@"警告" content:@"请填入正确的web信息"];
    }
    else if (![self validPhone:self.phoneTxt.text]) {
        [self alert:@"警告" content:@"请填入正确的Phone信息"];
    }
    else if ([self.usernameTxt.text length] == 0) {
        [self alert:@"警告" content:@"请填入username"];
    }
    else if ([self.fullnameTxt.text length] == 0) {
        [self alert:@"警告" content:@"请填入fullname"];
    }
    else if ([self.bioTxt.text length] == 0) {
        [self alert:@"警告" content:@"请填入bioText"];
    }
    else if ([self.sexTxt.text length] == 0) {
        [self alert:@"警告" content:@"请填入sex"];
    }
    else {
        [AVUser currentUser].username = self.usernameTxt.text.lowercaseString;
        [AVUser currentUser].email = self.emailTxt.text;
        [AVUser currentUser].mobilePhoneNumber = self.phoneTxt.text;
        [[AVUser currentUser] setObject:self.fullnameTxt.text forKey:@"fullname"];
        [[AVUser currentUser] setObject:self.websiteTxt.text forKey:@"web"];
        [[AVUser currentUser] setObject:self.bioTxt.text forKey:@"bio"];
        [[AVUser currentUser] setObject:self.sexTxt.text forKey:@"gender"];
        [[AVUser currentUser] setObject:UIImageJPEGRepresentation(self.avaImg.image, 0.5)  forKey:@"ava"];
        [[AVUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [self.view endEditing:YES];
                NSNotification *notice = [NSNotification notificationWithName:@"reload" object:nil];
                [[NSNotificationCenter defaultCenter] postNotification:notice];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else {
                [self alert:@"警告" content:error.localizedDescription];
            }
        }];
    }
}
@end
