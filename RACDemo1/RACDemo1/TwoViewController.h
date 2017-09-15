//
//  TwoViewController.h
//  RACDemo1
//
//  Created by Start on 2017/9/15.
//  Copyright © 2017年 het. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
@interface TwoViewController : UIViewController
/**创建信号*/
@property(nonatomic,strong)RACSubject *subject;
/**<#name#>*/
@property(nonatomic,strong)NSNumber *num;
@property (nonatomic,strong)  UIButton *RACSequenceButton;
@end
