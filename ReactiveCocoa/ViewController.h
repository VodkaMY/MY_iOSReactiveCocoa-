//
//  ViewController.h
//  ReactiveCocoa
//
//  Created by 毛岩 on 2017/2/6.
//  Copyright © 2017年 com.gzkiwi.yinpubaoblue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RedView.h"

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet RedView *redVIew;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UITextField *textFeild;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *acountTextFeild;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextFeild;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;


@end

