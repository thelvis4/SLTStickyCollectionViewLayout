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
@property (assign, nonatomic) NSInteger sectionNumber;

@property (assign, nonatomic) NSInteger numberOfCells;
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

- (instancetype)initWithMetrics:(SLTMetrics)metrics;
- (void)prepareIntermediateMetrics;

- (CGRect)frameForItemAtIndex:(NSInteger)index;
- (CGFloat)sectionWidth;
- (CGRect)sectionRect;

- (NSArray *)indexPathsOfItemsInRect:(CGRect)rect;
- (NSIndexPath *)headerIndexPath;
- (NSIndexPath *)footerIndexPath;

- (BOOL)headerIsVisibleInRect:(CGRect)rect;
- (BOOL)footerIsVisibleInRect:(CGRect)rect;

- (CGRect)headerFrameForVisibleRect:(CGRect)visibleRect;
- (CGRect)footerFrameForVisibleRect:(CGRect)visibleRect;

@end
