//
//  SLTMetrics.h
//  SLTStickyCollectionViewLayout
//
//  Created by Andrei Raifura on 4/2/15.
//  Copyright (c) 2015 YOPESO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct SLTMetrics {
    CGFloat x;
    CGFloat y;
    CGFloat height;
} SLTMetrics;

CGFloat SLTMetricsGetMaxY(SLTMetrics metrics);

SLTMetrics SLTMetricsMake(CGFloat x, CGFloat y, CGFloat height);
SLTMetrics SLTMetricsFromRect(CGRect rect);

CGRect CGRectFromMetrics(SLTMetrics metrics, CGFloat width);

CGRect CGRectFromRectWithX(CGRect rect, CGFloat x);
CGFloat maximumFloat(CGFloat first, CGFloat second, CGFloat third);

CGFloat nearestNumberToReferenceNumber(CGFloat a, CGFloat b, CGFloat referenceNumber);

extern const NSRange NSRangeUndefined;
BOOL NSRangeIsUndefined(NSRange range);
