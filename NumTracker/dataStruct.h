#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef enum
{
    MOVE_LEFT,
    MOVE_RIGHT,
    MOVE_UP,
    MOVE_DONW
    
}MOVE_ENUM;



#define IMG_WIDTH  45.0f


#define ROW_NUM   6
#define COLUMN_NUM  6

#define X_BEGIN_POS   20.0f
#define Y_BEGIN_POS   40.0f

//////////////////////////////////////////////////////////////////
@interface ImgViewInfo : NSObject

@property(strong) NSString * num;
@property(strong) UIImage * image;
@property(assign)   int tag;
@property(assign)   BOOL touchAble;

-(void)fromDict:(NSDictionary*)dict;

@end




//////////////////////////////////////////////////////////////////

