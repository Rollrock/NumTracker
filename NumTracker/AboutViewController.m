//
//  AboutViewController.m
//  NumTracker
//
//  Created by zhuang chaoxiao on 15-1-14.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "AboutViewController.h"
#import "SVProgressHUD.h"
#import "dataStruct.h"

@interface AboutViewController ()<SKProductsRequestDelegate,SKPaymentTransactionObserver>
- (IBAction)backClicked;
- (IBAction)buyAdv;
@property (weak, nonatomic) IBOutlet UIButton *buyAdvBtn;
@property (weak, nonatomic) IBOutlet UILabel *contactLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *telLabel;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    BOOL bBuy = [def boolForKey:ADV_BUY_KEY];
    
    if( bBuy )
    {
        [_buyAdvBtn setTitle:@"已购买" forState:UIControlStateNormal];
        _buyAdvBtn.enabled = NO;
    }
    
    _buyAdvBtn.layer.cornerRadius = 8;
    _buyAdvBtn.layer.masksToBounds = YES;

    _bgView.layer.cornerRadius = 8;
    _bgView.layer.masksToBounds = YES;
    
    _iconImgView.layer.cornerRadius = 15;
    _iconImgView.layer.masksToBounds = YES;
    
    _contactLabel.layer.cornerRadius = 8;
    _contactLabel.layer.masksToBounds = YES;
    
    _telLabel.layer.cornerRadius = 8;
    _telLabel.layer.masksToBounds = YES;
}


-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

///点击购买
- (IBAction)buyAdv
{
    [self butIt];
    
    [SVProgressHUD showWithStatus:@"请求中..."];
}


///////////////////////////////////////////////////////////////////////////////////////////////////

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
    NSLog(@"prod count:%d",[myprd count]);
    
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
    
    [SVProgressHUD dismiss];
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
                
                /*
                UIAlertView * alterView = [[UIAlertView alloc]initWithTitle:@"pay success" message:@"pay success" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                
                [alterView show];
                */
                
                [self storeBuyFlag];
                
                [SVProgressHUD showSuccessWithStatus:@"付款成功" duration:3];
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

////////////////////////////////////////////////////////////////////////////////////


-(void)storeBuyFlag
{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    [def setBool:YES forKey:ADV_BUY_KEY];
    
    [def synchronize];
}


-(void)viewDidDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
    
    [super viewDidDisappear:animated];
}

@end
