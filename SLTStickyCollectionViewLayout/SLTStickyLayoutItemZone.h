//
//  SLTStickyLayoutItemZone.h
//  SLTStickyCollectionViewLayout
//
//  Created by Andrei Raifura on 4/1/15.
//  Copyright (c) 2015 YOPESO. All rights reserved.
//

#import "SLTMetrics.h"

@interface SLTStickyLayoutItemZone : NSObject
- (instancetype)initWithMetrics:(SLTMetrics)metrics;

- (CGRect)frameForItemAtIndex:(NSInteger)index;
- (CGFloat)calculateZoneWidth;

@property (nonatomic) CGSize itemSize;
@property (nonatomic) NSInteger numberOfItems;

@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat interitemSpacing;

@end

@interface SLTStickyLayoutItemZone (OptimizedScrolling)
- (CGFloat)offsetForNearestColumnToOffset:(CGFloat)offset;

@end
