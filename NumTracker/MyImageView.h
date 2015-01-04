//
//  MyImageView.h
//  NumTracker
//
//  Created by zhuang chaoxiao on 14-12-30.
//  Copyright (c) 2014年 zhuang chaoxiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "dataStruct.h"


@protocol MyImageViewDelegate <NSObject>

@optional

-(void)MoveImageView:(UIImageView*)imgView withDir:(MOVE_ENUM)move;

@end

@interface MyImageView : UIImageView
{
    
}

@property(nonatomic,weak) id deletage;

//
-(id)initWithImgViewInfo:(ImgViewInfo*)info;

@end
