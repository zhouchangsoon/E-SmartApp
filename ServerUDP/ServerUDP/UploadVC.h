//
//  UploadVC.h
//  Instagram
//
//  Created by zcs on 2017/6/20.
//  Copyright © 2017年 周昌盛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVOSCloud/AVOSCloud.h>

@interface UploadVC : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITextField *bookname;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIImageView *picImg;
@property (strong, nonatomic) IBOutlet UITextView *introText;
@property (strong, nonatomic) IBOutlet UIButton *publishBtn;

- (IBAction)publish:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *deleteBtn;
- (IBAction)deleteImg:(UIButton *)sender;

@property (strong, nonatomic) NSString* translation;
@property (strong, nonatomic) NSString* text;

@end
