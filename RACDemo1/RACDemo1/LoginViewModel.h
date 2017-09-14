//
//  LoginViewModel.h
//  RACDemo1
//
//  Created by Start on 2017/9/14.
//  Copyright © 2017年 het. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
@interface LoginViewModel : NSObject
/**username*/
@property(nonatomic,copy)NSString *username;
/**password*/
@property(nonatomic,copy)NSString *password;
/**成功的信号*/
@property(nonatomic,strong)RACSubject *successSubject;
/**失败的信号*/
@property(nonatomic,strong)RACSubject *failureSubject;
/**错误信号*/
@property(nonatomic,strong)RACSubject *errorSubject;
/**按钮是否可点*/
-(RACSignal *)validSignal;
/**登录操作*/
-(void)login;
@end
