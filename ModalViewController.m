//
//  ModalViewController.m
//  ReactiveCocoa
//
//  Created by 毛岩 on 2017/2/7.
//  Copyright © 2017年 com.gzkiwi.yinpubaoblue. All rights reserved.
//

#import "ModalViewController.h"
#import "GlobeHeader.h"

@interface ModalViewController ()
@property(nonatomic,strong)RACSignal * signal;

@end

@implementation ModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self);
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        NSLog(@"%@",self);
        
        return nil;
    }];
    _signal = signal;
}
- (IBAction)diismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)dealloc
{
    NSLog(@"%s",__func__);
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

@end
