//
//  SLTStickyLayoutItemZone.h
//  SLTStickyCollectionViewLayout
//
//  Created by Andrei Raifura on 4/1/15.
//  Copyright (c) 2015 YOPESO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLTMetrics.h"

@interface SLTStickyLayoutItemZone : NSObject
- (instancetype)initWithMetrics:(SLTMetrics)metrics;

- (CGRect)frameForItemAtIndex:(NSInteger)index;
- (NSArray *)indexesOfItemsInRect:(CGRect)rect;

- (CGFloat)calculateZoneWidth;

@property (assign, nonatomic) CGSize itemSize;
@property (assign, nonatomic) NSInteger numberOfItems;

@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat interitemSpacing;


@end
