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


/*
 -999 表示空 也就是没有
 1000 以上的 表示移动的目标
 1-9  表示不移动的普通目标
 500 以上的 表示可变的目标
 */


#define IMG_TAB_BEG   10086

#define PASS_STORE_KEY  @"pass_store"

@interface ViewController ()<MyImageViewDelegate>
{
    NSMutableArray * _InfoArray;
    
    NSMutableArray * _dataArray;
    NSMutableArray * _spDataArray;
    //NSMutableArray * _backUpArray;
    //NSMutableArray * _backUpSpArray;
    
    GADBannerView * _bannerView;
    
    int ROW_NUM;
    int COLUMN_NUM;
    
    CGFloat X_BEGIN_POS;
    CGFloat Y_BEGIN_POS;
    
    CGFloat screen_width;
    CGFloat screen_heigth;
}

@end

@implementation ViewController


-(NSString*)getCurPass
{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    
    NSInteger val = [def integerForKey:PASS_STORE_KEY];
    
    return [NSString stringWithFormat:@"%d",val];
}

-(BOOL)isGameSuccess
{
    for( int i = 0; i < [_dataArray count]; ++ i )
    {
        NSString * str = [_dataArray objectAtIndex:i];
        
        if( ![str isEqualToString:@"-999"] )
        {
            return NO;
        }
    }
    
    return YES;
}

-(void)initGame
{
    
    [_InfoArray removeAllObjects];
    _InfoArray = nil;
    
    [_dataArray removeAllObjects];
    _dataArray = nil;
    
    [_spDataArray removeAllObjects];
    _spDataArray = nil;
    
   // [_backUpArray removeAllObjects];
    //_backUpArray = nil;
    
    //[_backUpSpArray removeAllObjects];
    //_backUpSpArray = nil;

    
    
    _InfoArray = [[NSMutableArray alloc]init];
    _dataArray = [[NSMutableArray alloc]init];
    //_backUpArray = [[NSMutableArray alloc]init];
    _spDataArray = [[NSMutableArray alloc]init];
   // _backUpSpArray = [[NSMutableArray alloc]init];
    
    //
    NSString * strPass = nil;
    if( screen_width == 320 && screen_heigth == 480 )
    {
        strPass = [NSString stringWithFormat:@"4s_%@.txt",[self getCurPass]];
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
                    NSString * str = [subDict objectForKey:@"value"];
                    
                    [_dataArray addObject:str];
                    
                    
                    //
                    //[_backUpArray addObject:str];
                    
                    
                    if( [str intValue] > 500 && [str intValue] < 1000)
                    {
                        [_spDataArray addObject:[NSString stringWithFormat:@"%d",[str intValue]-500]];
                        //[_backUpSpArray addObject:[NSString stringWithFormat:@"%d",[str intValue]-500]];
                    }
                    else
                    {
                        [_spDataArray addObject:@"-999"];
                        //[_backUpSpArray addObject:@"-999"];
                    }
                }
            }
        }
    }

        
    for( int i = 0; i < ROW_NUM; ++ i )
    {
        for( int j = 0; j < COLUMN_NUM; ++ j )
        {
            ImgViewInfo * info = [[ImgViewInfo alloc]init];
            info.num = [_dataArray objectAtIndex:i*COLUMN_NUM + j];
            
            int value = [info.num intValue];
            
            if( value == -999 )
            {
                info.image = nil;
                info.touchAble = NO;
            }
            else if( value >= 0 && value <= 9 )
            {
                info.image = [UIImage imageNamed:[NSString stringWithFormat:@"num_%d",value]];
                info.touchAble = NO;
            }
            else if( value >= 1000 )
            {
                info.image = [UIImage imageNamed:[NSString stringWithFormat:@"move_%d",value-1000]];
                info.touchAble = YES;
            }
            else if( value >= 500  && value < 1000)
            {
                info.image = [UIImage imageNamed:[NSString stringWithFormat:@"j_num_%d",value-500]];
                info.touchAble = NO;
            }
            
            [_InfoArray addObject:info];
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
            
            NSLog(@"tag:%d",imgView.tag);
            
            
            if( info.touchAble )
            {
                imgView.deletage = self;
                
                [self.view addSubview:imgView];
                
            }
            else
            {
                [self.view addSubview:imgView];
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

}

-(void)btnClicked:(UIButton*)btn
{
    if( 0 == btn.tag )
    {
        AboutViewController * vc = [[AboutViewController alloc]init];
        [self presentViewController:vc animated:YES completion:nil];
    }
    else if( 1 == btn.tag )
    {
        AppDelegate * appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        [appDel shareWithTextUrl];
    }
    else if( 2 == btn.tag )
    {
        [self reStartGame];
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
    
    //
    {
        rect = CGRectMake(15, 20, 90, 40);
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
        rect = CGRectMake(120, 20, 90, 40);
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
        rect = CGRectMake(220, 20, 90, 40);
        UIButton * btn = [[UIButton alloc]initWithFrame:rect];
        btn.tag = 2;
        [btn setTitle:@"重新开始" forState:UIControlStateNormal];
        btn.layer.cornerRadius = 5;
        btn.backgroundColor = [UIColor lightGrayColor];
        btn.layer.masksToBounds = YES;
        [self.view addSubview:btn];
        
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    {
        CGRect rect = [[UIScreen mainScreen] bounds];
        screen_width = rect.size.width;
        screen_heigth = rect.size.height;
        
        if( screen_width == 320 )
        {
            // iphone4
            if( screen_heigth == 480 )
            {
                X_BEGIN_POS = 10;
                Y_BEGIN_POS = 70;
                
                ROW_NUM = 5;
                COLUMN_NUM = 5;
            }
            // iphone5
            else
            {
                X_BEGIN_POS = 10;
                Y_BEGIN_POS = 70;
                
                ROW_NUM = 6;
                COLUMN_NUM = 5;
            }
        }
        //  6
        else if( screen_width == 750/2)
        {
            X_BEGIN_POS = 5;
            Y_BEGIN_POS = 70;
            
            ROW_NUM = 7;
            COLUMN_NUM = 6;
        }
        // 6p
        else if( screen_width == 1 )
        {
            
        }
    }
    
    //
    [self layoutControllers];
    //
    [self initGame];
    
    ///
    ///
    [self laytouADVView];
    //
    
    self.view.backgroundColor = [UIColor whiteColor];
}


-(void)MoveImageView:(MyImageView*)imgView withDir:(MOVE_ENUM)move
{
    int tag = imgView.tag-IMG_TAB_BEG;
    int sum = [[_dataArray objectAtIndex:tag] intValue]-1000;
    int row,column;
    
    row = tag/COLUMN_NUM;
    column = tag%COLUMN_NUM;
    
    NSLog(@"row:%d column:%d tag:%d",row,column,tag);
    
    //往右
    if( MOVE_RIGHT == move)
    {
        if( column < COLUMN_NUM - 1 )
        {
            int num = [[_dataArray objectAtIndex:tag+1]intValue];
            
            if( (num >= 1 && num <= 9) || (num>= 500 && num <= 600))
            {
                if( num >= 1 && num <= 9 )
                {
                    sum -= num;
                    ((UIImageView*)[self.view viewWithTag:tag+1+IMG_TAB_BEG]).image = [UIImage imageNamed:@"empty"];
                }
                else if( num >= 500 && num < 600 )
                {
                    sum -= num-500;
                    ((UIImageView*)[self.view viewWithTag:tag+1+IMG_TAB_BEG]).image = [UIImage imageNamed:[NSString stringWithFormat:@"num_%d",num-500]];
                }
                
                NSLog(@"sun:%d",sum);
                
                CGPoint pt = imgView.center;
                imgView.center = CGPointMake(pt.x+IMG_WIDTH, pt.y);
                imgView.tag = tag+1+IMG_TAB_BEG;
                
                [_dataArray replaceObjectAtIndex:tag withObject:@"-999"];
                [_dataArray replaceObjectAtIndex:tag+1 withObject:[NSString stringWithFormat:@"%d",sum+1000]];
                
                int sp = [[_spDataArray objectAtIndex:tag] intValue];
                if( sp > 0 )
                {
                    [_dataArray replaceObjectAtIndex:tag withObject:[NSString stringWithFormat:@"%d",sp]];
                    [_spDataArray replaceObjectAtIndex:tag withObject:@"-999"];
                }
                
                if( sum > 0 )
                {
                    imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"move_%d",sum]];
                }
                else if( sum == 0 )
                {
                    if( num >= 1 && num <= 9 )
                    {
                        [_dataArray replaceObjectAtIndex:tag+1 withObject:[NSString stringWithFormat:@"%d",-999]];
                        imgView.image = [UIImage imageNamed:@"success"];
                        imgView.userInteractionEnabled = NO;
                        
                        imgView.bTouch = NO;
                    }
                    
                }
                else
                {
                    imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"d_move_%d",abs(sum)]];
                }
                
                
                [self clicked:imgView.center];
            }
        }
    }
    else if( MOVE_DONW == move )
    {
        if( row < ROW_NUM - 1 )
        {
            int num = [[_dataArray objectAtIndex:tag+COLUMN_NUM]intValue];
            
            if( (num >= 1 && num <= 9 )||(num>= 500 && num <= 600))
            {
                if( num >= 1 && num <= 9)
                {
                    sum -= num;
                    ((UIImageView*)[self.view viewWithTag:tag+COLUMN_NUM+IMG_TAB_BEG]).image = [UIImage imageNamed:@"empty"];
                }
                else if(num>= 500 && num <= 600)
                {
                    sum -= num-500;
                    ((UIImageView*)[self.view viewWithTag:tag+COLUMN_NUM+IMG_TAB_BEG]).image = [UIImage imageNamed:[NSString stringWithFormat:@"num_%d",num-500]];
                }
                
                NSLog(@"sun:%d",sum);
                
                CGPoint pt = imgView.center;
                imgView.center = CGPointMake(pt.x, pt.y+IMG_WIDTH);
                imgView.tag = tag+COLUMN_NUM+IMG_TAB_BEG;
                
                
                [_dataArray replaceObjectAtIndex:tag withObject:@"-999"];
                [_dataArray replaceObjectAtIndex:tag+COLUMN_NUM withObject:[NSString stringWithFormat:@"%d",sum+1000]];
                
                int sp = [[_spDataArray objectAtIndex:tag] intValue];
                if( sp > 0 )
                {
                    [_dataArray replaceObjectAtIndex:tag withObject:[NSString stringWithFormat:@"%d",sp]];
                    [_spDataArray replaceObjectAtIndex:tag withObject:@"-999"];
                }
                
                if( sum > 0 )
                {
                    imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"move_%d",sum]];
                }
                else if( sum == 0 )
                {
                    if( num >= 1 && num <= 9 )
                    {
                        [_dataArray replaceObjectAtIndex:tag+COLUMN_NUM withObject:[NSString stringWithFormat:@"%d",-999]];
                        imgView.image = [UIImage imageNamed:@"success"];
                        imgView.userInteractionEnabled = NO;
                        
                        imgView.bTouch = NO;
                    }
                    
                }
                else
                {
                    imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"d_move_%d",abs(sum)]];
                }

                
                [self clicked:imgView.center];
            }
        }
    }
    //向左
    else if( MOVE_LEFT == move)
    {
        if( column > 0 )
        {
            int num = [[_dataArray objectAtIndex:tag-1]intValue];
            
            //
            
            if((num >= 1 && num <= 9 ) || ( num >= 500 && num <= 600))
            {
                if(num >= 1 && num <= 9 )
                {
                     sum -= num;
                    ((UIImageView*)[self.view viewWithTag:tag-1+IMG_TAB_BEG]).image = [UIImage imageNamed:@"empty"];

                }
                else if( num >= 500 && num <= 600)
                {
                    sum -= num-500;
                    ((UIImageView*)[self.view viewWithTag:tag-1+IMG_TAB_BEG]).image = [UIImage imageNamed:[NSString stringWithFormat:@"num_%d",num-500]];
                }
                
               
                NSLog(@"sun:%d",sum);
                
                CGPoint pt = imgView.center;
                imgView.center = CGPointMake(pt.x-IMG_WIDTH, pt.y);
                imgView.tag = tag-1+IMG_TAB_BEG;
                
                [_dataArray replaceObjectAtIndex:tag withObject:@"-999"];
                [_dataArray replaceObjectAtIndex:tag-1 withObject:[NSString stringWithFormat:@"%d",sum+1000]];
                
                
                int sp = [[_spDataArray objectAtIndex:tag] intValue];
                if( sp > 0 )
                {
                    [_dataArray replaceObjectAtIndex:tag withObject:[NSString stringWithFormat:@"%d",sp]];
                    [_spDataArray replaceObjectAtIndex:tag withObject:@"-999"];
                }
                
                if( sum > 0 )
                {
                    imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"move_%d",sum]];
                }
                else if( sum == 0 )
                {
                    if(num >= 1 && num <= 9)
                    {
                        [_dataArray replaceObjectAtIndex:tag-1 withObject:[NSString stringWithFormat:@"%d",-999]];
                        imgView.image = [UIImage imageNamed:@"success"];
                        imgView.userInteractionEnabled = NO;
                        
                        imgView.bTouch = NO;
                    }
                }
                else
                {
                    imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"d_move_%d",abs(sum)]];
                }
                
                [self clicked:imgView.center];
            }
        }
    }
    else if( MOVE_UP == move )
    {
        if( row >0 )
        {
            int num = [[_dataArray objectAtIndex:tag-COLUMN_NUM]intValue];
            
            if( (num >= 1 && num <= 9) || (num >= 500 && num <= 600))
            {
                if(num >= 1 && num <= 9)
                {
                    sum -= num;
                    ((UIImageView*)[self.view viewWithTag:tag-COLUMN_NUM+IMG_TAB_BEG]).image = [UIImage imageNamed:@"empty"];
                }
                else if(num >= 500 && num <= 600)
                {
                    sum -= num-500;
                    ((UIImageView*)[self.view viewWithTag:tag-COLUMN_NUM+IMG_TAB_BEG]).image = [UIImage imageNamed:[NSString stringWithFormat:@"num_%d",num-500]];
                }
                
                NSLog(@"sun:%d",sum);
                
                CGPoint pt = imgView.center;
                imgView.center = CGPointMake(pt.x, pt.y-IMG_WIDTH);
                imgView.tag = tag-COLUMN_NUM+IMG_TAB_BEG;
                
                [_dataArray replaceObjectAtIndex:tag withObject:@"-999"];
                [_dataArray replaceObjectAtIndex:tag-COLUMN_NUM withObject:[NSString stringWithFormat:@"%d",sum+1000]];
                
                int sp = [[_spDataArray objectAtIndex:tag] intValue];
                if( sp > 0 )
                {
                    [_dataArray replaceObjectAtIndex:tag withObject:[NSString stringWithFormat:@"%d",sp]];
                    [_spDataArray replaceObjectAtIndex:tag withObject:@"-999"];
                }

                if( sum > 0 )
                {
                    imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"move_%d",sum]];
                }
                else if( sum == 0 )
                {
                    if( num >= 1 && num <= 9 )
                    {
                        [_dataArray replaceObjectAtIndex:tag-COLUMN_NUM withObject:[NSString stringWithFormat:@"%d",-999]];
                        imgView.image = [UIImage imageNamed:@"success"];
                        imgView.userInteractionEnabled = NO;
                        
                        imgView.bTouch = NO;
                    }
                    
                }
                else
                {
                    imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"d_move_%d",abs(sum)]];
                }

                [self clicked:imgView.center];
            }
        }
    }
    
    [self isGameSuccess];
}

-(void)clicked:(CGPoint)pt
{
    UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(0, 0) radius:50/2 -3 startAngle:0 endAngle:2*M_PI clockwise:YES];
    
    CAShapeLayer * layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    layer.fillColor = [[UIColor clearColor]CGColor];
    layer.strokeColor = [[UIColor orangeColor] CGColor];
    layer.lineCap = kCALineCapRound;
    layer.position = pt;//CGPointMake(125, 225);
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


-(void)laytouADVView
{
    CGRect rect = [[UIScreen mainScreen]bounds];
    CGPoint pt ;
    
    
    
    
    
    /*
    
    if( screen_width == 320 && screen_heigth == 480 )
    {
        pt = CGPointMake(0, rect.origin.y+rect.size.height-kGADAdSizeLargeBanner.size.height-1);
        _bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLargeBanner origin:pt];
    }
    else if( screen_width == 320 && screen_heigth == 1136/2)
    {
        pt = CGPointMake(0, rect.origin.y+rect.size.height-kGADAdSizeLargeBanner.size.height-1);
        _bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLargeBanner origin:pt];
    }
    else if( screen_width == 750/2 && screen_heigth == 1334/2 )
    {
        pt = CGPointMake(0, rect.origin.y+rect.size.height-kGADAdSizeLargeBanner.size.height-1);
        _bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLargeBanner origin:pt];
    }

    _bannerView.adUnitID = ADMOB_ID;//调用你的id
    
    _bannerView.rootViewController = self;
    
    [_bannerView loadRequest:[GADRequest request]];
    
    
    if( rect.size.height >= 568 )
    {
        pt = _bannerView.center;
        _bannerView.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, pt.y);
    }
    
    [self.view addSubview:_bannerView];
    */
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
