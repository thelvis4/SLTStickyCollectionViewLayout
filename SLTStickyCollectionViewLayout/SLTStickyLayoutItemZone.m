//
//  SLTStickyLayoutItemZone.m
//  SLTStickyCollectionViewLayout
//
//  Created by Andrei Raifura on 4/1/15.
//  Copyright (c) 2015 YOPESO. All rights reserved.
//

#import "SLTStickyLayoutItemZone.h"
#import "SLTPosition.h"
#import "Utils.h"

static NSInteger const SLTUndefinedInteger = -INFINITY;

@interface SLTStickyLayoutItemZone ()
@property (assign, nonatomic) SLTMetrics metrics;

@property (nonatomic) NSInteger numberOfLines;

@end


@implementation SLTStickyLayoutItemZone

- (instancetype)initWithMetrics:(SLTMetrics)metrics {
    self = [super init];
    if (self) {
        _metrics = metrics;
        _numberOfLines = SLTUndefinedInteger;
    }
    
    return self;
}


- (CGRect)frameForItemAtIndex:(NSInteger)index {
    SLTPosition position = [self positionForItemAtIndex:index];
    CGFloat xOrigin = [self xOriginForColumnNumber:position.column];
    CGFloat yOrigin = [self yOriginForLineNumber:position.line];
    
    return CGRectMake(xOrigin, yOrigin, _itemSize.width, _itemSize.height);
}


- (CGFloat)calculateZoneWidth {
    if (_numberOfItems == 0) return 0.f;
    
    NSInteger numberOfColumns = [self numberOfColumns];
    if (numberOfColumns == 0) return _itemSize.width;
    
    NSInteger numberOfHorizontalSpaces = numberOfColumns - 1;
    return (numberOfColumns * _itemSize.width) + (numberOfHorizontalSpaces * _interitemSpacing);
}


#pragma mark - Caching values

- (NSInteger)numberOfLines {
    if (_numberOfLines == SLTUndefinedInteger) {
        _numberOfLines = [self calculateNumberOfLines];
    }
    
    return _numberOfLines;
}


#pragma mark - Private Methods

- (SLTPosition)positionForItemAtIndex:(NSInteger)index {
    if (0 == index) return SLTPositionMake(0, 0);
    
    NSInteger numberOfLines = [self numberOfLines];
    BOOL isEnoughSpace = (numberOfLines != 0);
    NSInteger column = isEnoughSpace ? index / numberOfLines : index; // there is at least a line of items
    NSInteger line = isEnoughSpace ? index % numberOfLines : 0;
    
    return SLTPositionMake(line, column);
}


- (CGFloat)yOriginForLineNumber:(NSInteger)line {
    return _metrics.y + line * [self distanceBetweenLines];
}


- (CGFloat)xOriginForColumnNumber:(NSInteger)column {
    return _metrics.x + column * [self distanceBetweenColumns];
}


- (CGFloat)calculateLineSpacing {
    NSInteger numberOfLines = [self numberOfLines];
    if (1 == numberOfLines) return 0.0;

    CGFloat spaceOccupiedByItems = numberOfLines * _itemSize.height;
    CGFloat totalLineSpacing = _metrics.height - spaceOccupiedByItems;
    
    NSInteger numberOfSpaces = numberOfLines - 1;
    
    return totalLineSpacing / numberOfSpaces;
}


- (NSInteger)calculateNumberOfLines {
    return (NSInteger) floorf((_metrics.height + _minimumLineSpacing) / (_itemSize.height + _minimumLineSpacing));
}


- (NSInteger)numberOfColumns {
    return (NSInteger) ceilf((CGFloat)_numberOfItems / (CGFloat)self.numberOfLines);
}


#pragma mark - Item Frames Mapping

- (CGRect)zoneRect {
    CGFloat x = _metrics.x;
    CGFloat y = _metrics.y;
    CGFloat height = _metrics.height;
    CGFloat width = [self calculateZoneWidth];
    
    return CGRectMake(x, y, width, height);
}


- (NSInteger)firstColumnInRect:(CGRect)rect {
    CGFloat x = CGRectGetMinX(rect);
    CGFloat column = (x - _metrics.x + _interitemSpacing) / [self distanceBetweenColumns];
    
    return (NSInteger) floorf(column);
}


- (NSInteger)lastColumnInRect:(CGRect)rect {
    CGFloat x = CGRectGetMaxX(rect);
    CGFloat column = (x - _metrics.x) / [self distanceBetweenColumns];
    NSInteger numberOfColumns = [self numberOfColumns];

    return (NSInteger)((column >= numberOfColumns) ? (numberOfColumns - 1) : floorf(column));
}


- (CGFloat)distanceBetweenColumns {
    return _itemSize.width + _interitemSpacing;
}


- (CGFloat)distanceBetweenLines {
    CGFloat lineSpacing = [self calculateLineSpacing];

    return _itemSize.height + lineSpacing;
}

@end


@implementation SLTStickyLayoutItemZone (OptimizedScrolling)

- (CGFloat)offsetForNearestColumnToOffset:(CGFloat)offset {
    if (offset < _metrics.x) return _metrics.x;
    
    CGRect zoneRect = [self zoneRect];
    if (offset > CGRectGetMaxX(zoneRect)) {
        NSInteger lastColumn = [self numberOfColumns] - 1;
        return [self xOriginForColumnNumber:lastColumn];
    }

    CGFloat distanceBetweenColumns = [self distanceBetweenColumns];
    CGFloat addition = distanceBetweenColumns / 2;
    CGFloat x = offset - addition;
    CGRect rect = CGRectMake(x, _metrics.y, distanceBetweenColumns, 0);
    CGRect intersectedRect = CGRectIntersection(rect, zoneRect);
    
    NSInteger firstColumn = [self firstColumnInRect:intersectedRect];
    NSInteger lastColumn = [self lastColumnInRect:intersectedRect];
    
    
    CGFloat firstOffset = [self xOriginForColumnNumber:firstColumn];
    CGFloat secondOffset = [self xOriginForColumnNumber:lastColumn];
    
    return SLTNearestNumberToReferenceNumber(firstOffset, secondOffset, offset);
}

@end
