#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>




typedef enum
{
    MOVE_LEFT,
    MOVE_RIGHT,
    MOVE_UP,
    MOVE_DONW
    
}MOVE_ENUM;

#define ADMOB_ID  @"ca-app-pub-3058205099381432/8591538347"

#define IMG_WIDTH  60.0f

#define ADV_BUY_KEY  @"adv_buy"

#define INVALIDE_NUM    -999
#define IMG_TAB_BEG   10086

//////////////////////////////////////////////////////////////////
@interface ImgViewInfo : NSObject

@property(assign)   int num;//数字
@property(assign)   int imgTag;
@property(assign)   BOOL touchAble;//是否可以移动
@property(assign)   int repeatCount;// 重复的次数 1表示一次消除   2表示2次消除
@property(assign)   int repeatNum;//重复的数字

-(void)fromDict:(NSDictionary*)dict;

@end




//////////////////////////////////////////////////////////////////

