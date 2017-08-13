//
//  ViewController.m
//  ServerUDP
//
//  Created by zcs on 2017/1/20.
//  Copyright © 2017年 ZCS-Company. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *alert;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, assign) int flag;
@end

@implementation ViewController
{
    GCDAsyncSocket* socket;
    GCDAsyncSocket* clientSocket;
    NSThread* currentThread;
    SystemSoundID soundId;
    NSMutableArray<NSString *> *strArray;
    UITapGestureRecognizer* tapGesture;
    CGRect keyboardFrame;
    CGFloat textViewY;
    CGFloat textViewH;
    YDTranslateRequest *translateRequest;
    YDTranslateInstance* yd;
    BOOL touch;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    strArray = [[NSMutableArray alloc] init];
    [self.textView setHidden:YES];
    [self.textView setFont:[UIFont systemFontOfSize:16]];
    [self.textView setBackgroundColor:[UIColor colorWithRed:104 / 255 green:104 / 255 blue:104 / 255 alpha:0.7]];
    [self.textView setTextColor:[UIColor colorWithRed:255 / 255 green:255 / 255 blue:255 / 255 alpha:1]];
    [self.textView setFrame:CGRectMake(0, self.view.frame.size.height - 15, self.view.frame.size.width, 30)];
    textViewY = self.textView.frame.origin.y;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideTextView)];
    [self.view addGestureRecognizer:tapGesture];
//    监听键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//    设置背景
    UIImageView* backgroundView = [[UIImageView alloc] initWithFrame:self.view.frame];
    backgroundView.image = [UIImage imageNamed:@"Cover.jpg"];
    [self.view addSubview:backgroundView];
    [self.view sendSubviewToBack:backgroundView];
//    [self.alert addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionOld context:nil];
//    设置Title
    [self.navigationItem setTitle:[AVUser currentUser].username];
//    为用户选择文字时添加选项
    [self addMenu];
//    为用户点击完成时回到菜单
    UIToolbar* toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    UIButton* barButton = [UIButton buttonWithType:UIButtonTypeSystem];
    barButton.frame = CGRectMake(self.view.frame.size.width - 60, 0, 50, 30);
    [barButton setTitle:@"Finish" forState:UIControlStateNormal];
    [barButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [barButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [barButton addTarget:self action:@selector(hideTextView) forControlEvents:UIControlEventTouchUpInside];
    toolBar.backgroundColor = [UIColor darkGrayColor];
    [toolBar addSubview:barButton];
    self.textView.inputAccessoryView = toolBar;
//    注册翻译ID
    yd = [YDTranslateInstance sharedInstance];
    yd.appKey = @"5074221c54f3f8fb";
//    设置初始值
    touch = false;
    [self start];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    id oldName = [change objectForKey:NSKeyValueChangeOldKey];
    NSLog(@"oldName----------%@",oldName);
    id newName = [change objectForKey:NSKeyValueChangeNewKey];
    NSLog(@"newName-----------%@",newName);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)textViewDidBeginEditing:(UITextView *)textView {
//    touch = true;
//}

- (void)addMenu {
    UIMenuItem* itemOne = [[UIMenuItem alloc] initWithTitle:@"translate" action:@selector(translate)];
    UIMenuItem *itemTwo = [[UIMenuItem alloc] initWithTitle:@"save" action:@selector(save)];
    [UIMenuController sharedMenuController].menuItems = @[itemOne, itemTwo];
}

- (void)save {
    UploadVC* upload = [self.storyboard instantiateViewControllerWithIdentifier:@"Upload"];
    upload.text = [self.textView.text substringWithRange:self.textView.selectedRange];
    [self.navigationController pushViewController:upload animated:YES];
}

- (void)translate {
//    初始化翻译工具
    translateRequest = [YDTranslateRequest request];
    YDTranslateParameters *parameters = [YDTranslateParameters targeting];
    parameters.source = @"youdaosw";
    parameters.from = @"英文";
    parameters.to = @"中文";
    translateRequest.translateParameters = parameters;
    [translateRequest lookup:[self.textView.text substringWithRange:self.textView.selectedRange] WithCompletionHandler:^(YDTranslateRequest *request, YDTranslate *translte, NSError *error) {
        if (error) {
            NSString *des = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
            [self alert:@"Alert" message:des];
        }
        else {
            NSString *fanyi = translte.translation[0];
            if(fanyi == nil){
                [self alert:@"Alert" message:@"抱歉，遇到错误，请重新输入"];
            }
            else {
                UploadVC* upload = [self.storyboard instantiateViewControllerWithIdentifier:@"Upload"];
                upload.translation = fanyi;
                upload.text = [self.textView.text substringWithRange:self.textView.selectedRange];
                [self.navigationController pushViewController:upload animated:YES];
            }
        }
    }];
}

- (void)hideTextView {
    [self.view endEditing:YES];
}

- (void)start {
    socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError* error = nil;
    [socket acceptOnPort:8787 error:&error];
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    if ([clientSocket isConnected]) {
        [clientSocket disconnect];
    }
    clientSocket = newSocket;
    [clientSocket readDataWithTimeout:-1 tag:0];
    NSLog(@"receive connect from %@, %hu", newSocket.connectedHost, newSocket.connectedPort);
}

- (void)showMessage {
    if ([strArray count] != 0) {
        NSString* str = strArray[0];
        for (int i = 1; i < strArray.count; ++i) {
            str = [str stringByAppendingString:strArray[i]];
        }
        self.textView.text = str;
        CGSize contentSize = CGSizeMake(self.textView.frame.size.width, 200);
        CGFloat height = ceilf([self.textView sizeThatFits:contentSize].height);
        [self.textView setFrame:CGRectMake(0, (self.view.frame.size.height - height) / 2, self.view.frame.size.width, height)];
        textViewY = self.textView.frame.origin.y;
        [self performSelector:@selector(cleanMessage) withObject:nil afterDelay:2];
    }
}

- (void)cleanMessage {
    [strArray removeAllObjects];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString* message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"信息：%@", message);
    if (message) {
        if ([message isEqualToString:@"attention"]) {
            [self.alert setHidden:NO];
            [self.alert performSelector:@selector(setHidden:) withObject:@1 afterDelay:5];
            AudioServicesPlaySystemSound(1007);
//            if (_flag == 1) {
//                AudioServicesPlaySystemSound(1007);
//            }
//            if (_flag == 2) {
//                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//            }
            
        }
        else if([message isEqualToString:@"drowsiness"]) {
            self.alert.image = [UIImage imageNamed:@"sleep.png"];
            [self.alert setHidden:NO];
            AudioServicesPlaySystemSound(1007);
//            if (_flag == 1) {
//                AudioServicesPlaySystemSound(1007);
//            }
//            if (_flag == 2) {
//                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//            }
            [self.alert performSelector:@selector(setHidden:) withObject:@YES afterDelay:5];
        }
        
        else {
            self.textView.hidden = NO;
            [strArray addObject:message];
//            [self showMessage];
        }
    }
    [clientSocket disconnect];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    textViewH = self.textView.frame.size.height;
    if (self.view.frame.size.height - keyboardFrame.size.height - self.textView.frame.size.height + self.tabBarController.tabBar.frame.size.height - 30 < 0) {
        [UIView animateWithDuration:0.4 animations:^{
            self.textView.frame = CGRectMake(self.textView.frame.origin.x, 25, self.textView.frame.size.width, self.view.frame.size.height - keyboardFrame.size.height + self.tabBarController.tabBar.frame.size.height - 23);
        }];
    }
    else {
        [UIView animateWithDuration:0.4 animations:^{
            self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.view.frame.size.height - keyboardFrame.size.height - self.textView.frame.size.height + self.tabBarController.tabBar.frame.size.height, self.textView.frame.size.width, self.textView.frame.size.height);
        }];
    }
}


- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    [self showMessage];
    if (err) {
        NSLog(@"出错啦: %@", err.localizedDescription);
    }
}

//当键盘消失的时候输入框下移
- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.4 animations:^{
        self.textView.frame = CGRectMake(self.textView.frame.origin.x, textViewY, self.textView.frame.size.width, textViewH);
    }];
}

- (void)alert:(NSString *)title message:(NSString *)message {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
