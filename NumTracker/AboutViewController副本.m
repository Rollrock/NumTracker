//
//  AboutViewController.m
//  NumTracker
//
//  Created by zhuang chaoxiao on 15-1-7.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "AboutViewController.h"
#import <StoreKit/StoreKit.h>
#import "dataStruct.h"

@interface AboutViewController ()<SKProductsRequestDelegate,SKPaymentTransactionObserver>

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self layoutBackView];
    
    [self layoutBuyView];
    
    self.view.backgroundColor = [UIColor grayColor];
}

-(void)layoutBackView
{
    UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(10, 20, 40, 40)];
    [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

-(void)layoutBuyView
{
    UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 20, 40, 40)];
    [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(buyClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}


-(void)buyClicked
{
    [self butIt];
}


-(void)backClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

///////////////

-(void)butIt
{
    [self initialStore];
    
    [self buy:@"dis_adv"];
}


-(void)initialStore
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

-(void)releaseStore
{
    NSLog(@"-releaseStore-");
    
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

-(void)buy:(NSString*)prdTag
{
    [self requestProductData:prdTag];
}

-(BOOL)CanMakePay
{
    return [SKPaymentQueue canMakePayments];
}


-(void)requestProductData:(NSString*)prdTag
{
    NSLog(@"-requestProductData-");
    
    NSArray * product = [[NSArray alloc] initWithObjects:prdTag, nil];
    NSSet * nsset = [NSSet setWithArray:product];
    SKProductsRequest * req = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    req.delegate = self;
    
    [req start];
    
}


-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray * myprd = response.products;
    
    NSLog(@"prodId:%@",response.invalidProductIdentifiers);
    NSLog(@"prod count:%ud",[myprd count]);
    
    //
    
    for( SKProduct * product in myprd )
    {
        NSLog(@"SK desc:%@",[product description]);
        NSLog(@"title:%@",[product localizedTitle]);
        NSLog(@"desc :%@",[product localizedDescription]);
        NSLog(@"price:%@",[product price]);
        NSLog(@"id:%@",[product productIdentifier]);
    }
    
    SKPayment * payment = nil;
    payment = [SKPayment paymentWithProduct:[response.products objectAtIndex:0]];
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}


-(void)requestProUpgradeProductData:(NSString*)idTag
{
    
    NSLog(@"----requestProUpgradeProductData----");
    
    NSSet * prodId = [NSSet setWithObject:idTag];
    SKProductsRequest * prodReq = [[SKProductsRequest alloc] initWithProductIdentifiers:prodId];
    prodReq.delegate = self;
    
    [prodReq start];
}


-(void)purchasedTransaction:(SKPaymentTransaction*)tran
{
    NSLog(@"----purchasedTransaction----");
    
    NSArray * trans = [[NSArray alloc]initWithObjects:tran, nil];
    [self paymentQueue:[SKPaymentQueue defaultQueue] updatedTransactions:trans];
    
}


-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for( SKPaymentTransaction * tran in transactions )
    {
        switch (tran.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
            {
                [self completeTransaction:tran];
                
                UIAlertView * alterView = [[UIAlertView alloc]initWithTitle:@"pay success" message:@"pay success" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                
                [alterView show];
                
                //
                
                NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
                [def setBool:YES forKey:ADV_BUY_KEY];
                [def synchronize];
                
            }
                break;
                
            case SKPaymentTransactionStateFailed:
            {
                [self completeTransaction:tran];
                
                UIAlertView * alterView = [[UIAlertView alloc]initWithTitle:@"pay failed" message:@"pay failed" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                
                [alterView show];
            }
                break;
                
                
            case SKPaymentTransactionStateRestored:
            {
                NSLog(@"SKPaymentTransactionStateRestored");
            }
                break;
                
            case SKPaymentTransactionStatePurchasing:
            {
                NSLog(@"SKPaymentTransactionStatePurchasing");
            }
                break;
                
            default:
                break;
        }
    }
}

-(void)completeTransaction:(SKPaymentTransaction*)tran
{
    NSLog(@"completeTransaction");
    
    NSString * prod = tran.payment.productIdentifier;
    
    if( [prod length] > 0 )
    {
        NSArray * tt = [prod componentsSeparatedByString:@"."];
        
        NSString * bookId = [tt lastObject];
        
        NSLog(@"bookId:%@",bookId);
        
        if( [bookId length] > 0 )
        {
            [self recordTransaction:bookId];
            [self provideContent:bookId];
        }
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction:tran];
}

-(void)recordTransaction:(NSString *)product
{
    NSLog(@"-----Record transcation--------\n");
}

-(void)provideContent:(NSString *)product
{
    NSLog(@"-----Download product content--------\n");
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"Failed\n");
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

-(void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction
{
    NSLog(@"-----paymentQueueRestoreCompletedTransactionsFinished-------\n");
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"-----Restore transaction--------\n");
}

-(void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"-------Payment Queue----\n");
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
