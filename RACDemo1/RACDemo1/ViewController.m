//
//  ViewController.m
//  RACDemo
//
//  Created by Start on 2017/9/11.
//  Copyright © 2017年 het. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
@interface ViewController ()
/**uilabel*/
@property(nonatomic,strong)UILabel *label;
/**按钮*/
@property(nonatomic,strong)UIButton *button;
@end

@implementation ViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.label];
    self.label.frame = CGRectMake(100, 100, 100, 30);
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]init];
    [[tapGes rac_gestureSignal]subscribeNext:^(id x) {
        NSLog(@"点击了label");
    }];
    [self.label addGestureRecognizer:tapGes];
    
    
    //监听按钮的点击方法
    @weakify(self);
    [[self.button rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
         @strongify(self);
        NSLog(@"按钮点击了");
    }];
    
    //代替通知
    RACSignal *deallocSignal = [self rac_signalForSelector:@selector(viewWillDisappear:)];
    [[[RACSignal interval:2 onScheduler:[RACScheduler mainThreadScheduler]]takeUntil:deallocSignal] subscribeNext:^(id x) {
        //NSLog(@"每隔两秒执行一次");
    }];
    
    RACSignal *signal11 = [RACSignal return:@1];
    //对信号11进行加工 对信号12进行订阅时能够返回两倍的值
    RACSignal *signal12 = [signal11 map:^id(NSNumber *value) {
        return @(value.integerValue *2);
    }];
    
    [signal12 subscribeNext:^(id x) {
        NSLog(@"signal12: %@",x);
    }];
    
    //创建一个信号
    RACSignal *testSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"发送一个信号"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    //订阅信号
    [testSignal subscribeNext:^(id x) {
        NSLog(@"x: %@",x);
    }];
    
    
   //创建事件
    RACCommand *command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        //第一步：创建命令，命令里必须要返回一个信号，如果不想返回可以返回一个空信号（[RACSignal empty]），然后在命令里创建信号，来传输数据，可以是这个命令接收到的也可以是任意的。
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:input];
            [subscriber sendCompleted];
            return nil;
        }];
        return signal;
    }];
    //第二步：接收命令里的信号中的数据
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    [command execute:@"执行"];
    //以上三步就是一个完整的command命令流程，这个方法是用来监听命令执行过程中的状态
    [command.executing subscribeNext:^(id x) {
        if ([x boolValue] == YES) {
            NSLog(@"正在执行");
        }else
        {
            NSLog(@"尚未执行");
        }
    }];
    
    
    //遍历数组
    NSArray *array = @[@"1",@"3",@"5"];
    RACSequence *sequence = [array rac_sequence];
    [sequence.signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    //包装一个元组
    RACTuple *tuple = RACTuplePack(@"test",@24);
    RACTupleUnpack(NSString *name,NSNumber *age) = tuple;
    NSLog(@"name %@,age %@",name,age);
    
    
    
    
    //遍历字典
    NSDictionary *dictonary =  @{@"title":@"RAC",@"auther":@"潮汐"};
    RACSequence *dSequence = [dictonary rac_sequence];
    [dSequence.signal subscribeNext:^(RACTuple *x) {
        RACTupleUnpack(NSString *key,NSString *value) = x;
        NSLog(@"%@, %@",key,value);
    }];
    
    //对信号的延时处理
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"text"];
        [subscriber sendCompleted];
        return nil;
    }]delay:2]subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    
    //RAC代理
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"RACTest" message:@"text" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"ohter", nil];
    [[self rac_signalForSelector:@selector(alertView:clickedButtonAtIndex:) fromProtocol:@protocol(UIAlertViewDelegate)]subscribeNext:^(RACTuple *tuple) {
        //RACTuple是RAC为我们提供的一种集合数据类型叫做元祖   表中的每行（即数据库中的每条记录）就是一个元组
        NSLog(@"取消%@ , other%@",tuple.first,tuple.second);
    }];
    [alertView show];
    
    //**RACObserve(self, name)：**监听某个对象的某个属性,返回的是信号，可以用来代替KVO
    [RACObserve(self.view, backgroundColor)subscribeNext:^(id x) {
        NSLog(@"backgroundColor");
    }];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UILabel *)label
{
    if (!_label) {
        _label = [[UILabel alloc]init];
        _label.userInteractionEnabled = YES;
        _label.backgroundColor = [UIColor orangeColor];
        _label.text = @"点击";
        _label.font = [UIFont systemFontOfSize:13.0f];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}

-(UIButton *)button
{
    if (!_button) {
        _button = [[UIButton alloc]init];
        [_button setTitle:@"按钮点击" forState:UIControlStateNormal];
    }
    return _button;
}

/*
 1.对事件的监听。目标动作 targer-action
 2.信号 RACSignal(信号类)Signal是RAC中的核心概念 当数据改变的时候，信号内部就会收到数据,然后发出，但是默认一个信号是冷信号，当一个信号没有订阅者时它什么也不干，信号可以通过以下三种方式发送事件给订阅者。
    2.1 subscriber sendNext:@""//发送 可以有多少sendNext
    2.2 subscriber sendComplete//发送完成 只能有一次sendComplete或sendError
    2.3 subscriber sendError//发送中的错误
 3. RACCommand 处理事件的类 监控了事件的整个处理过程,对事件如何处理和其中数据的传递都做了处理
 4.RACTuple（元组类） 类似数组http://cocoadocs.org/docsets/ReactiveCocoa/2.3.1/Classes/RACTuple.html
 5.RACSequence（集合类）：RAC中的NSArray，NSDictionary，可以通过rac_sequence方法使NSArry转换为RACSequence。但是传闻ReactiveCocoa3中将会废弃sequences。
 6.常用的Category
     RAC为系统的很多类扩展了功能，其中UIControl的类目内容如下:
     - (RACSignal *)rac_signalForControlEvents:(UIControlEvents)controlEvents;
     RAC扩展了这个方法，而这个方法的返回值类型是RACSignal,signal是信号的意思我们将获得一个信号，此时这个信号是一个冷信号，不会做任何事情,我们可以通过订阅这个信号,使其变为一个热信号，这样当事件触发信号就会给我们发送消息，发送消息的方式是一个block回调，block里会有一个id类型的参数x作为消息的内容
    6.1 RAC提供了一个宏 可以方便的将信号发送过来的值赋给某个对象的某个属性 RAC(对象的属性,值);
 7.RACSubject
    用来代替代理/通知
    1.创建信号 2.订阅信号 3 发送信号 
    RACSubject *subject = [RACSubject subject];
     [subject subscribeNext:^(id x) {
     // block:当有数据发出的时候就会调用
     // block:处理数据
     NSLog(@"%@",x);
     }];
     [subject sendNext:value];
 小结: 究其本质核心就是signals 也就是bind(绑定) 处理相关事务的时候首先要想到的就是绑定
 
 */

/*
 MVVM讲解 
    1. 拆解 
        M: Model 包括数据模型、访问数据库的操作和网络请求等
        V: view 包括了iOS中View和Controller组成,负责UI的展示，绑定ViewModel中的属性
        VM:viewModel 负责从model中获取View所需的数据,转换成View可以展示的数据,并暴露公开的属性和命令供View进行绑定。
        Binder：这是我最近发现的，在标准MVVM中没有提到的一部分，但是如果使用MVVM + ReactiveCocoa就会自然地写出这一层。这一层主要为了实现响应式编程的功能，实现 View 和 ViewModel 的同步
 
 
 */

@end
