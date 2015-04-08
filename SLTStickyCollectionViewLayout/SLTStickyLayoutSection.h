//
//  SLTStickyLayoutSection.h
//  SLTStickyCollectionViewLayout
//
//  Created by Andrei Raifura on 4/1/15.
//  Copyright (c) 2015 YOPESO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLTMetrics.h"

@interface SLTStickyLayoutSection : NSObject
@property (assign, nonatomic) NSInteger sectionIndex;

@property (assign, nonatomic) NSInteger numberOfItems;
@property (assign, nonatomic) CGSize itemSize;

@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat minimumInteritemSpacing;

@property (nonatomic) CGFloat distanceBetweenHeaderAndCells;
@property (nonatomic) CGFloat distanceBetweenFooterAndCells;

@property (nonatomic) CGFloat headerHeight;
@property (nonatomic) CGFloat footerHeight;

@property (nonatomic) CGFloat headerContentWidth;
@property (nonatomic) CGFloat footerContentWidth;

@property (nonatomic) CGFloat headerInset;

@property (nonatomic, readonly) SLTMetrics metrics;

- (instancetype)initWithMetrics:(SLTMetrics)metrics;
- (void)prepareIntermediateMetrics;

- (CGFloat)sectionWidth;
- (CGRect)sectionRect;

- (BOOL)hasHeaderInRect:(CGRect)rect;
- (BOOL)hasFooterInRect:(CGRect)rect;

- (NSArray *)layoutAttributesForItemsInRect:(CGRect)rect;
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndex:(NSInteger)index;
- (UICollectionViewLayoutAttributes *)layoutAttributesForHeaderInRect:(CGRect)rect;
- (UICollectionViewLayoutAttributes *)layoutAttributesForFooterInRect:(CGRect)rect;

@end

@interface SLTStickyLayoutSection (OptimizedScrolling)
- (CGFloat)offsetForNearestColumnToOffset:(CGFloat)offset;

@end