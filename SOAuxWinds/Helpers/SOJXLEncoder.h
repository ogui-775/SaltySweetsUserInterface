//Created by Salty on 4/24/26.

@import libjxl;

#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>

@interface SOJXLEncoder : NSObject
+ (NSData *)encodeImageDataToJXL:(NSData *)inputData error:(NSError **)error;
@end
