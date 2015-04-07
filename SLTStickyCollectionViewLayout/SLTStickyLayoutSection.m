//
//  SLTStickyLayoutSection.m
//  SLTStickyCollectionViewLayout
//
//  Created by Andrei Raifura on 4/1/15.
//  Copyright (c) 2015 YOPESO. All rights reserved.
//

#import "SLTStickyLayoutSection.h"
#import "SLTStickyLayoutItemZone.h"

@interface SLTStickyLayoutSection ()
@property (nonatomic, readwrite) SLTMetrics metrics;
@property (strong, nonatomic) SLTStickyLayoutItemZone *itemZone;

@property (strong, nonatomic) NSArray *attributes;

@end


@implementation SLTStickyLayoutSection

- (instancetype)initWithMetrics:(SLTMetrics)metrics {
    self = [super init];
    if (self) {
        _metrics = metrics;
    }
    
    return self;
}


- (void)prepareIntermediateMetrics {
    _itemZone = [[SLTStickyLayoutItemZone alloc] initWithMetrics:[self calculateItemZoneMetrics]];
    
    _itemZone.itemSize = _itemSize;
    _itemZone.numberOfItems = _numberOfItems;
    _itemZone.minimumLineSpacing = _minimumLineSpacing;
    _itemZone.interitemSpacing = _minimumInteritemSpacing;
}


- (CGFloat)sectionWidth {
    return maximumFloat([_itemZone calculateZoneWidth], _headerContentWidth, _footerContentWidth);
}


- (CGRect)sectionRect {
    return CGRectFromMetrics(_metrics, [self sectionWidth]);
}


- (NSIndexPath *)headerIndexPath {
    return [NSIndexPath indexPathForItem:0 inSection:_sectionNumber];
}


- (NSIndexPath *)footerIndexPath {
    return [NSIndexPath indexPathForItem:0 inSection:_sectionNumber];
}


- (BOOL)headerIsVisibleInRect:(CGRect)rect {
    return _headerHeight > 0.f && [self headerIntersectsRect:rect];
}


- (BOOL)footerIsVisibleInRect:(CGRect)rect {
    return _footerHeight > 0.f && [self footerIntersectsRect:rect];
}


- (CGRect)headerFrameForVisibleRect:(CGRect)visibleRect {
    if (![self headerIntersectsRect:visibleRect]) return [self initialHeaderContentRect];
    
    CGFloat headerXPosition = [self headerXPositionForVisibleRect:visibleRect];
    CGRect headerRect = [self headerRect];
    CGFloat exceedingSpace =  headerXPosition + _headerContentWidth - CGRectGetMaxX(headerRect);
    
    BOOL headerShouldStickToRightMargin = (exceedingSpace > 0.f);
    if (headerShouldStickToRightMargin) {
        return [self rectForHeaderAlignedToRight];
    } else {
        return CGRectFromRectWithX([self initialHeaderContentRect], headerXPosition);
    }
}


- (CGRect)footerFrameForVisibleRect:(CGRect)visibleRect {
    if (![self footerIntersectsRect:visibleRect]) return [self initialFooterContentRect];
    
    CGFloat footerXPosition = [self headerXPositionForVisibleRect:visibleRect];
    CGRect footerRect = [self footerRect];
    CGFloat exceedingSpace =  footerXPosition + _footerContentWidth - CGRectGetMaxX(footerRect);
    
    BOOL footerShouldStickToRightMargin = (exceedingSpace > 0.f);
    
    if (footerShouldStickToRightMargin) {
        return [self rectForFooterAlignedToRight];
    } else {
        return CGRectFromRectWithX([self initialFooterContentRect], footerXPosition);
    }
}


- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:_sectionNumber];
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = [_itemZone frameForItemAtIndex:index];
    return attributes;
}


- (NSArray *)layoutAttributesForItemsInRect:(CGRect)rect {
    NSMutableArray *attributesInRect = [NSMutableArray array];
    
    for (UICollectionViewLayoutAttributes *attributes in self.attributes) {
        if(CGRectIntersectsRect(rect, attributes.frame)){
            [attributesInRect addObject:attributes];
        }
    }
    
    return [NSArray arrayWithArray:attributesInRect];
}


#pragma mark - Private Methods

- (NSArray *)attributes {
    if (_attributes) return _attributes;
    
    NSMutableArray *attributes = [NSMutableArray arrayWithCapacity:_numberOfItems];
    
    for (NSInteger index = 0; index < _numberOfItems; index++) {
        [attributes addObject:[self layoutAttributesForItemAtIndex:index]];
    }
    
    _attributes = [NSArray arrayWithArray:attributes];
    
    return _attributes;
}


- (SLTMetrics)calculateItemZoneMetrics {
    SLTMetrics metrics = _metrics;
    if (_headerHeight > 0.f) {
        metrics.height -= _headerHeight;
        metrics.y += _headerHeight;
        
        metrics.height -= _distanceBetweenHeaderAndCells;
        metrics.y += _distanceBetweenHeaderAndCells;
    }
    
    if (_footerHeight > 0.f) {
        metrics.height -= _footerHeight;
        metrics.height -= _distanceBetweenFooterAndCells;
    }
    
    return  metrics;
}


- (BOOL)headerIntersectsRect:(CGRect)rect {
    return CGRectIntersectsRect(rect, [self headerRect]);
}


- (BOOL)footerIntersectsRect:(CGRect)rect {
    return CGRectIntersectsRect(rect, [self footerRect]);
}


- (CGFloat)headerXPositionForVisibleRect:(CGRect)visibleRect {
    BOOL headerViewSticksToSectionMargin = (CGRectGetMinX(visibleRect) <= _metrics.x - _headerInset);
    if (headerViewSticksToSectionMargin) {
        return _metrics.x;
    } else {
        return CGRectGetMinX(visibleRect) + _headerInset;
    }
}


- (CGRect)rectForHeaderAlignedToRight {
    CGFloat shiftingDistance = [self sectionWidth] - _headerContentWidth;
    
    return CGRectOffset([self initialHeaderContentRect], shiftingDistance, 0.f);
}


- (CGRect)rectForFooterAlignedToRight {
    CGFloat shiftingDistance = [self sectionWidth] - _footerContentWidth;
    
    return CGRectOffset([self initialFooterContentRect], shiftingDistance, 0.f);
}


- (CGRect)headerRect {
    return CGRectMake(_metrics.x, _metrics.y, [self sectionWidth], _headerHeight);
}


- (CGRect)footerRect {
    CGPoint origin = [self footerOrigin];
    
    return CGRectMake(origin.x, origin.y, [self sectionWidth], _footerHeight);
}


- (CGRect)initialHeaderContentRect {
    return CGRectMake(_metrics.x, _metrics.y, _headerContentWidth, _headerHeight);
}


- (CGRect)initialFooterContentRect {
    CGPoint origin = [self footerOrigin];
    
    return CGRectMake(origin.x, origin.y, _footerContentWidth, _footerHeight);
}


- (CGPoint)footerOrigin {
    CGFloat yOrigin = SLTMetricsGetMaxY(_metrics) - _footerHeight;
    
    return CGPointMake(_metrics.x, yOrigin);
}

@end


@implementation SLTStickyLayoutSection (OptimizedScrolling)

- (CGFloat)offsetForNearestColumnToOffset:(CGFloat)offset {
    return [_itemZone offsetForNearestColumnToOffset:offset];
}

@end