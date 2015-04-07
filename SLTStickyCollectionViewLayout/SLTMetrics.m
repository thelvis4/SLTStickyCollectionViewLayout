//
//  SLTMetrics.m
//  SLTStickyCollectionViewLayout
//
//  Created by Andrei Raifura on 4/2/15.
//  Copyright (c) 2015 YOPESO. All rights reserved.
//

#import "SLTMetrics.h"

CGFloat SLTMetricsGetMaxY(SLTMetrics metrics) {
    return metrics.y + metrics.height;
}

SLTMetrics SLTMetricsMake(CGFloat x, CGFloat y, CGFloat height) {
    SLTMetrics metrics;
    metrics.x = x;
    metrics.y = y;
    metrics.height = height;
    
    return metrics;
}


SLTMetrics SLTMetricsFromRect(CGRect rect) {
    SLTMetrics metrics;
    metrics.x = CGRectGetMinX(rect);
    metrics.y = CGRectGetMinY(rect);
    metrics.height = CGRectGetHeight(rect);
    
    return metrics;
}


CGRect CGRectFromMetrics(SLTMetrics metrics, CGFloat width) {
    return CGRectMake(metrics.x, metrics.y, width, metrics.height);
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


CGFloat nearestNumberToReferenceNumber(CGFloat a, CGFloat b, CGFloat referenceNumber) {
    return (ABS(referenceNumber - b) < ABS(referenceNumber - a)) ? b : a;
}


const NSRange NSRangeUndefined = {INFINITY,0};


BOOL NSRangeIsUndefined(NSRange range) {
    return NSEqualRanges(range, NSRangeUndefined);
}