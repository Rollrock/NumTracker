#import "dataStruct.h"

#define SetSTR(dict,keypath,property) do \
{ \
	NSString* src = [dict valueForKeyPath:keypath]; \
    if([src isKindOfClass:NSString.class]) { \
	self.property = (src)?src:@""; \
	} else { \
	self.property = @""; \
    }\
} while (0);

#define SETSTRFORDICT(dict, key, property) do \
{ \
	NSString* temp = self.property;\
	if(temp)\
	{\
		[dict setObject:temp forKey:key];\
	}\
	else\
	{\
		[dict setObject:@"" forKey:key];\
	}\
} while (0);


//////////////////////////////////////////////////////////////////////////////
@implementation ImgViewInfo


-(void)fromDict:(NSDictionary *)dict
{

}

@end

//////////////////////////////////////////////////////////////////////////////

