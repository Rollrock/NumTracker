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

@interface ViewController ()<MyImageViewDelegate>
{
    NSMutableArray * _InfoArray;
    NSMutableArray * _dataArray;
}

@end

@implementation ViewController


-(void)initTestData
{
    _InfoArray = [[NSMutableArray alloc]init];
    _dataArray = [[NSMutableArray alloc]init];
    
    //
    
    NSString * filePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"data.txt"];
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
            
            [_InfoArray addObject:info];
        }
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initTestData];
    
    ///
    
    for( int i = 0; i < ROW_NUM; ++ i)
    {
        for( int j = 0; j < COLUMN_NUM; ++ j )
        {
            ImgViewInfo * info = (ImgViewInfo *)[_InfoArray objectAtIndex:i*COLUMN_NUM+j];
            
            MyImageView * imgView = [[MyImageView alloc]initWithImgViewInfo:info];
            imgView.frame = CGRectMake(X_BEGIN_POS+j*IMG_WIDTH,Y_BEGIN_POS+i*IMG_WIDTH, IMG_WIDTH, IMG_WIDTH);
            imgView.tag = i*COLUMN_NUM + j;
            
            
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
            
            MyImageView * imgView = (MyImageView *)[self.view viewWithTag:(i*COLUMN_NUM + j)];
            
            
            if( info.touchAble )
            {
                [self.view bringSubviewToFront:imgView];
            }
        }
    }

    
    ///
    
    self.view.backgroundColor = [UIColor whiteColor];
}


-(void)MoveImageView:(UIImageView*)imgView withDir:(MOVE_ENUM)move
{
    NSLog(@"MoveImageView");
    
    int tag = imgView.tag;
    int sum = [[_dataArray objectAtIndex:tag] intValue]-1000;
    int row,column;
    
    row = tag/COLUMN_NUM;
    column = tag%COLUMN_NUM;
    
    NSLog(@"row:%d column:%d==tag:%d",row,column,tag);
    
    //往右
    if( MOVE_RIGHT == move)
    {
        if( column < COLUMN_NUM - 1 )
        {
            int num = [[_dataArray objectAtIndex:tag+1]intValue];
            
            if( num >= 1 && num <= 9 )
            {
                sum -= num;
                NSLog(@"sun:%d",sum);
                
                //[[self.view viewWithTag:tag+1] removeFromSuperview];
                
                ((UIImageView*)[self.view viewWithTag:tag+1]).image = [UIImage imageNamed:@"empty"];
                
                CGPoint pt = imgView.center;
                imgView.center = CGPointMake(pt.x+IMG_WIDTH, pt.y);
                imgView.tag = tag+1;
                imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"move_%d",sum]];
                
                [_dataArray replaceObjectAtIndex:tag withObject:@"-999"];
                [_dataArray replaceObjectAtIndex:tag+1 withObject:[NSString stringWithFormat:@"%d",sum+1000]];
                
                [self clicked:imgView.center];
            }
        }
    }
    else if( MOVE_DONW == move )
    {
        if( row < ROW_NUM - 1 )
        {
            int num = [[_dataArray objectAtIndex:tag+COLUMN_NUM]intValue];
            
            if( num >= 1 && num <= 9 )
            {
                sum -= num;
                NSLog(@"sun:%d",sum);
                
                //[[self.view viewWithTag:tag+COLUMN_NUM] removeFromSuperview];
                
                ((UIImageView*)[self.view viewWithTag:tag+COLUMN_NUM]).image = [UIImage imageNamed:@"empty"];
                
                CGPoint pt = imgView.center;
                imgView.center = CGPointMake(pt.x, pt.y+IMG_WIDTH);
                imgView.tag = tag+COLUMN_NUM;
                imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"move_%d",sum]];
                
                [_dataArray replaceObjectAtIndex:tag withObject:@"-999"];
                [_dataArray replaceObjectAtIndex:tag+COLUMN_NUM withObject:[NSString stringWithFormat:@"%d",sum+1000]];
                
                [self clicked:imgView.center];
            }
        }
    }
    else if( MOVE_LEFT == move)
    {
        if( column > 0 )
        {
            int num = [[_dataArray objectAtIndex:tag-1]intValue];
            
            if( num >= 1 && num <= 9 )
            {
                sum -= num;
                NSLog(@"sun:%d",sum);
                
                //[[self.view viewWithTag:tag-1] removeFromSuperview];
                
                ((UIImageView*)[self.view viewWithTag:tag-1]).image = [UIImage imageNamed:@"empty"];
                
                CGPoint pt = imgView.center;
                imgView.center = CGPointMake(pt.x-IMG_WIDTH, pt.y);
                imgView.tag = tag-1;
                imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"move_%d",sum]];
                
                [_dataArray replaceObjectAtIndex:tag withObject:@"-999"];
                [_dataArray replaceObjectAtIndex:tag-1 withObject:[NSString stringWithFormat:@"%d",sum+1000]];
                
                [self clicked:imgView.center];
            }
        }
    }
    else if( MOVE_UP == move )
    {
        if( row >0 )
        {
            int num = [[_dataArray objectAtIndex:tag-COLUMN_NUM]intValue];
            
            if( num >= 1 && num <= 9 )
            {
                sum -= num;
                NSLog(@"sun:%d",sum);
                
                //[[self.view viewWithTag:tag-COLUMN_NUM] removeFromSuperview];
                
                ((UIImageView*)[self.view viewWithTag:tag-COLUMN_NUM]).image = [UIImage imageNamed:@"empty"];
                
                CGPoint pt = imgView.center;
                imgView.center = CGPointMake(pt.x, pt.y-IMG_WIDTH);
                imgView.tag = tag-COLUMN_NUM;
                imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"move_%d",sum]];
                
                [_dataArray replaceObjectAtIndex:tag withObject:@"-999"];
                [_dataArray replaceObjectAtIndex:tag-COLUMN_NUM withObject:[NSString stringWithFormat:@"%d",sum+1000]];
                
                [self clicked:imgView.center];
            }
        }
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
    layer.position = pt;//CGPointMake(125, 225);
    layer.lineWidth = 3.0f;
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2.5, 2.5, 1)];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
