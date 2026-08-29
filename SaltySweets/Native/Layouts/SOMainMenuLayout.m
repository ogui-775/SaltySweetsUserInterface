//Created by Salty on 8/7/26.

#import "SOMainMenuLayout.h"

static NSString * const SOMainMenuSectionHeaderKind = @"SOMainMenuSectionHeader";
static NSString * const SOMainMenuBackgroundKindA = @"SOMainMenuBackgroundA";
static NSString * const SOMainMenuBackgroundKindB = @"SOMainMenuBackgroundB";

#pragma mark - Header
@implementation SOMainMenuSectionHeader
- (void)setTitle:(NSString *)title {
    _title = [title copy];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    NSDictionary *attributes = @{
        NSFontAttributeName: [NSFont systemFontOfSize:[NSFont smallSystemFontSize] weight:NSFontWeightLight],
        NSForegroundColorAttributeName: NSColor.labelColor };
    
    NSRect textRect = NSMakeRect( 5.0,
                                 -3.0,
                                 NSWidth(self.bounds) - 32.0,
                                 NSHeight(self.bounds) );
    [self.title drawInRect:textRect withAttributes:attributes];
}

@end

#pragma mark - Background A

@interface SOMainMenuSectionBackgroundA : NSView
@end

@implementation SOMainMenuSectionBackgroundA
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor colorWithWhite:0.0 alpha:0.05] setFill];
    
    NSRectFill(self.bounds);
}
@end

#pragma mark - Background B

@interface SOMainMenuSectionBackgroundB : NSView
@end

@implementation SOMainMenuSectionBackgroundB
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor colorWithWhite:0.0 alpha:0] setFill];
    NSRectFill(self.bounds);
    [[NSColor colorWithWhite:0.0 alpha:0.1] setStroke];
    NSBezierPath *path =
        [NSBezierPath bezierPathWithRect:CGRectMake(0, 0, self.bounds.size.width, 0.5)];
    path.lineWidth = 0.5;
    [path stroke];
    path =
        [NSBezierPath bezierPathWithRect:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 0.5)];
    [path stroke];
}
@end

#pragma mark - Layout

@implementation SOMainMenuLayout
- (instancetype)initCustom {
    self = [super initWithSectionProvider:^NSCollectionLayoutSection *(NSInteger sectionIndex, id environment) {
        NSCollectionLayoutSize *itemSize = [NSCollectionLayoutSize sizeWithWidthDimension:
                                            [NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                                                          heightDimension:
                                            [NSCollectionLayoutDimension absoluteDimension:35]];
        
        NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:itemSize];
        
        NSCollectionLayoutSize *groupSize = [NSCollectionLayoutSize sizeWithWidthDimension:
                                             [NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                                                           heightDimension:
                                             [NSCollectionLayoutDimension fractionalHeightDimension:0.20]];
        
        NSCollectionLayoutGroup *group = [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:groupSize
                                                                                        subitem:item
                                                                                          count:8];
        
        NSCollectionLayoutSection *section = [NSCollectionLayoutSection sectionWithGroup:group];
        
        section.contentInsets = NSDirectionalEdgeInsetsMake(5.0, 10.0, 5.0, 10.0);
        
        NSCollectionLayoutSize *headerSize =
            [NSCollectionLayoutSize
                sizeWithWidthDimension:
                    [NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                heightDimension:
                    [NSCollectionLayoutDimension absoluteDimension:20.0]];

        NSCollectionLayoutBoundarySupplementaryItem *header =
            [NSCollectionLayoutBoundarySupplementaryItem
                boundarySupplementaryItemWithLayoutSize:headerSize
                elementKind:SOMainMenuSectionHeaderKind
                alignment:NSRectAlignmentTop];

        section.boundarySupplementaryItems = @[header];
        
        group.interItemSpacing = [NSCollectionLayoutSpacing fixedSpacing:10];
        
        NSString *backgroundKind =
        (sectionIndex % 2 == 0) ? SOMainMenuBackgroundKindA
                                : SOMainMenuBackgroundKindB;
        
        NSCollectionLayoutDecorationItem *background = [NSCollectionLayoutDecorationItem backgroundDecorationItemWithElementKind:backgroundKind];
        
        section.decorationItems = @[background];
        
        return section;
    }];
    
    if (self) {
        [self registerClass:[SOMainMenuSectionBackgroundA class]
    forDecorationViewOfKind:SOMainMenuBackgroundKindA];
        
        [self registerClass:[SOMainMenuSectionBackgroundB class]
    forDecorationViewOfKind:SOMainMenuBackgroundKindB];
    }
    
    return self;
}
@end
