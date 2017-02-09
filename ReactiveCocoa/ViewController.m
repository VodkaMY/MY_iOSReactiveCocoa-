//
//  ViewController.m
//  ReactiveCocoa
//
//  Created by 毛岩 on 2017/2/6.
//  Copyright © 2017年 com.gzkiwi.yinpubaoblue. All rights reserved.
//

#import "ViewController.h"
#import "GlobeHeader.h"
#import "RACReturnSignal.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}
#pragma mark - 过滤
/**
 ignore
 filter:适用于文本框
 take
 distinctUntilChanged
 skip:跳过几个信号
 */
-(void)skip
{
    //skip:跳过几个信号
    //1. 创建信号
    RACSubject * subject = [RACSubject subject];
    
    [[subject skip:2] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    [subject sendNext:@"2"];
    [subject sendNext:@"3"];
    [subject sendNext:@"3"];
}
-(void)distinctUntilChanged
{
    //distinctUntilChanged:如果当前的值跟上一个值相同就不会被订阅到
    //1. 创建信号
    RACSubject * subject = [RACSubject subject];
    [[subject distinctUntilChanged] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    [subject sendNext:@"1"];
    [subject sendNext:@"1"];
    [subject sendNext:@"2"];
}
-(void)take
{
    //创建信号
    //take:取前面几个值
    //takeLast:取后面几个值, 必须调用发送完成
    //takeUntil:传一个信号,表示只要传入进去的信号发送完成或者发送任意数据, 的时候就不会接收原信号内容了
    RACSubject * subject = [RACSubject subject];
    RACSubject * signal = [RACSubject subject];
    [[subject takeUntil:signal] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    [subject sendNext:@"1"];
    [subject sendNext:@"2"];
    //传入信号发送完成
    [signal sendCompleted];
    
    [subject sendNext:@"3"];
    
    [subject sendCompleted];
}
-(void)ignore
{
    //ignoer:忽略一些值
    
    //创建信号
    RACSubject * subject = [RACSubject subject];
    
    //处理信号:忽略信号
    [[subject ignore:@"1"] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    //    [subject ignoreValues] //忽略所有值
    
    //订阅信号
    
    
    //发送信号
    [subject sendNext:@"1"];
}

-(void)filter
{
    //需求:只有当我们文本框的的长度大于5的时候才想获取文本框的内容
    [[_textFeild.rac_textSignal filter:^BOOL(id value) {
        //value:原信号的内容
        return [value length] > 5;
        //返回值,就是过滤条件,只有满足田间才能获取到内容
        
        
    }] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark - combineLatest与reduce组合:组常用的,一定要掌握
-(void)combineLatestReduce
{
    //组合:需求acountTextFeild和pwdTextFeild同时有内容的时候才能点击按钮
    RACSignal * conbineSignal = [RACSignal combineLatest:@[_pwdTextFeild.rac_textSignal,_acountTextFeild.rac_textSignal] reduce:^id(NSString * account,NSString * pwd){
        //block:只要组合信号发送信号就会调用,组成一个新的值
        NSLog(@"account = %@ pwd = %@",account,pwd);
        //聚合的值就是组合信号的内容
        return@(account.length && pwd.length);//包装成bool值
    }];
    
    [conbineSignal subscribeNext:^(id x) {
        _loginBtn.enabled = [x boolValue];
    }];
    RAC(_loginBtn,enabled) = conbineSignal;
}
#pragma mark - ReactiveCocoa组合
/**
 concat:顺序请求
 then:忽略1信号
 merge:只要有一个请求就会发送信号
 zipwith:两个信号同时发送信号,压缩信号为tuple元组, 发送next,所有请求完成
 combineLatest与reduce组合:组常用的,一定要掌握
 */
-(void)zipSignal
{
    //zipWith
    //创建信号A
    RACSubject * signalA = [RACSubject subject];
    //创建信号B
    RACSubject * signalB = [RACSubject subject];
    //组合元组:所有信号发送成功后才更新UI
    RACSignal * zipSignal = [signalA zipWith:signalB];
    [zipSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    //发送信号:与发送顺序无关, 与组合顺序有关[signalA zipWith:signalB];
    [signalA sendNext:@"signalA"];
    [signalB sendNext:@"singalB"];
}
-(void)concatAndThen
{
    //ReactiveCocoa组合
    
    //使用注意点:使用时一定要调用发送完成 sendCompleted
    
    //创建信号A,AFN请求一般是RACSignal
    RACSignal * signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //使用AFN请求后发送请求
        [subscriber sendNext:@"发送上部分请求"];
        
        //发送完成
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    
    //创建信号B
    RACSignal * signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //使用AFN请求后发送请求
        [subscriber sendNext:@"发送下部分请求"];
        
        //发送完成
        
        [subscriber sendCompleted];
        return nil;
    }];
    
    //需求A请求完进行B的请求
    RACSignal * concatSignal = [signalA concat:signalB];
    
    //创建组合信号
    //then:忽略第一个信号的所有值
    RACSignal * concatSignal1 = [signalA then:^RACSignal *{
        return signalB;
    }];
    
    //订阅信号
    [concatSignal subscribeNext:^(id x) {
        //既能拿到A信号的值也能拿到B信号的值
        NSLog(@"%@",x);
    }];
}
-(void)merege
{
    //创建信号A
    RACSubject * signalA = [RACSubject subject];
    //创建信号B
    RACSubject * signalB = [RACSubject subject];
    
    //组合信号
    RACSignal * mergeSignal = [signalA merge:signalB];
    
    //订阅信号
    [mergeSignal subscribeNext:^(id x) {
        //任意信号被订阅都会来到这里
        NSLog(@"%@",x);
    }];
    
    //发送信号
    [signalA sendNext:@"上部分"];
    [signalB sendNext:@"下部分"];
}
#pragma mark - ReactiveCocoa开发中常用绑定映射
-(void)flattenMapCommonUse
{
    //flattenMap:用于信号中的信号
    //创建信号
    RACSubject * signalOfSignal = [RACSubject subject];
    RACSubject * signal = [RACSubject subject];
    
    //订阅信号
    
    //原始方法
    [signalOfSignal subscribeNext:^(id x) {
        [x subscribeNext:^(id x) {
            NSLog(@"方法一:%@",x);
        }];
    }];
    [signalOfSignal.switchToLatest subscribeNext:^(id x) {
        NSLog(@"方法二:%@",x);
    }];
    //flattenMap方法
    RACSignal * bingSignal = [signalOfSignal flattenMap:^RACStream *(id value) {
        
        return value;
    }];
    [bingSignal subscribeNext:^(id x) {
        NSLog(@"方法三:%@",x);
    }];
    
    //开发中的常用方法
    [[signalOfSignal flattenMap:^RACStream *(id value) {
        return value;
    }] subscribeNext:^(id x) {
        NSLog(@"开发中常用的方法:%@",x);
    }];
    //发送信号
    
    [signalOfSignal sendNext:signal];
    [signal sendNext:@123];
}
-(void)map
{
    //ReactiveCocoa操作方法之映射
    //创建信号
    RACSubject * subject = [RACSubject subject];
    
    //绑定信号
    RACSignal * bindSignal = [subject map:^id(id value) {
        //返回的值就是一个映射的值
        //        NSLog(@"%@",value);
        return [NSString stringWithFormat:@"绑定后的信号%@",value];
    }];
    
    //订阅信号
    [bindSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    //发送信号
    [subject sendNext:@123];
}

//flattenMap
-(void)flattenMap
{
    //1. 创建信号
    RACSubject * subjiect = [RACSubject subject];
    
    //绑定信号
    RACSignal * bingSignal = [subjiect flattenMap:^RACStream *(id value) {
        //只要原信号发送内容就会调用
        //value就是原信号发送的内容
        value = [NSString stringWithFormat:@"处理后的value%@",value];
        
        //返回信号就是用来包装成修改内容的值
        
        //导入RACReturnSignal.h
        return [RACReturnSignal return:value];
    }];
    
    //绑定信号flattenMap中返回的是什么信号,订阅的就是什么信号
    
    //2. 订阅信号
    [bingSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    //3. 发送信号
    [subjiect sendNext:@123];
}
#pragma mark - ReactiveCocoa常见操作方法介绍
-(void)ReactiveCocoaCommonUse
{
    //ReactiveCocoa常见操作方法介绍
    //ReactiveCocoa操作思想Hook钩子思想
    //1. 创建信号
    RACSubject * subject = [RACSubject subject];
    
    //2. 绑定信号,对原信号进行处理
    RACSignal * bindSignal = [subject bind:^RACStreamBindBlock{
        //返回RACStream信号, 万物皆是流
        return ^RACSignal*(id value, BOOL *stop){
            //block调用:只要原信号发送信号就会调用block
            //block作用:处理原信号
            //value:原信号发送的信号
            NSLog(@"接收到原信号%@",value);
            value = [NSString stringWithFormat:@"MY%@",value];
            //信号返回一定不能传nil,返回空信号[RACSignal empty]
            return [RACReturnSignal return:value];
        };
    }];
    
    //3. 订阅绑定信号
    [bindSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    //4. 发送数据
    [subject sendNext:@"1"];
}
#pragma mark - command重点

-(void)command2
{
    //RACCommand
    //当前命令内部数据发送返程, 一定要主动发送完成
    //1. 创建命令
    RACCommand * command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"打印命令:%@",input);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            //发送信号
            [subscriber sendNext:@"执行命令产生的数据"];
            //发送完成
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    
    //订阅信号
    //监听事件有没有完成
    [command.executing subscribeNext:^(id x) {
        if ([x boolValue] == YES) { //当前正在执行
            NSLog(@"正在执行");
        }else{
            //执行完成 没有完成
            NSLog(@"执行完成 没有完成");
        }
    }];
    //executionSignals:信号源,signalOfSignal:信号中的信号:发送的数据就是信号
    [command.executionSignals subscribeNext:^(RACSignal * x) {
        [x subscribeNext:^(id x) {
            NSLog(@"%@",x);
        }];
    }];
    
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    //2. 执行命令
    [command execute:@1];
}

-(void)command1
{
    //1. 创建命令
    RACCommand * command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        
        NSLog(@"%@",input);
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            //发送数据
            [subscriber sendNext:@"执行命令发送的数据"];
            //发送完成
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    
    //如何拿到执行命令中产生的数据
    //订阅命令的内部信号
    //1. 方式一:直接执行命令产生的信号
    
    
    //2. 执行命令
    RACSignal * signal = [command execute:@1];
    
    //3. 订阅信号
    [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}
#pragma mark - 解决多次订阅bug
-(void)requestOnce
{
    //每次订阅不要都请求一次,指向请求一次,只要拿到数据就好了
    
    //不管订阅多少次,只会请求一次
    
    //RACMulticastConnection: 使用必须要有信号
    
    //1. 创建信号
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送热门模块的请求");
        //5. 发送信号
        [subscriber sendNext:@1];
        return  nil;
    }];
    //2. 把信号转换成连接类
    //Multicast:多路传送
    //    RACMulticastConnection * muticast = [signa    l publish];
    RACMulticastConnection * muticast = [signal multicast:[RACReplaySubject subject]];
    //3. 订阅链接类的信号
    [muticast.signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    //4. 连接
    [muticast connect];
}
-(void)requestBug
{
    //1. 创建信号
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        static int i = 0;
        i++;
        NSLog(@"创建订阅信号: %d",i);
        //3. 发送信号
        [subscriber sendNext:@1];
        return [RACDisposable disposableWithBlock:^{
            
        }];
    }];
    
    //2. 订阅信号
    [signal subscribeNext:^(id x) {
        NSLog(@"第一个订阅者:%@",x);
    }];
    [signal subscribeNext:^(id x) {
        NSLog(@"第二个订阅者:%@",x);
    }];
}

#pragma mark - rac常用宏
/*
    RAC
    RACObserve
    @weakify(self)/@strongify(self)
    RACTuplePack/RACTupleUnpack
 */
-(void)ReactiveCocoa
{
    
    //ReactiveCocoa常用宏
    //    [_textFeild.rac_textSignal subscribeNext:^(id x) {
    //        NSLog(@"%@",x);
    //        _label.text = x;
    //    }];
    //1. 用来给某个对象的某个属性绑定信号,只要产生信号的内容,就会给内容的属性赋值
    RAC(_label,text) = _textFeild.rac_textSignal;
    
    //2. 观察者
    [RACObserve(self.view, frame) subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    //3. 解决强引用
    @weakify(self);
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        NSLog(@"%@",self);
        
        return nil;
    }];
    //    _signal = signal;
    
    //4. 包装元组
    RACTuple * tuple = RACTuplePack(@"1",@"2");
    NSLog(@"%@",tuple[0]);
}

#pragma mark - rac常用开发场景
/*
 1. 代替代理: RACSubject
 2. 代替KVO
 3. 监听事件
 4. 代替通知
 5. 监听文本框
 6. 当有多个请求时, 请求全部完成才能显示界面liftSelector
 */
-(void)RACPutIntoUse
{
    //RAC开发中常用的场景
    //1. 代替代理: RACSubject
    [_redVIew.btnClickSignal subscribeNext:^(id x) {
        NSLog(@"点击按钮传值过来%@",x);
    }];
    //RAC
    //把控制器调用didReceiveMemoryWarning转换成一个信号
    [[self rac_signalForSelector:@selector(didReceiveMemoryWarning)] subscribeNext:^(id x) {
        NSLog(@"didReceiveMemoryWarning调用了");
    }];
    //不能传值
    [[_redVIew rac_signalForSelector:@selector(btnClick:)] subscribeNext:^(id x) {
        NSLog(@"按钮被点击了");
    }];
    
    //2. 代替KVO
    [_redVIew rac_observeKeyPath:@"frame" options:NSKeyValueObservingOptionNew observer:nil block:^(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent) {
        
    }];
    
    [[_redVIew rac_valuesForKeyPath:@"frame"  observer:nil] subscribeNext:^(id x) {
        //订阅信号
        NSLog(@"%@",x);
    }];
    
    //3. 监听事件
    [[_btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSLog(@"按钮点击%@",x);
    }];
    
    //4. 代替通知
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardDidShowNotification object:nil] subscribeNext:^(id x) {
        NSLog(@"键盘出来了");
    }];
    
    //5. 监听文本框
    [_textFeild.rac_textSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    //6. 当有多个请求时, 请求全部完成才能显示界面liftSelector
    //请求热销模块
    RACSignal * hotSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //请求数据
        NSLog(@"AFN请求热销数据");
        [subscriber sendNext:@"热销模块的数据"];
        return nil;
    }];
    RACSignal * newSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"AFN请求最新数据");
        [subscriber sendNext:@"最新模块数据"];
        return nil;
    }];
    //请求最新模块
    
    //数组:存放信号
    //当数组中所有信号都发送数据的时候,才会执行Selecter
    //方法的参数必须跟数组的信号一一对应
    [self rac_liftSelector:@selector(updateUIWithHotData:newData:) withSignals:hotSignal,newSignal,nil];
}
-(void)updateUIWithHotData:(NSString * )hotData newData:(NSString * )newData
{
    //拿到数据更新UI
    NSLog(@"hotData %@, newData %@",hotData,newData);
}
//字典转模型
-(void)dicToModel
{
    NSArray * dicArr = [NSArray array];
    NSArray * dataList =  [[dicArr.rac_sequence map:^id(NSDictionary * value) {
        //value是dic, 可以使用mjexternsion
        return nil;
    }] array];
}
-(void)RACSecquenceDic
{
    NSDictionary * dic = @{@"account":@"aaa",@"name":@"xmg",@"age":@18};
    [dic.rac_sequence.signal subscribeNext:^(id x) {
        //x = RACTuple
        //        NSString * key = x[0];
        //        NSString * value = x[1];
        //        NSLog(@"key = %@ , value = %@",key,value);
        //RACTupleUnpack 用来解析元组,传需要解析的变量名
        RACTupleUnpack(NSString * key,NSString * value) = x;
        NSLog(@"key = %@ , value = %@",key,value);
    }];
}
-(void)RACSecquencArr
{
    //RACSequence集合:RAC中的集合类用替换OC中的NSArray/NSDictionary,可以使用它来快速遍历数组和字典
    NSArray * arr = @[@"123",@"231",@"321"];
    //RAC集合
    RACSequence * secquence = arr.rac_sequence;
    //把集合转换成信号
    RACSignal * signal = secquence.signal;
    //订阅信号,内部会遍历所有元素发送元素
    [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    //简便写法
    [arr.rac_sequence.signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}
//元组
-(void)RACTuple
{
    //元组
    RACTuple * tuple = [RACTuple tupleWithObjectsFromArray:@[@"123",@"231",@"321"]];
    NSString * str = tuple[0];
    NSLog(@"%@",str);
}
//使用RACSubjext替换代理反向传值
-(void)RACSubjextDelegate
{
    //订阅信号
    [_redVIew.btnClickSignal subscribeNext:^(id x) {
        NSLog(@"订阅信号:%@",x);
    }];
}
//RACReplaySubject
-(void)RACReplaySubject
{
    //1. 创建信号
    RACReplaySubject * subject = [RACReplaySubject subject];
    
    //2. 订阅信号
    [subject subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    //遍历所有的值,拿到当前的订阅者去发送数据
    //3. 发送信号
    [subject sendNext:@123];
    
    //RACReplaySubject发送数据:
    //1. 保存值
    //2. 调用父类, 便利所有订阅者发送数据
}
//使用RACSubjext进行代替代理
-(void)RACSubjext
{
    //1. 创建信号
    RACSubject * subject = [RACSubject subject];
    
    //2. 订阅信号
    [subject subscribeNext:^(id x) {
        NSLog(@"第一个订阅者%@",x);
    }];
    
    [subject subscribeNext:^(id x) {
        NSLog(@"第二个订阅者%@",x);
    }];
    
    
    //3. 发送信号
    [subject sendNext:@1];
}

//使用有值进行使用RACSignal
-(void)RACSignal
{
    //RACSignal:有数据产生就使用RACSignal
    //RACSignal使用步骤: 1.创建信号 2.订阅信号 3.发送信号
    //1.创建信号(冷信号)
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //didSubscribe调用:只要一个信号被订阅就会被调用
        //didSubscribe作用:发送数据
        //3.发送数据
        [subscriber sendNext:@1];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"订阅者被取消");
        }];
    }];
    //2.订阅信号(热信号)
    RACDisposable * disposable = [signal subscribeNext:^(id x) {
        //nextBlock调用:订阅者发送数据就会调用
        //nextBlock作用:处理数据,展示到UI上面
        //x: 信息发送的内容
        NSLog(@"%@",x);
    }];
    //取消订阅信号
    [disposable dispose];
    
    //只要订阅sendNext,就会执行nextBlock
    //只要订阅RACDynamicSignal,就会执行didSubscribe
    //前提条件RACDynamicSignal,不同类型的订阅,处理订阅的事情不一样
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
