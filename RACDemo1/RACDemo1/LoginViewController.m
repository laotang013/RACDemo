
//
//  LoginViewController.m
//  RACDemo1
//
//  Created by Start on 2017/9/14.
//  Copyright © 2017年 het. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginViewModel.h"
#import "User.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
@interface LoginViewController ()
/**viewModel*/
@property(nonatomic,strong) LoginViewModel *viewModel;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self bindModel];
}

-(void)bindModel
{
    self.viewModel = [[LoginViewModel alloc]init];
    RAC(self.viewModel,username) = self.accountField.rac_textSignal;
    RAC(self.viewModel,password) = self.passWordField.rac_textSignal;
    RAC(self.logginButton,enabled) = [self.viewModel validSignal];
    @weakify(self);//订阅登录成功信号并作出处理
    [self.viewModel.successSubject subscribeNext:^(id x) {
        @strongify(self);
        User*user = x[0];
        NSLog(@"username:%@\tpassword:%@", user.user, user.secret);
        NSLog(@"登陆成功");
    }];
    // 订阅登录失败信号并作出处理
    [self.viewModel.failureSubject subscribeNext:^(id x) {
        NSLog(@"登陆失败");
    }];
    
    // 订阅登录错误信号并作出处理
    [self.viewModel.errorSubject subscribeNext:^(id x) {
        NSLog(@"登陆错误");
    }];
    
    //登录
    [[self.logginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.viewModel login];
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
