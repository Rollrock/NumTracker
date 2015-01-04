//
//  MyImageView.m
//  NumTracker
//
//  Created by zhuang chaoxiao on 14-12-30.
//  Copyright (c) 2014年 zhuang chaoxiao. All rights reserved.
//

#import "MyImageView.h"
#import "dataStruct.h"

@interface MyImageView()
{
    CGPoint _beganPT;
    CGPoint _center;
}
@end

@implementation MyImageView

-(id)initWithImgViewInfo:(ImgViewInfo*)info
{
    self = [super init];
    
    if( self )
    {
        if( info.image )
        {
            self.image = info.image;
        }
        
        if( info.touchAble )
        {
            self.userInteractionEnabled = YES;
        }
    }
    
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[touches anyObject] locationInView:self.superview];
    
    _beganPT = pt;
    _center = self.center;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    CGPoint pt = [[touches anyObject]locationInView:self.superview];
    
    CGFloat x = abs(_beganPT.x - pt.x);
    CGFloat y = abs(_beganPT.y - pt.y);
    
    //右
    if( (x > y) && (x>IMG_WIDTH) && (_beganPT.x-pt.x<0))
    {
        if( [_deletage respondsToSelector:@selector(MoveImageView:withDir:)])
        {
            [_deletage MoveImageView:self withDir:MOVE_RIGHT];
            
            _beganPT = CGPointMake(_beganPT.x+IMG_WIDTH, _beganPT.y);
        }
    }
    //下
    else if( (y > x) && (y > IMG_WIDTH)&&(_beganPT.y-pt.y<0))
    {
        if( [_deletage respondsToSelector:@selector(MoveImageView:withDir:)])
        {
            [_deletage MoveImageView:self withDir:MOVE_DONW];
            
            _beganPT = CGPointMake(_beganPT.x, _beganPT.y+IMG_WIDTH);
        }
    }
    //左边
    else if( (x > y) && (x>IMG_WIDTH) && (_beganPT.x-pt.x>0))
    {
        if( [_deletage respondsToSelector:@selector(MoveImageView:withDir:)])
        {
            [_deletage MoveImageView:self withDir:MOVE_LEFT];
            
            _beganPT = CGPointMake(_beganPT.x-IMG_WIDTH, _beganPT.y);
        }
    }
    //上
    else if( (y > x) && (y > IMG_WIDTH)&&(_beganPT.y-pt.y>0))
    {
        if( [_deletage respondsToSelector:@selector(MoveImageView:withDir:)])
        {
            [_deletage MoveImageView:self withDir:MOVE_UP];
            
            _beganPT = CGPointMake(_beganPT.x, _beganPT.y-IMG_WIDTH);
        }
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

@end





















