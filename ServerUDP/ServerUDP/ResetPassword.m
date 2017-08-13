//
//  ResetPassword.m
//  Instagram
//
//  Created by zcs on 2017/5/29.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import "ResetPassword.h"

@interface ResetPassword ()
@property (strong, nonatomic) IBOutlet UITextField *emailTxt;
@property (strong, nonatomic) IBOutlet UIButton *resetBtn;
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;

- (IBAction)resetBtn_clicked:(UIButton *)sender;
- (IBAction)cancelBtn_clicked:(UIButton *)sender;
@end

@implementation ResetPassword

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView* bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.jpg"]];
    bgView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    bgView.layer.zPosition = -1;
    [self.view addSubview:bgView];
    UITapGestureRecognizer* hideTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    hideTap.numberOfTouchesRequired = 1;
    hideTap.numberOfTapsRequired = 1;
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:hideTap];
    self.emailTxt.frame = CGRectMake(10, 120, self.view.frame.size.width - 20, 30);
    self.resetBtn.frame = CGRectMake(20, self.emailTxt.frame.origin.y + 50, self.view.frame.size.width / 4, 30);
    self.cancelBtn.frame = CGRectMake(self.view.frame.size.width / 4 * 3 - 20, self.resetBtn.frame.origin.y, self.view.frame.size.width / 4, 30);
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

- (IBAction)resetBtn_clicked:(UIButton *)sender {
    [self.view endEditing:YES];
    if (self.emailTxt.text != nil) {
        [AVUser requestPasswordResetForEmailInBackground:self.emailTxt.text block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"请注意" message:@"重置密码的连接已经发送到你的邮箱" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            } else {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"请注意" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    }
    else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"请注意" message:@"电子邮件不能为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)cancelBtn_clicked:(UIButton *)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)hideKeyboard:(UITapGestureRecognizer *)recognizer {
    [self.view endEditing:YES];
}
@end
