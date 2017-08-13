//
//  SignUp.m
//  Instagram
//
//  Created by zcs on 2017/5/29.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import "SignUp.h"

@interface SignUp ()
@property (strong, nonatomic) IBOutlet UIImageView *avaImg;

@property (strong, nonatomic) IBOutlet UITextField *usernameTxt;
@property (strong, nonatomic) IBOutlet UITextField *passwordTxt;
@property (strong, nonatomic) IBOutlet UITextField *repeatPasswordTxt;
@property (strong, nonatomic) IBOutlet UITextField *emailTxt;
@property (strong, nonatomic) IBOutlet UITextField *nameTxt;
@property (strong, nonatomic) IBOutlet UITextField *bioTxt;
@property (strong, nonatomic) IBOutlet UITextField *webTxt;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (assign, nonatomic) CGFloat scrollViewHeight;
@property (assign, nonatomic) CGRect keyboard;

@property (strong, nonatomic) IBOutlet UIButton *signBtn;
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;

- (IBAction)signBtn_clicked:(UIButton *)sender;
- (IBAction)cancelBtn_clicked:(UIButton *)sender;
@end

@implementation SignUp

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView* bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.jpg"]];
    bgView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    bgView.layer.zPosition = -1;
    [self.view addSubview:bgView];
    self.scrollView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.bounds.size.height);
    [self.scrollView setContentSize:self.view.bounds.size];    //限定了垂直滚动和水平滚动
    self.scrollViewHeight = self.view.bounds.size.height;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    UITapGestureRecognizer* hideTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardTap:)];
    hideTap.numberOfTapsRequired = 1;
    hideTap.numberOfTouchesRequired = 1;
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:hideTap];
    UITapGestureRecognizer* imgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadImg:)];
    [self.avaImg setUserInteractionEnabled:YES];
    [self.avaImg addGestureRecognizer:imgTap];
    self.avaImg.layer.cornerRadius = self.avaImg.frame.size.width / 2;
    self.avaImg.layer.masksToBounds = YES;
    self.avaImg.frame = CGRectMake(self.view.frame.size.width / 2 - 40, 40, 80, 80);
    self.usernameTxt.frame = CGRectMake(10, self.avaImg.frame.origin.y + 90, self.view.frame.size.width - 20, 30);
    self.passwordTxt.frame = CGRectMake(10, self.usernameTxt.frame.origin.y + 40, self.view.frame.size.width - 20, 30);
    self.repeatPasswordTxt.frame = CGRectMake(10, self.passwordTxt.frame.origin.y + 40, self.view.frame.size.width - 20, 30);
    self.emailTxt.frame = CGRectMake(10, self.repeatPasswordTxt.frame.origin.y + 40, self.view.frame.size.width - 20, 30);
    self.nameTxt.frame = CGRectMake(10, self.emailTxt.frame.origin.y + 40, self.view.frame.size.width - 20, 30);
    self.bioTxt.frame = CGRectMake(10, self.nameTxt.frame.origin.y + 40, self.view.frame.size.width - 20, 30);
    self.webTxt.frame = CGRectMake(10, self.bioTxt.frame.origin.y + 40, self.view.frame.size.width - 20, 30);
    self.signBtn.frame = CGRectMake(20, self.webTxt.frame.origin.y + 50, self.view.frame.size.width / 4, 30);
    self.cancelBtn.frame = CGRectMake(self.view.frame.size.width - 20 - self.signBtn.frame.size.width, self.signBtn.frame.origin.y, self.view.frame.size.width / 4, 30);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)signBtn_clicked:(UIButton *)sender {
    [self.view endEditing:YES];
    if (!self.usernameTxt.hasText || !self.passwordTxt.hasText || !self.repeatPasswordTxt.hasText || !self.emailTxt.hasText || !self.nameTxt.hasText || !self.bioTxt.hasText || !self.webTxt.hasText) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"请注意" message:@"请填写完所有选项" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if (self.passwordTxt.text != self.repeatPasswordTxt.text) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"请注意" message:@"两次密码不一致" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        AVUser *user = [[AVUser alloc] init];
        user.username = self.usernameTxt.text;
        user.password = self.passwordTxt.text;
        user.email = self.emailTxt.text;
        [user setObject:self.nameTxt.text forKey:@"fullname"];
        [user setObject:self.bioTxt.text forKey:@"bio"];
        [user setObject:self.webTxt.text forKey:@"web"];
        [user setObject:@"" forKey:@"gender"];
        NSData* avaData = UIImageJPEGRepresentation(self.avaImg.image, 0.5);
        AVFile* avaFile = [AVFile fileWithName:@"ava.jpg" data:avaData];
        [user setObject:avaFile forKey:@"ava"];
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                NSLog(@"用户注册成功");
                [AVUser logInWithUsernameInBackground:user.username password:user.password block:^(AVUser * _Nullable user, NSError * _Nullable error) {
                    if (error == nil) {
                        if (user != nil) {
                            [[NSUserDefaults standardUserDefaults] setObject:user.username forKey:@"username"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                            [delegate login];
                        }
                        else {
                            NSLog(@"用户名为空");
                        }
                    }
                    else {
                        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                        [alert addAction:action];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                }];
                
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (IBAction)cancelBtn_clicked:(UIButton *)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showKeyboard:(NSNotification *)notification {
    self.keyboard = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect rect = self.scrollView.frame;
    rect.size.height = self.scrollViewHeight - self.keyboard.size.height;
    [UIView animateWithDuration:0.4 animations:^{
        self.scrollView.frame = rect;
    }];
}

- (void)hidKeyboard:(NSNotification *)notification {
    CGRect rect = self.scrollView.frame;
    rect.size.height = self.view.frame.size.height;
    [UIView animateWithDuration:0.4 animations:^{
        self.scrollView.frame = rect;
    }];
}

- (void)hideKeyboardTap:(UITapGestureRecognizer*)recognizer {
    [self.view endEditing:YES];
}

- (void)loadImg:(UITapGestureRecognizer *)recognizer {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [picker setAllowsEditing:YES];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    self.avaImg.image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
