//
//  SignInVC.m
//  Instagram
//
//  Created by zcs on 2017/5/29.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import "SignInVC.h"

@interface SignInVC ()
@property (strong, nonatomic) IBOutlet UITextField *usernameTxt;
@property (strong, nonatomic) IBOutlet UITextField *passwordTxt;
@property (strong, nonatomic) IBOutlet UIButton *signInBtn;
@property (strong, nonatomic) IBOutlet UIButton *signOutBtn;
@property (strong, nonatomic) IBOutlet UIButton *forgotBtn;
@property (strong, nonatomic) IBOutlet UILabel *label;

- (IBAction)signInBtn_clicked:(UIButton *)sender;
- (IBAction)signOutBtn_clicked:(UIButton *)sender;
- (IBAction)forgotBtn_clicked:(UIButton *)sender;
@end

@implementation SignInVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.label.font = [UIFont fontWithName:@"Pacifico" size:25];
    UIImageView* bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.jpg"]];
    bgView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    bgView.layer.zPosition = -1;
    [self.view addSubview:bgView];
    UITapGestureRecognizer* hideTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    hideTap.numberOfTapsRequired = 1;
    hideTap.numberOfTouchesRequired = 1;
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:hideTap];
    self.label.frame = CGRectMake(10, 80, self.view.frame.size.width - 20, 50);
    self.usernameTxt.frame = CGRectMake(10, self.label.frame.origin.y + 70, self.view.frame.size.width - 20, 30);
    self.passwordTxt.frame = CGRectMake(10, self.usernameTxt.frame.origin.y + 40, self.view.frame.size.width - 20, 30);
    self.forgotBtn.frame = CGRectMake(10, self.passwordTxt.frame.origin.y + 30, self.view.frame.size.width - 20, 30);
    self.signInBtn.frame = CGRectMake(20, self.forgotBtn.frame.origin.y + 40, self.view.frame.size.width / 4, 30);
    self.signOutBtn.frame = CGRectMake(self.view.frame.size.width - self.signInBtn.frame.size.width - 20, self.signInBtn.frame.origin.y, self.view.frame.size.width / 4, 30);
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

- (IBAction)signInBtn_clicked:(UIButton *)sender {
    [self.view endEditing:YES];
    if (!self.usernameTxt.hasText || !self.passwordTxt.hasText) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"注意" message:@"前填入完整信息" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else{
        [AVUser logInWithUsernameInBackground:self.usernameTxt.text password:self.passwordTxt.text block:^(AVUser * _Nullable user, NSError * _Nullable error) {
            if (error == nil) {
                [[NSUserDefaults standardUserDefaults] setObject:user.username forKey:@"username"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                AppDelegate* app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [app login];
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (IBAction)signOutBtn_clicked:(UIButton *)sender {
    [self.view endEditing:YES];
}

- (IBAction)forgotBtn_clicked:(UIButton *)sender {
    [self.view endEditing:YES];
}

- (void)hideKeyboard:(UITapGestureRecognizer *)recognizer {
    [self.view endEditing:YES];
}
@end
