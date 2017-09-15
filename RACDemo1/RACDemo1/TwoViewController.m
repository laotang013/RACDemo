

//
//  TwoViewController.m
//  RACDemo1
//
//  Created by Start on 2017/9/15.
//  Copyright © 2017年 het. All rights reserved.
//

#import "TwoViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
@interface TwoViewController ()
@property(nonatomic, copy)UIButton *button;
@end

@implementation TwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self buildUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)buildUI {
    
    self.button.frame = CGRectMake(50, 100, 50, 30);
    self.RACSequenceButton.frame = CGRectMake(50, 200, 100, 30);
    self.view.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:self.button];
    [self.view addSubview:self.RACSequenceButton];
    self.num = @(1);
    
    //遍历数组
   [[self.RACSequenceButton rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
       [self test6];
   }];
    

}
-(void)test1
{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"flags.plist" ofType:nil];
    NSArray *dictArray = [NSArray arrayWithContentsOfFile:path];
    [dictArray.rac_sequence.signal subscribeNext:^(NSDictionary *dict) {
        NSLog(@"dict %@ %@",dict[@"name"],dict[@"icon"]);
    }error:^(NSError *error) {
        NSLog(@"错误");
    } completed:^{
        NSLog(@"完成");
    }];
}

-(void)test2
{
    //多个订阅者 但是只想发送一个信号的时候怎么办这时我们就可以用RACMulticastConnection，来实现。
    //普通写法, 这样的缺点是：每订阅一次信号就得重新创建并发送请求，这样很不友好
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送请求了");
        [subscriber sendNext:@"Start"];
        return nil;
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
//    2017-09-15 11:09:24.994 RACDemo1[3579:766172] 发送请求了
//    2017-09-15 11:09:24.994 RACDemo1[3579:766172] Start
//    2017-09-15 11:09:24.995 RACDemo1[3579:766172] 发送请求了
//    2017-09-15 11:09:24.995 RACDemo1[3579:766172] Start
//    2017-09-15 11:09:24.995 RACDemo1[3579:766172] 发送请求了
//    2017-09-15 11:09:24.995 RACDemo1[3579:766172] Start
  
}


-(void)test3
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送请求了");
        [subscriber sendNext:@"Start"];
        return nil;

    }];
    //比较好的做法是使用RACMulticastConnection 无论有多少个订阅者无论订阅多少次只发送一个
    RACMulticastConnection *connect = [signal publish];
    [connect.signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    [connect.signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    [connect.signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    //连接 只有连接了才会把信号源变化热信号
    [connect connect];
}

-(void)test4
{
    //RACCommand RAC中用于处理事件的类,可以把事件如何处理 事件中的数据如何传递 包装到这个类中 可以很方便的监控
    //事件的执行过程 比如看事件有没有执行完毕
    //创建命令
    RACCommand *command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"input %@",input);//block调用 执行命令的时候就会调用
        //这里的返回值不允许返回nil
        return[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"执行命令产生的数据"];
            return nil;
        }];
        //return [RACSignal empty];
    }];
    //执行命令
    RACSignal *signal = [command execute:@2];// 这里其实用到的是replaySubject 可以先发送命令再订阅
    // 如何拿到执行命令中产生的数据呢？
    // 订阅命令内部的信号
    // ** 方式一：直接订阅执行命令返回的信号
    [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

-(void)test5
{
    //创建信号中的信号
    RACSubject *signalofsignals = [RACSubject subject];
    RACSubject *signalA = [RACSubject subject];
//        [signalofsignals subscribeNext:^(RACSignal *x) {
//            [x subscribeNext:^(id x) {
//                NSLog(@"%@", x);
//            }];
//        }];
    [signalofsignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    [signalofsignals sendNext:signalA];
    [signalA sendNext:@5];
}

-(void)test6
{
    RACCommand *command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        //block调用  执行命令的时候就会调用
        NSLog(@"%@",input);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
           [subscriber sendNext:@"执行产生的数据"];
            [subscriber sendCompleted];//主动发送完成
            return nil;
        }];
    }];
    //监听事件有没有完成.
    [command.executing subscribeNext:^(id x) {
        if ([x boolValue] == YES) {
            NSLog(@"正在执行");
        }else
        {
            NSLog(@"执行完成");
        }
    }];
}


- (UIButton *)button {
    if (!_button) {
        _button = [[UIButton alloc] init];
        [_button setBackgroundColor:[UIColor grayColor]];
        [_button setTitle:@"pop" forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(btnOnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}
- (UIButton *)RACSequenceButton {
    if (!_RACSequenceButton) {
        _RACSequenceButton = [[UIButton alloc] init];
        [_RACSequenceButton setBackgroundColor:[UIColor grayColor]];
        [_RACSequenceButton setTitle:@"_RACSequenceButton" forState:UIControlStateNormal];
       // [_RACSequenceButton addTarget:self action:@selector(btnOnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _RACSequenceButton;
}

- (void)btnOnClick {
    if (self.subject) {
        //发送信号
        [self.subject sendNext:@"Start"];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
