//
//  User.h
//  RACDemo1
//
//  Created by Start on 2017/9/14.
//  Copyright © 2017年 het. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
/**账号*/
@property(nonatomic,copy)NSString *user;
/**密码*/
@property(nonatomic,copy)NSString *secret;
@end
