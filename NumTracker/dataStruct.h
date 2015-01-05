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


/*
#define ROW_NUM   6
#define COLUMN_NUM  5

#define X_BEGIN_POS   0.0f
#define Y_BEGIN_POS   40.0f
*/
//////////////////////////////////////////////////////////////////
@interface ImgViewInfo : NSObject

@property(strong) NSString * num;
@property(strong) UIImage * image;
@property(assign)   int tag;
@property(assign)   BOOL touchAble;

-(void)fromDict:(NSDictionary*)dict;

@end




//////////////////////////////////////////////////////////////////

