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