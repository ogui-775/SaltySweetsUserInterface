//Created by Salty on 7/23/26.

#import "SOCalendarDockTileReplacementPageController.h"

@interface SOCalendarDisplayLayerOrientation : NSObject
@property CGRect dayRect;
@property CATransform3D dayRotation;
@property CGRect monthRect;
@property CATransform3D monthRotation;

+ (instancetype)orientationWithPreviousOrientation:(SOCalendarDisplayLayerOrientation *)previous
                                      dayRectOrNil:(CGRect)dayRect
                                  dayRotationOrNil:(CATransform3D)dayRotation
                                    monthRectOrNil:(CGRect)monthRect
                                     monthRotation:(CATransform3D)monthRotation;
+ (instancetype)orientationWithDayRect:(CGRect)dayRect
                              rotation:(CATransform3D)dayRotation
                             monthRect:(CGRect)monthRect
                              rotation:(CATransform3D)monthRotation;
@end

@implementation SOCalendarDisplayLayerOrientation
+ (instancetype)orientationWithPreviousOrientation:(SOCalendarDisplayLayerOrientation *)previous
                                      dayRectOrNil:(CGRect)dayRect
                                  dayRotationOrNil:(CATransform3D)dayRotation
                                    monthRectOrNil:(CGRect)monthRect
                                     monthRotation:(CATransform3D)monthRotation{
    if (!previous)
        return [SOCalendarDisplayLayerOrientation orientationWithDayRect:dayRect
                                                                rotation:dayRotation
                                                               monthRect:monthRect
                                                                rotation:monthRotation];
    
    SOCalendarDisplayLayerOrientation *orientation = [SOCalendarDisplayLayerOrientation new];
    
    if (!CGRectEqualToRect(dayRect, CGRectZero))
        orientation.dayRect = dayRect;
    else
        orientation.dayRect = previous.dayRect;
    
    if (!CATransform3DEqualToTransform(dayRotation, CATransform3DIdentity))
        orientation.dayRotation = dayRotation;
    else
        orientation.dayRotation = previous.dayRotation;
    
    if (!CGRectEqualToRect(monthRect, CGRectZero))
        orientation.monthRect = monthRect;
    else
        orientation.monthRect = previous.monthRect;
    
    if (!CATransform3DEqualToTransform(monthRotation, CATransform3DIdentity))
        orientation.monthRotation = monthRotation;
    else
        orientation.monthRotation = previous.monthRotation;
    
    return orientation;
}

+ (instancetype)orientationWithDayRect:(CGRect)dayRect
                              rotation:(CATransform3D)dayRotation
                             monthRect:(CGRect)monthRect
                              rotation:(CATransform3D)monthRotation{
    SOCalendarDisplayLayerOrientation *orientation = [SOCalendarDisplayLayerOrientation new];
    orientation.dayRect = (CGRectIsEmpty(dayRect) || CGRectIsNull(dayRect)) ? CGRectZero : dayRect;
    orientation.dayRotation = CATransform3DEqualToTransform(dayRotation,
                                                            CATransform3DIdentity) ? CATransform3DIdentity : dayRotation;
    orientation.monthRect = (CGRectIsEmpty(monthRect) || CGRectIsNull(monthRect)) ? CGRectZero : monthRect;
    orientation.monthRotation = CATransform3DEqualToTransform(monthRotation,
                                                              CATransform3DIdentity) ? CATransform3DIdentity : monthRotation;
    
    return orientation;
}
@end



@interface SOCalendarDisplayLayer : CALayer
+ (instancetype)initWithImage:(NSImage *)calendarImage
                  orientation:(SOCalendarDisplayLayerOrientation *)orientation;
@property (weak) CALayer *calendarLayer;
@property (weak) CALayer *monthLayer;
@property (weak) CALayer *dayLayer;
@property (strong) SOCalendarDisplayLayerOrientation *currentOrientation;
@end



@interface SOCalendarDisplayView : NSView
@property (strong) SOCalendarDisplayLayer *calendarLayer;
@property (strong) SODragAwareImageView *imageView;
@end

@implementation SOCalendarDisplayView

@end



@implementation SOCalendarDockTileReplacementPageController
//Controller
@end



@implementation SOCalendarDisplayLayer
@synthesize currentOrientation = _currentOrientation;

+ (instancetype)initWithImage:(NSImage *)calendarImage
                  orientation:(SOCalendarDisplayLayerOrientation *)orientation{
    SOCalendarDisplayLayer *layer = [super layer];
    if (layer){
        layer.calendarLayer = [CALayer layer];
        layer.dayLayer = [CALayer layer];
        layer.monthLayer = [CALayer layer];
        
        layer.currentOrientation = orientation;
    }
    return layer;
}

- (SOCalendarDisplayLayerOrientation *)currentOrientation{
    return _currentOrientation;
}

- (void)setCurrentOrientation:(SOCalendarDisplayLayerOrientation *)currentOrientation{
    _currentOrientation = currentOrientation;
    //do transform
}
@end
