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
@property (nonatomic) CGRect rect;
@property (strong, nonatomic) SLTStickyLayoutItemZone *cellZone;

@end


@implementation SLTStickyLayoutSection

- (instancetype)initWithSectionRect:(CGRect)sectionRect {
    self = [super init];
    if (self) {
        _rect = sectionRect;
    }
    
    return self;
}


- (CGRect)frameForItemAtIndex:(NSInteger)index {
    return [_cellZone frameForItemAtIndex:index];
}


- (CGFloat)sectionWidth {
    return maximumFloat([_cellZone calculateZoneWidth], _headerContentWidth, _footerContentWidth);
}


- (CGRect)sectionRect {
    CGRect rect = _rect;
    rect.size.width = [self sectionWidth];
    
    return rect;
}


- (void)prepareIntermediateMetrics {
    _cellZone = [[SLTStickyLayoutItemZone alloc] initWithZoneRect:[self cellZoneRect]];
    
    _cellZone.itemSize = _itemSize;
    _cellZone.numberOfItems = _numberOfCells;
    _cellZone.minimumLineSpacing = _minimumLineSpacing;
    _cellZone.interitemSpacing = _minimumInteritemSpacing;
}


- (NSArray *)indexPathsOfItemsInRect:(CGRect)rect {
    return [self indexPathsForItemIndexes:[_cellZone indexesOfItemsInRect:rect]];
}


- (NSIndexPath *)headerIndexPath {
    return [NSIndexPath indexPathForItem:0 inSection:_sectionNumber];
}


- (NSIndexPath *)footerIndexPath {
    return [NSIndexPath indexPathForItem:0 inSection:_sectionNumber];
}


- (BOOL)headerIsVisibleInRect:(CGRect)rect {
    if (_headerHeight <= 0.f) return NO;
    if (![self headerIntersectsRect:rect]) return NO;
    
    return YES;
}


- (BOOL)footerIsVisibleInRect:(CGRect)rect {
    if (_footerHeight <= 0.f) return NO;
    if (![self footerIntersectsRect:rect]) return NO;
    
    return YES;
}


- (CGRect)headerFrameForVisibleRect:(CGRect)visibleRect {
    if (![self headerIntersectsRect:visibleRect]) return [self initialHeaderContentRect];
    
    CGFloat headerXPosition = [self headerXPositionForVisibleRect:visibleRect];
    CGRect headerRect = [self headerRect];
    CGFloat exceedingSpace =  headerXPosition + _headerContentWidth - CGRectGetMaxX(headerRect);
    
    BOOL headerShouldStickToRightMargin = (exceedingSpace > 0.f);
    if (headerShouldStickToRightMargin) {
        return [self rectForHeaderAllignedToRight];
    } else {
        return CGRectFromRectWithX([self initialHeaderContentRect], headerXPosition);
    }
}


- (CGFloat)headerXPositionForVisibleRect:(CGRect)visibleRect {
    BOOL headerViewSticksToSectionMargin = (CGRectGetMinX(visibleRect) <= CGRectGetMinX(_rect) - _headerInset);
    if (headerViewSticksToSectionMargin) {
        return CGRectGetMinX(_rect);
    } else {
        return CGRectGetMinX(visibleRect) + _headerInset;
    }
}


- (CGRect)rectForHeaderAllignedToRight {
    CGFloat shiftingDistance = [self sectionWidth] - _headerContentWidth;
    
    return CGRectOffset([self initialHeaderContentRect], shiftingDistance, 0.f);
}


- (CGRect)rectForFooterAllignedToRight {
    CGFloat shiftingDistance = [self sectionWidth] - _footerContentWidth;
    
    return CGRectOffset([self initialFooterContentRect], shiftingDistance, 0.f);
}


- (CGRect)footerFrameForVisibleRect:(CGRect)visibleRect {
    if (![self footerIntersectsRect:visibleRect]) return [self initialFooterContentRect];
    
    CGFloat footerXPosition = [self headerXPositionForVisibleRect:visibleRect];
    CGRect footerRect = [self footerRect];
    CGFloat exceedingSpace =  footerXPosition + _footerContentWidth - CGRectGetMaxX(footerRect);
    
    BOOL footerShouldStickToRightMargin = (exceedingSpace > 0.f);
    
    if (footerShouldStickToRightMargin) {
        return [self rectForFooterAllignedToRight];
    } else {
        return CGRectFromRectWithX([self initialFooterContentRect], footerXPosition);
    }
}


- (BOOL)headerIntersectsRect:(CGRect)rect {
    return CGRectIntersectsRect(rect, [self headerRect]);
}


- (BOOL)footerIntersectsRect:(CGRect)rect {
    return CGRectIntersectsRect(rect, [self footerRect]);
}


- (BOOL)sectionIntersectsRect:(CGRect)rect {
    return CGRectIntersectsRect(rect, [self sectionRect]);
}


#pragma mark - Private Methds

- (NSArray *)indexPathsForItemIndexes:(NSArray *)indexes {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:[indexes count]];
    
    for (NSNumber *index in indexes) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[index integerValue] inSection:_sectionNumber];
        [indexPaths addObject:indexPath];
    }
    
    return [NSArray arrayWithArray:indexPaths];
}


- (CGRect)cellZoneRect {
    CGRect zoneRect = _rect;
    if (_headerHeight > 0.f) {
        zoneRect.size.height -= _headerHeight;
        zoneRect.origin.y += _headerHeight;
        
        zoneRect.size.height -= _distanceBetweenHeaderAndCells;
        zoneRect.origin.y += _distanceBetweenHeaderAndCells;
    }
    
    if (_footerHeight > 0.f) {
        zoneRect.size.height -= _footerHeight;
        zoneRect.size.height -= _distanceBetweenFooterAndCells;
    }
    
    return zoneRect;
}


- (CGRect)headerRect {
    return CGRectMake(CGRectGetMinX(_rect), CGRectGetMinY(_rect), [self sectionWidth], _headerHeight);
}


- (CGRect)footerRect {
    CGPoint origin = [self footerOrigin];
    
    return CGRectMake(origin.x, origin.y, [self sectionWidth], _footerHeight);
}


- (CGRect)initialHeaderContentRect {
    return CGRectMake(CGRectGetMinX(_rect), CGRectGetMinY(_rect), _headerContentWidth, _headerHeight);
}


- (CGRect)initialFooterContentRect {
    CGPoint origin = [self footerOrigin];
    
    return CGRectMake(origin.x, origin.y, _footerContentWidth, _footerHeight);
}


- (CGPoint)footerOrigin {
    CGFloat yOrigin = CGRectGetMaxY(_rect) - _footerHeight;
    
    return CGPointMake(CGRectGetMinX(_rect), yOrigin);
}


CGRect CGRectFromRectWithX(CGRect rect, CGFloat x) {
    CGRect changedRect = rect;
    changedRect.origin.x = x;
    
    return changedRect;
}


CGFloat maximumFloat(CGFloat first, CGFloat second, CGFloat third) {
    CGFloat max = first;
    
    if (second > max) {
        max = second;
    }
    
    if (third > max) {
        max = third;
    }
    
    return max;
}

@end