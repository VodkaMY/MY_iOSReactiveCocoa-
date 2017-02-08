//
//  RedView.m
//  ReactiveCocoa
//
//  Created by 毛岩 on 2017/2/7.
//  Copyright © 2017年 com.gzkiwi.yinpubaoblue. All rights reserved.
//

#import "RedView.h"


@implementation RedView

//懒加载 用到时使用get方法加载
-(RACSubject *)btnClickSignal
{
    if (_btnClickSignal == nil) {
        _btnClickSignal = [RACSubject subject];
    }
    return _btnClickSignal;
}

-(IBAction)btnClick:(id)sender
{
    NSLog(@"红色按钮点击");
//    //方法1: 发送信号
//    [self.btnClickSignal sendNext:@"按钮被点击了"];
    
}

@end
