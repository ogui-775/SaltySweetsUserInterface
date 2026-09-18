//Created by Salty on 4/24/26.

#import "SOJXLEncoder.h"

@implementation SOJXLEncoder

+ (NSData *)encodeImageDataToJXL:(NSData *)inputData error:(NSError **)error {
    if (!inputData) return nil;

    CGImageSourceRef src = CGImageSourceCreateWithData((__bridge CFDataRef)inputData, NULL);
    if (!src) {
        if (error) *error = [NSError errorWithDomain:@"SOJXLEncoder"
                                                code:1
                                            userInfo:@{NSLocalizedDescriptionKey: @"Failed to create image source"}];
        return nil;
    }
    
    CGImageRef cgImage = CGImageSourceCreateImageAtIndex(src, 0, NULL);
    CFRelease(src);
    
    if (!cgImage) {
        if (error) *error = [NSError errorWithDomain:@"SOJXLEncoder"
                                                code:2
                                            userInfo:@{NSLocalizedDescriptionKey: @"Failed to decode image"}];
        return nil;
    }
    
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);

    size_t bytesPerPixel = 4;
    size_t bytesPerRow = width * bytesPerPixel;
    size_t bufferSize  = height * bytesPerRow;

    uint8_t *pixels = malloc(bufferSize);
    memset(pixels, 0, bufferSize);

    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();

    CGContextRef ctx = CGBitmapContextCreate(
        pixels,
        width,
        height,
        8,
        bytesPerRow,
        cs,
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
        kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big
#pragma cland diagnostic pop
    );

    CGColorSpaceRelease(cs);

    CGContextDrawImage(ctx, CGRectMake(0, 0, width, height), cgImage);
    CGContextRelease(ctx);
    CGImageRelease(cgImage);
    
    JxlEncoder *encoder = JxlEncoderCreate(NULL);
    if (!encoder) {
        free(pixels);
        return nil;
    }
    
    JxlEncoderFrameSettings *frameSettings =
        JxlEncoderFrameSettingsCreate(encoder, NULL);
    
    JxlEncoderFrameSettingsSetOption(frameSettings,
        JXL_ENC_FRAME_SETTING_EFFORT, 7);
    
    JxlEncoderSetFrameLossless(frameSettings, JXL_TRUE);
    
    JxlPixelFormat pixelFormat = {
        .num_channels = 4,
        .data_type = JXL_TYPE_UINT8,
        .endianness = JXL_NATIVE_ENDIAN,
        .align = 0
    };

    JxlBasicInfo basicInfo;
    JxlEncoderInitBasicInfo(&basicInfo);

    basicInfo.xsize = (uint32_t)width;
    basicInfo.ysize = (uint32_t)height;

    basicInfo.num_color_channels = 3;
    basicInfo.num_extra_channels = 1;
    basicInfo.alpha_bits = 8;

    basicInfo.bits_per_sample = 8;
    basicInfo.exponent_bits_per_sample = 0;

    basicInfo.alpha_premultiplied = JXL_TRUE;
    basicInfo.uses_original_profile = JXL_TRUE;
    
    if (JxlEncoderSetBasicInfo(encoder, &basicInfo) != JXL_ENC_SUCCESS) {
        free(pixels);
        JxlEncoderDestroy(encoder);
        return nil;
    }
    
    JxlColorEncoding colorEncoding;
    JxlColorEncodingSetToSRGB(&colorEncoding, JXL_FALSE);
    JxlEncoderSetColorEncoding(encoder, &colorEncoding);
    
    if (JxlEncoderAddImageFrame(frameSettings,
                               &pixelFormat,
                               pixels,
                               bufferSize) != JXL_ENC_SUCCESS) {
        free(pixels);
        JxlEncoderDestroy(encoder);
        return nil;
    }
    
    JxlEncoderCloseInput(encoder);
    
    size_t outCapacity = 64 * 1024;
    uint8_t *outBuffer = malloc(outCapacity);
    
    uint8_t *nextOut = outBuffer;
    size_t availOut = outCapacity;
    
    while (1) {
        JxlEncoderStatus status =
            JxlEncoderProcessOutput(encoder, &nextOut, &availOut);
        
        if (status == JXL_ENC_SUCCESS) {
            break;
        } else if (status == JXL_ENC_NEED_MORE_OUTPUT) {
            size_t used = nextOut - outBuffer;
            outCapacity *= 2;
            outBuffer = realloc(outBuffer, outCapacity);
            nextOut = outBuffer + used;
            availOut = outCapacity - used;
        } else {
            free(outBuffer);
            free(pixels);
            JxlEncoderDestroy(encoder);
            return nil;
        }
    }
    
    size_t finalSize = nextOut - outBuffer;
    
    NSData *result = [NSData dataWithBytes:outBuffer length:finalSize];
    
    free(outBuffer);
    free(pixels);
    JxlEncoderDestroy(encoder);
    
    return result;
}

@end
