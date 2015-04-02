//
//  SLTStickyLayoutItemZone.m
//  SLTStickyCollectionViewLayout
//
//  Created by Andrei Raifura on 4/1/15.
//  Copyright (c) 2015 YOPESO. All rights reserved.
//

#import "SLTStickyLayoutItemZone.h"

typedef struct Position {
    NSInteger line;
    NSInteger column;
} Position;

Position PositionMake(NSInteger line, NSInteger column) {
    Position position;
    position.line = line;
    position.column = column;
    
    return position;
}


BOOL PositionIsEqualToPosition(Position position1, Position position2) {
    return (position1.column == position2.column) && (position1.line == position2.line);
}

@interface SLTStickyLayoutItemZone ()
@property (assign, nonatomic) SLTMetrics metrics;

@end

@implementation SLTStickyLayoutItemZone

- (instancetype)initWithMetrics:(SLTMetrics)metrics {
    self = [super init];
    if (self) {
        _metrics = metrics;
    }
    
    return self;
}


- (CGRect)frameForItemAtIndex:(NSInteger)index {
    CGFloat lineSpacing = [self calculateLineSpacing];
    Position position = [self positionForItemAtIndex:index];
    CGFloat xOrigin = _metrics.x + position.column * (_itemSize.width + _interitemSpacing);
    CGFloat yOrigin = _metrics.y + position.line * (_itemSize.height + lineSpacing);
    
    return CGRectMake(xOrigin, yOrigin, _itemSize.width, _itemSize.height);
}


- (CGFloat)calculateZoneWidth {
    if (_numberOfItems == 0) return 0.f;
    
    NSInteger numberOfColumns = [self numberOfColumns];
    if (numberOfColumns == 0) return _itemSize.width;
    
    NSInteger numberOfHorizontalSpaces = numberOfColumns - 1;
    return (numberOfColumns * _itemSize.width) + (numberOfHorizontalSpaces * _interitemSpacing);
}


- (NSArray *)indexesOfItemsInRect:(CGRect)rect {
    CGRect intersectedRect = CGRectIntersection(rect, [self zoneRect]);
    if (CGRectIsNull(intersectedRect)) return @[];
    
    return [self buildMapOfItemIndexesForRect:intersectedRect];
}


#pragma mark - Private Methods

- (Position)positionForItemAtIndex:(NSInteger)index {
    if (0 == index) return PositionMake(0, 0);
    
    NSInteger numberOfLines = [self numberOfLines];
    BOOL isEnoughSpace = (numberOfLines != 0);
    NSInteger column = isEnoughSpace ? index / numberOfLines : index; // there is at least a line of items
    NSInteger line = isEnoughSpace ? index % numberOfLines : 0;
    
    return PositionMake(line, column);
}


- (NSInteger)indexForPosition:(Position)position {
    if (PositionIsEqualToPosition(position, PositionMake(0, 0))) return 0;
    
    return position.column * [self numberOfLines] + position.line;
}


- (CGFloat)calculateLineSpacing {
    NSInteger numberOfLines = [self numberOfLines];
    CGFloat spaceOcupiedByItems = numberOfLines * _itemSize.height;
    CGFloat totalLineSpacing = _metrics.height - spaceOcupiedByItems;
    
    NSInteger numberOfSpaces = numberOfLines - 1;
    
    return totalLineSpacing / numberOfSpaces;
}


- (NSInteger)numberOfLines {
    return floorf((_metrics.height + _minimumLineSpacing) / (_itemSize.height + _minimumLineSpacing));
}


- (NSInteger)numberOfColumns {
    NSInteger numberOfLines = [self numberOfLines];
    
    return ceilf((CGFloat)self.numberOfItems / (CGFloat)numberOfLines);
}


#pragma mark - Item Frames Mapping

- (NSArray *)buildMapOfItemIndexesForRect:(CGRect)rect {
    NSInteger firstLine = [self firstLineInRect:rect];
    NSInteger lastLine = [self lastLineInRect:rect];
    NSInteger firstColumn = [self firstColumnInRect:rect];
    NSInteger lastColumn = [self lastColumnInRect:rect];
    
    NSMutableArray *indexes = [NSMutableArray array];
    for (NSInteger line = firstLine; line <= lastLine; line++) {
        for (NSInteger column = firstColumn; column <= lastColumn; column++) {
            Position position = PositionMake(line, column);
            NSInteger index = [self indexForPosition:position];
            if (index < self.numberOfItems) {
                [indexes addObject:@(index)];
            }
        }
    }
    
    return indexes;
}


- (CGRect)zoneRect {
    CGFloat x = _metrics.x;
    CGFloat y = _metrics.y;
    CGFloat height = _metrics.height;
    CGFloat width = [self calculateZoneWidth];
    
    return CGRectMake(x, y, width, height);
}


- (NSInteger)firstColumnInRect:(CGRect)rect {
    CGFloat x = CGRectGetMinX(rect);
    CGFloat column = (x - _metrics.x + _interitemSpacing) / (_itemSize.width + _interitemSpacing);
    
    return floorf(column);
}


- (NSInteger)lastColumnInRect:(CGRect)rect {
    CGFloat x = CGRectGetMaxX(rect);
    CGFloat column = (x - _metrics.x) / (_itemSize.width + _interitemSpacing);
    
    return floorf(column);
}


- (NSInteger)firstLineInRect:(CGRect)rect {
    CGFloat lineSpacing = [self calculateLineSpacing];
    CGFloat y = CGRectGetMinY(rect);
    CGFloat line = (y - _metrics.y + lineSpacing) / (_itemSize.height + lineSpacing);
    
    return floorf(line);
}


- (NSInteger)lastLineInRect:(CGRect)rect {
    CGFloat y = CGRectGetMaxY(rect);
    CGFloat line = (y - _metrics.y) / (_itemSize.height + [self calculateLineSpacing]);
    
    return floorf(line);
}

@end
