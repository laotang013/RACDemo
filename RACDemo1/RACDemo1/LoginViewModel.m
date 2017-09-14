//
//  LoginViewModel.m
//  RACDemo1
//
//  Created by Start on 2017/9/14.
//  Copyright © 2017年 het. All rights reserved.
//

#import "LoginViewModel.h"
#import "User.h"
@interface LoginViewModel()
/**用户改变信号*/
@property(nonatomic,strong)RACSignal *userNameSignal;
/**密码改变信号*/
@property(nonatomic,strong)RACSignal *passwordSignal;
/**请求数据*/
@property(nonatomic,strong)NSArray *requestData;
@end
@implementation LoginViewModel
-(instancetype)init
{
    if (self = [super init]) {
        _userNameSignal = RACObserve(self, username);
        _passwordSignal = RACObserve(self, password);
        _successSubject = [RACSubject subject];
        _failureSubject = [RACSubject subject];
        _errorSubject = [RACSubject subject];
    }
    return  self;
}

-(RACSignal *)validSignal
{
    RACSignal *validSignal = [RACSignal combineLatest:@[_userNameSignal,_passwordSignal] reduce:^id(NSString *userName,NSString *password){
        return @(userName.length >=6&& password.length >= 6);
    }];
    return validSignal;
}

-(void)login
{
    User *user = [[User alloc]init];
    user.user = self.username;
    user.secret = self.password;
    _requestData = @[user];
    //发送成功的信号
    [_successSubject sendNext:_requestData];
    
}

@end
