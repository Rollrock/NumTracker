//
//  MyPayMent.h
//  NumTracker
//
//  Created by zhuang chaoxiao on 15-1-11.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface MyPayMent : NSObject<SKProductsRequestDelegate,SKPaymentTransactionObserver>

-(void)butIt;

@end
