//
//  AppDelegate.h
//  NumTracker
//
//  Created by zhuang chaoxiao on 14-12-30.
//  Copyright (c) 2014年 zhuang chaoxiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"






@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;



-(void) shareWithTextUrl;
-(BOOL)isWeChatValid;

@end

