//
//  ViewController.m
//  NumTracker
//
//  Created by zhuang chaoxiao on 14-12-30.
//  Copyright (c) 2014年 zhuang chaoxiao. All rights reserved.
//

#import "dataStruct.h"
#import "ViewController.h"
#import "MyImageView.h"
#import "JSONKit.h"
#import "GADBannerView.h"
#import "AppDelegate.h"
#import "AboutViewController.h"
#import "BaiduMobAdView.h"
#import "BaiduMobAdDelegateProtocol.h"
#import "BaiduMobAdInterstitial.h"




typedef enum
{
    IPHONE_4,
    IPHONE_5,
    IPHONE_6,
    IPHONE_6P
}IPHONE_TYPE;


/*
 -999 表示空 也就是没有
 1000 以上的 表示移动的目标
 1-9  表示不移动的普通目标
 500 以上的 表示可变的目标
 */




#define PASS_STORE_KEY  @"pass_store"

@interface ViewController ()<MyImageViewDelegate,BaiduMobAdViewDelegate,BaiduMobAdInterstitialDelegate>
{
    NSMutableArray * _InfoArray;
    
    NSMutableArray * _dataArray;
    NSMutableArray * _spDataArray;
    
    GADBannerView * _bannerView;
    
    int ROW_NUM;
    int COLUMN_NUM;
    
    CGFloat X_BEGIN_POS;
    CGFloat Y_BEGIN_POS;
    
    CGFloat screen_width;
    CGFloat screen_heigth;
    
    //
    UIView * _passView;
    BaiduMobAdView * _baiduView;
    
    IPHONE_TYPE _iphoneType;
    
    BOOL _advBuy;
}

@end

@implementation ViewController


-(void)initAdvBuyFlag
{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    _advBuy = [def boolForKey:ADV_BUY_KEY];
}

-(NSString*)getCurPass
{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    
    NSInteger val = [def integerForKey:PASS_STORE_KEY];
    
    return [NSString stringWithFormat:@"%d",val+1];
}

-(void)setCurPass
{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    
    NSInteger val = [def integerForKey:PASS_STORE_KEY];
    val += 1;
    
    [def setInteger:val forKey:PASS_STORE_KEY];
    [def synchronize];
}

-(BOOL)isGameSuccess
{
    for( int i = 0; i < [_InfoArray count]; ++ i )
    {
        ImgViewInfo *info = [_InfoArray objectAtIndex:i];
        
        if( info.num != 0 || info.repeatCount != 0 )
        {
            return NO;
        }
    }
    
    
    NSLog(@"GameSuccess");
    
    return YES;
}


//过关广告被点击
-(void)didAdClicked
{
    [self hidePassView];
}

//隐藏过关
-(void)hidePassView
{
    [UIView animateWithDuration:1 animations:^(void){
        
        _passView.frame = CGRectMake(0, 0, 1, 1);
        _passView.center = self.view.center;
        _passView.hidden = YES;
        
    }];
}

//显示过关
-(void)showPassView
{
    [UIView animateWithDuration:1 animations:^(void){
        
        _passView.hidden = NO;
        
        if( _iphoneType == IPHONE_4 )
        {
            _passView.frame = CGRectMake(0, 0, screen_width, 370);
        }
        else if (_iphoneType == IPHONE_5)
        {
             _passView.frame = CGRectMake(0, 0, screen_width, 450);
        }
        else if(_iphoneType == IPHONE_6 )
        {
            _passView.frame = CGRectMake(0, 0, screen_width, 490);
        }
        else if(_iphoneType == IPHONE_6P )
        {
            _passView.frame = CGRectMake(0, 0, screen_width, 610);
        }
        
        
        if(_advBuy)
        {
            _passView.frame = CGRectMake(0, 0, screen_width, 200);
            _passView.center = self.view.center;
        }
        
        
        [self.view bringSubviewToFront:_passView];
        
    }];
}

//初始化过关
-(void)initPassView
{
    CGFloat _baduViewYPos = 0;
    CGRect nextBtnRect;
    CGRect againBtnRect;
    
    if(_advBuy)
    {
        _passView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        _passView.backgroundColor = [UIColor grayColor];
        _passView.layer.cornerRadius = 8;
        _passView.layer.masksToBounds = YES;
        _passView.center = self.view.center;
        [self.view addSubview:_passView];
        
        
        againBtnRect= CGRectMake(40, 50, 100, 100);
        nextBtnRect= CGRectMake(200, 50, 100, 100);
    }
    else
    {
        
        if( _iphoneType == IPHONE_4 )
        {
            _baduViewYPos = 20;
            againBtnRect= CGRectMake(40, 280, 80, 80);
            nextBtnRect= CGRectMake(200, 280, 80, 80);
            
        }
        else if( _iphoneType == IPHONE_5 )
        {
            _baduViewYPos = 40;
            againBtnRect= CGRectMake(40, 330, 100, 100);
            nextBtnRect= CGRectMake(190, 330, 100, 100);
        }
        else if( _iphoneType == IPHONE_6 )
        {
            _baduViewYPos = 40*(375.0/320);
            againBtnRect= CGRectMake(40*(375.0/320), 330, 100*(375.0/320), 100*(375.0/320));
            nextBtnRect= CGRectMake(190*(375.0/320), 330, 100*(375.0/320), 100*(375.0/320));
        }
        
        _passView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        _passView.backgroundColor = [UIColor grayColor];
        _passView.layer.cornerRadius = 8;
        _passView.layer.masksToBounds = YES;
        _passView.center = self.view.center;
        [self.view addSubview:_passView];
        
        //
        _baiduView = [[BaiduMobAdView alloc]init];
        _baiduView.AdType = BaiduMobAdViewTypeBanner;
        _baiduView.frame = CGRectMake(0, _baduViewYPos, kBaiduAdViewSquareBanner300x250.width, kBaiduAdViewSquareBanner300x250.height);
        
        if( _iphoneType == IPHONE_6P )
        {
            _baiduView.frame = CGRectMake(0, _baduViewYPos, kBaiduAdViewSquareBanner600x500.width, kBaiduAdViewSquareBanner600x500.height);
        }
        _baiduView.center = CGPointMake(screen_width/2, _baiduView.center.y);
        _baiduView.delegate = self;
        [_passView addSubview:_baiduView];
        [_baiduView start];
    }
    
    
    //
    UIButton * nextBtn = [[UIButton alloc]initWithFrame:nextBtnRect];
    [nextBtn setBackgroundImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextClicked) forControlEvents:UIControlEventTouchUpInside];
    [_passView addSubview:nextBtn];
    
    UIButton * againBtn = [[UIButton alloc]initWithFrame:againBtnRect];
    [againBtn setBackgroundImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    [againBtn addTarget:self action:@selector(againClicked) forControlEvents:UIControlEventTouchUpInside];
    [_passView addSubview:againBtn];
    
}

//重玩一次
-(void)againClicked
{
    [self hidePassView];
    
    [self reStartGame];
}

//下一关
-(void)nextClicked
{
    [self hidePassView];
    
    [self setCurPass];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^(void){
        
        sleep(0.5);
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
            [self reStartGame];
        });
        
    });
}

-(void)initGame
{
    int tag =0;
    
    [_InfoArray removeAllObjects];
    _InfoArray = nil;
    
    [_dataArray removeAllObjects];
    _dataArray = nil;
    
    [_spDataArray removeAllObjects];
    _spDataArray = nil;
    
    
    _InfoArray = [[NSMutableArray alloc]init];
    _dataArray = [[NSMutableArray alloc]init];
    _spDataArray = [[NSMutableArray alloc]init];
    
    NSMutableArray * animArray = [[NSMutableArray alloc]init];
    
    //
    NSString * strPass = nil;
    
    if( _iphoneType == IPHONE_4 )
    {
        strPass = [NSString stringWithFormat:@"4s_%@.txt",[self getCurPass]];
    }
    else if( _iphoneType == IPHONE_5 ||_iphoneType == IPHONE_6 || _iphoneType == IPHONE_6P )
    {
        strPass = [NSString stringWithFormat:@"5_%@.txt",[self getCurPass]];
    }

    
    NSString * filePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:strPass];
    NSString * strText = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSLog(@"strText:%@",strText);
    
    NSDictionary * dict = [strText objectFromJSONString];
    
    if( [dict isKindOfClass:[NSDictionary class]] )
    {
        NSArray * array = [dict objectForKey:@"data"];
        
        if( [array isKindOfClass:[NSArray class]] )
        {
            for( NSDictionary * subDict in array )
            {
                if( [subDict isKindOfClass:[NSDictionary class]] )
                {
                    
                    if( tag >= COLUMN_NUM*ROW_NUM)
                    {
                        break;
                    }
                    
                    NSString * value = [subDict objectForKey:@"value"];
                    NSString * repeatCount = [subDict objectForKey:@"repeatCount"];
                    NSString * repeatNum = [subDict objectForKey:@"repeatNum"];
                    
                    ImgViewInfo * info = [[ImgViewInfo alloc]init];
                    info.num = [value intValue];
                    
                    if( [value integerValue] !=  0 )//0 表示可移动项
                    {
                        info.touchAble = YES;
                        info.repeatCount = 0;
                        info.repeatNum = 0;
                    }
                    else
                    {
                        info.touchAble = NO;
                        info.repeatCount = [repeatCount intValue];
                        info.repeatNum = [repeatNum intValue];
                    }
            
                    info.imgTag = tag++;
                    
                    [_InfoArray addObject:info];
                    
                }
            }
        }
    }

    //
    
    for( int i = 0; i < ROW_NUM; ++ i)
    {
        for( int j = 0; j < COLUMN_NUM; ++ j )
        {
            ImgViewInfo * info = (ImgViewInfo *)[_InfoArray objectAtIndex:i*COLUMN_NUM+j];
            
            MyImageView * imgView = [[MyImageView alloc]initWithImgViewInfo:info];
            imgView.frame = CGRectMake(X_BEGIN_POS+j*IMG_WIDTH,Y_BEGIN_POS+i*IMG_WIDTH, IMG_WIDTH, IMG_WIDTH);
            imgView.tag = i*COLUMN_NUM + j+IMG_TAB_BEG;
            
           
            if( info.touchAble )
            {
                imgView.deletage = self;
                
                [self.view addSubview:imgView];
            }
            else
            {
                [self.view addSubview:imgView];
            }
            
            //
            if( (info.num != 0) || (info.repeatCount != 0) )
            {
                imgView.hidden = YES;
                [animArray addObject:[NSString stringWithFormat:@"%d",imgView.tag]];
            }
        }
    }
    
    //
    for( int i = 0; i < ROW_NUM; ++ i)
    {
        for( int j = 0; j < COLUMN_NUM; ++ j )
        {
            ImgViewInfo * info = (ImgViewInfo *)[_InfoArray objectAtIndex:i*COLUMN_NUM+j];
            
            MyImageView * imgView = (MyImageView *)[self.view viewWithTag:(i*COLUMN_NUM + j+IMG_TAB_BEG)];
            
            if( info.touchAble )
            {
                [self.view bringSubviewToFront:imgView];
            }
        }
    }
    
    //产生动画效果
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^(void){
        
        while([animArray count] )
        {
            [NSThread sleepForTimeInterval:0.2];
            
            int index = arc4random() % ([animArray count]);
            
            NSString * str = [animArray objectAtIndex:index];
            [animArray removeObjectAtIndex:index];
            int tag = [str intValue];
            
            MyImageView * view =(MyImageView *) [self.view viewWithTag:tag];
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                
                [UIView animateWithDuration:0.3 animations:^(void){
                    
                    view.hidden = NO;
                    CGPoint center = view.center;
                    //view.frame = CGRectMake(0, 0, IMG_WIDTH+10, IMG_WIDTH+10);
                    //view.center = center;
                    
                    view.frame = CGRectMake(view.frame.origin.x-5, view.frame.origin.y-5, IMG_WIDTH+10, IMG_WIDTH+10);
                    
                }completion:^(BOOL finish){
                    
                    [UIView animateWithDuration:0.2 animations:^(void){
                        
                        CGPoint center = view.center;
                        view.frame = CGRectMake(view.frame.origin.x+5, view.frame.origin.y+5, IMG_WIDTH, IMG_WIDTH);
                        //view.center = center;
                    }];
                }];
            });
        }
    });
}

//重新开始
-(void)btnClicked:(UIButton*)btn
{
    if( 0 == btn.tag )
    {
        AboutViewController * vc = [[AboutViewController alloc]initWithNibName:@"AboutViewController" bundle:nil];
        [self presentViewController:vc animated:YES completion:nil];
    }
    else if( 1 == btn.tag )
    {
        AppDelegate * appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        [appDel shareWithTextUrl];
    }
    else if( 2 == btn.tag )
    {
        [self showPassView];
        //[self againClicked];
    }
}


-(void)reStartGame
{
    for( UIView * subView in [self.view subviews] )
    {
        if( subView.tag >= IMG_TAB_BEG )
        {
            [subView removeFromSuperview];
        }
    }
    
    [self initGame];
}

-(void)layoutControllers
{
    CGRect rect;
    CGFloat xPox = 0;
    
    if( _iphoneType == IPHONE_6 )
    {
        xPox = 20;
    }
    else if( _iphoneType == IPHONE_6P )
    {
        xPox = 40;
    }
    //
    {
        rect = CGRectMake(xPox+15, 20, 90, 40);
        UIButton * btn = [[UIButton alloc]initWithFrame:rect];
        btn.tag = 0;
        [btn setTitle:@"关于我们" forState:UIControlStateNormal];
        btn.layer.cornerRadius = 5;
        btn.backgroundColor = [UIColor lightGrayColor];
        btn.layer.masksToBounds = YES;
        [self.view addSubview:btn];
        
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //
    {
        rect = CGRectMake(xPox+120, 20, 90, 40);
        UIButton * btn = [[UIButton alloc]initWithFrame:rect];
        btn.tag = 1;
        [btn setTitle:@"微信分享" forState:UIControlStateNormal];
        btn.layer.cornerRadius = 5;
        btn.backgroundColor = [UIColor lightGrayColor];
        btn.layer.masksToBounds = YES;
        [self.view addSubview:btn];
        
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    //
    {
        rect = CGRectMake(xPox+220, 20, 90, 40);
        UIButton * btn = [[UIButton alloc]initWithFrame:rect];
        btn.tag = 2;
        [btn setTitle:NSLocalizedString(@"playAgain", nil) forState:UIControlStateNormal];
        btn.layer.cornerRadius = 5;
        btn.backgroundColor = [UIColor lightGrayColor];
        btn.layer.masksToBounds = YES;
        [self.view addSubview:btn];
        
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)initScreenValue
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    screen_width = rect.size.width;
    screen_heigth = rect.size.height;
    
    if( screen_width == 320 && screen_heigth == 480 )
    {
        _iphoneType = IPHONE_4;
    }
    else if( screen_width == 320 && screen_heigth == 1136/2)
    {
        _iphoneType = IPHONE_5;
    }
    else if( screen_width == 750/2 )
    {
        _iphoneType = IPHONE_6;
    }
    else if( screen_width == 1242/3)
    {
        _iphoneType = IPHONE_6P;
    }

}

-(void)initPosValue
{
    if( _iphoneType == IPHONE_4 )
    {
        IMG_WIDTH = 60.0f;
        
        X_BEGIN_POS = 10;
        Y_BEGIN_POS = 70;
        
        ROW_NUM = 5;
        COLUMN_NUM = 5;
    }
    else if( _iphoneType == IPHONE_5 )
    {
        IMG_WIDTH = 60.0f;
        
        X_BEGIN_POS = 10;
        Y_BEGIN_POS = 70;
        
        ROW_NUM = 6;
        COLUMN_NUM = 5;
    }
    else if( _iphoneType == IPHONE_6 )
    {
        IMG_WIDTH = 70.0f;
        
        X_BEGIN_POS = 5;
        Y_BEGIN_POS = 70;
        
        ROW_NUM = 6;
        COLUMN_NUM = 5;
    }
    else if( _iphoneType == IPHONE_6P )
    {
        IMG_WIDTH = 77.0f;
        
        X_BEGIN_POS = 30;
        Y_BEGIN_POS = 70;
        
        ROW_NUM = 6;
        COLUMN_NUM = 5;
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initAdvBuyFlag];
    //
    [self initScreenValue];
    //
    [self initPosValue];
    //
    [self layoutControllers];
    //
    [self initGame];

    ///
    [self laytouADVView];
    //
    [self initPassView];
    
    //
    self.view.backgroundColor = [UIColor whiteColor];
}


-(void)MoveImageView:(MyImageView*)imgView withDir:(MOVE_ENUM)move
{
    {
        ImgViewInfo * moveInfo = [_InfoArray objectAtIndex:imgView.tag-IMG_TAB_BEG];
        int moveTag = imgView.tag-IMG_TAB_BEG;
        int moveRepeatNum = moveInfo.repeatNum;
        int moveRepeatCount = moveInfo.repeatCount;
        int moveSum = moveInfo.num;
        int row,column;
        
        row = moveTag / COLUMN_NUM;
        column = moveTag%COLUMN_NUM;
        
        //向右
        if( MOVE_RIGHT == move)
        {
            if( column < COLUMN_NUM - 1 )
            {
                ImgViewInfo * rightInfo = (ImgViewInfo *)[_InfoArray objectAtIndex:moveTag+1];
                MyImageView * rightImgView = (MyImageView *)[self.view viewWithTag:moveTag+1+IMG_TAB_BEG];
                //
                if( (!rightInfo.touchAble) && (rightInfo.repeatCount != 0 ))
                {
                    int repeatCount = rightInfo.repeatCount-1;
                    int repeatNum = rightInfo.repeatNum;
                    int ret = moveSum - repeatNum;
                    
                    //设置右边的图片
                    if( repeatCount == 0 )
                    {
                        rightImgView.image = [UIImage imageNamed:@"empty"];
                    }
                    else if( repeatCount == 1 )
                    {
                        rightImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"num_%d",repeatNum]];
                    }
                    else if( repeatCount == 2 )
                    {
                        
                    }
                    
                    //移动图片
                    CGPoint center = imgView.center;
                    imgView.center = CGPointMake(center.x+IMG_WIDTH, center.y);
                    
                    if( repeatCount == 0 && ret == 0 )
                    {
                        imgView.image = [UIImage imageNamed:@"success"];
                        imgView.bTouch = NO;
                        imgView.userInteractionEnabled = NO;
                    }
                    else
                    {
                        if( ret > 0 )
                        {
                            imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"move_%d",ret]];
                        }
                        else
                        {
                            imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"d_move_%d",abs(ret)]];
                        }
                    }
                    
                    imgView.tag = imgView.tag+1;
                    
                    //更新数据
                    moveInfo.num = 0;
                    [_InfoArray replaceObjectAtIndex:moveTag withObject:moveInfo];
                    
                    //
                    rightInfo.repeatCount = repeatCount;
                    rightInfo.num = ret;
                    
                    [_InfoArray replaceObjectAtIndex:moveTag+1 withObject:rightInfo];
                    
                }
            }
        }
        //向下
        else if( MOVE_DONW == move )
        {
            if( row < ROW_NUM - 1 )
            {
                ImgViewInfo * downInfo = (ImgViewInfo *)[_InfoArray objectAtIndex:moveTag+COLUMN_NUM];
                MyImageView * downImgView = (MyImageView *)[self.view viewWithTag:moveTag+COLUMN_NUM+IMG_TAB_BEG];
                //
                if( (!downInfo.touchAble) && (downInfo.repeatCount != 0 ))
                {
                    int repeatCount = downInfo.repeatCount-1;
                    int repeatNum = downInfo.repeatNum;
                    int ret = moveSum - repeatNum;
                    
                    //设置右边的图片
                    if( repeatCount == 0 )
                    {
                        downImgView.image = [UIImage imageNamed:@"empty"];
                    }
                    else if( repeatCount == 1 )
                    {
                        downImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"num_%d",repeatNum]];
                    }
                    else if( repeatCount == 2 )
                    {
                        
                    }
                    
                    //移动图片
                    CGPoint center = imgView.center;
                    imgView.center = CGPointMake(center.x, center.y+IMG_WIDTH);
                    if( repeatCount== 0 && ret == 0 )
                    {
                        imgView.image = [UIImage imageNamed:@"success"];
                        imgView.bTouch = NO;
                        imgView.userInteractionEnabled = NO;
                    }
                    else
                    {
                        if( ret > 0 )
                        {
                            imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"move_%d",ret]];
                        }
                        else
                        {
                            imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"d_move_%d",abs(ret)]];
                        }

                    }
                    imgView.tag = imgView.tag+COLUMN_NUM;
                    
                    //更新数据
                    moveInfo.num = 0;
                    [_InfoArray replaceObjectAtIndex:moveTag withObject:moveInfo];
                    
                    //
                    downInfo.repeatCount = repeatCount;
                    downInfo.num = ret;
                    
                    [_InfoArray replaceObjectAtIndex:moveTag+COLUMN_NUM withObject:downInfo];
                    
                }
            }
        }
        //向左
        else if( MOVE_LEFT == move)
        {
            if( column > 0 )
            {
                ImgViewInfo * leftInfo = (ImgViewInfo *)[_InfoArray objectAtIndex:moveTag-1];
                MyImageView * leftImgView = (MyImageView *)[self.view viewWithTag:moveTag-1+IMG_TAB_BEG];
                //
                if( (!leftInfo.touchAble) && (leftInfo.repeatCount != 0 ))
                {
                    int repeatCount = leftInfo.repeatCount-1;
                    int repeatNum = leftInfo.repeatNum;
                    int ret = moveSum - repeatNum;
                    
                    //设置右边的图片
                    if( repeatCount == 0 )
                    {
                        leftImgView.image = [UIImage imageNamed:@"empty"];
                     }
                    else if( repeatCount == 1 )
                    {
                        leftImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"num_%d",repeatNum]];
                    }
                    else if( repeatCount == 2 )
                    {
                        
                    }
                    
                    //移动图片
                    CGPoint center = imgView.center;
                    imgView.center = CGPointMake(center.x-IMG_WIDTH, center.y);
                    if( repeatCount== 0 && ret == 0 )
                    {
                        imgView.image = [UIImage imageNamed:@"success"];
                        imgView.bTouch = NO;
                        imgView.userInteractionEnabled = NO;
                    }
                    else
                    {
                        if( ret > 0 )
                        {
                            imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"move_%d",ret]];
                        }
                        else
                        {
                            imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"d_move_%d",abs(ret)]];
                        }

                    }
                    imgView.tag = imgView.tag-1;
                    
                    //更新数据
                    moveInfo.num = 0;
                    [_InfoArray replaceObjectAtIndex:moveTag withObject:moveInfo];
                    
                    //
                    leftInfo.repeatCount = repeatCount;
                    leftInfo.num = ret;
                    
                    [_InfoArray replaceObjectAtIndex:moveTag-1 withObject:leftInfo];
                }
            }
        }
        //向上
        else if( MOVE_UP == move )
        {
            if( row >0 )
            {
                ImgViewInfo * downInfo = (ImgViewInfo *)[_InfoArray objectAtIndex:moveTag-COLUMN_NUM];
                MyImageView * downImgView = (MyImageView *)[self.view viewWithTag:moveTag-COLUMN_NUM+IMG_TAB_BEG];
                //
                if( (!downInfo.touchAble) && (downInfo.repeatCount != 0 ))
                {
                    int repeatCount = downInfo.repeatCount-1;
                    int repeatNum = downInfo.repeatNum;
                    int ret = moveSum - repeatNum;
                    
                    //设置右边的图片
                    if( repeatCount == 0 )
                    {
                        downImgView.image = [UIImage imageNamed:@"empty"];
                    }
                    else if( repeatCount == 1 )
                    {
                        downImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"num_%d",repeatNum]];
                    }
                    else if( repeatCount == 2 )
                    {
                        
                    }
                    
                    //移动图片
                    CGPoint center = imgView.center;
                    imgView.center = CGPointMake(center.x, center.y-IMG_WIDTH);
                    if( repeatCount== 0 && ret == 0 )
                    {
                        imgView.image = [UIImage imageNamed:@"success"];
                        imgView.bTouch = NO;
                        imgView.userInteractionEnabled = NO;
                    }
                    else
                    {
                        if( ret > 0 )
                        {
                            imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"move_%d",ret]];
                        }
                        else
                        {
                            imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"d_move_%d",abs(ret)]];
                        }

                    }
                    imgView.tag = imgView.tag-COLUMN_NUM;
                    
                    //更新数据
                    moveInfo.num = 0;
                    [_InfoArray replaceObjectAtIndex:moveTag withObject:moveInfo];
                    
                    //
                    downInfo.repeatCount = repeatCount;
                    downInfo.num = ret;
                    
                    [_InfoArray replaceObjectAtIndex:moveTag-COLUMN_NUM withObject:downInfo];
                    
                }
            }
        }
    }
    
    
    for( int i = 0; i < [_InfoArray count]; ++ i )
    {
        ImgViewInfo * info = [_InfoArray objectAtIndex:i];
        NSLog(@"num:%d repeatCount:%d repeatNum:%d",info.num,info.repeatCount,info.repeatNum);
    }
    

    if( [self isGameSuccess] )
    {
        [self showPassView];
    }
    
}

-(void)clicked:(CGPoint)pt
{
    UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(0, 0) radius:50/2 -3 startAngle:0 endAngle:2*M_PI clockwise:YES];
    
    CAShapeLayer * layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    layer.fillColor = [[UIColor clearColor]CGColor];
    layer.strokeColor = [[UIColor orangeColor] CGColor];
    layer.lineCap = kCALineCapRound;
    layer.position = pt;
    layer.lineWidth = 3.0f;
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2.0, 2.0, 1)];
    scaleAnimation.removedOnCompletion = NO;
    scaleAnimation.fillMode = kCAFillModeForwards;
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue = @0;
    alphaAnimation.removedOnCompletion = NO;
    alphaAnimation.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup * group = [CAAnimationGroup animation];
    group.animations = @[scaleAnimation, alphaAnimation];
    group.duration = 1.0;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    group.delegate = self;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    
    [self.view.layer addSublayer:layer];
    
    [layer addAnimation:group forKey:@""];
}


- (NSString *)publisherId
{
    return @"bf498248";
}

/**
 *  应用在union.baidu.com上的APPID
 */
- (NSString*) appSpec
{
    return @"bf498248";
}


//底部广告
-(void)laytouADVView
{
    
    CGRect rect = [[UIScreen mainScreen]bounds];
    CGPoint pt ;

    if( _iphoneType == IPHONE_4 )
    {
        pt = CGPointMake(0, rect.origin.y+rect.size.height-kGADAdSizeLargeBanner.size.height-1);
        _bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLargeBanner origin:pt];
    }
    else if( _iphoneType == IPHONE_5 )
    {
        pt = CGPointMake(0, rect.origin.y+rect.size.height-kGADAdSizeLargeBanner.size.height-1);
        _bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLargeBanner origin:pt];
    }
    else if( _iphoneType == IPHONE_6 )
    {
        GADAdSize size = GADAdSizeFromCGSize(CGSizeMake(screen_width, 170));
        pt = CGPointMake(0, rect.origin.y+rect.size.height-size.size.height-1);
        _bannerView = [[GADBannerView alloc] initWithAdSize:size origin:pt];

    }
    else if( _iphoneType == IPHONE_6P )
    {
        GADAdSize size = GADAdSizeFromCGSize(CGSizeMake(screen_width, 120));
        pt = CGPointMake(0, rect.origin.y+rect.size.height-size.size.height-1);
        _bannerView = [[GADBannerView alloc] initWithAdSize:size origin:pt];
    }

    _bannerView.adUnitID = ADMOB_ID;//调用你的id
    _bannerView.rootViewController = self;
    [_bannerView loadRequest:[GADRequest request]];
    
    [self.view addSubview:_bannerView];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
