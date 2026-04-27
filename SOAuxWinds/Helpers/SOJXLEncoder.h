//Created by Salty on 4/24/26.

@import libjxl;

#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>

@interface SOJXLEncoder : NSObject
///Encodes a non-JXL compressed image to a lossless-compressed JXL image with input data of Image IO framework
///supported formats. Input data  is internally copied to a CGImage prior to compression.
+ (NSData *)encodeImageDataToJXL:(NSData *)inputData error:(NSError **)error;
@end
