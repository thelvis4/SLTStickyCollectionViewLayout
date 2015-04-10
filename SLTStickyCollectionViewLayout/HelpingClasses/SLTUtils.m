
//
//  Utils.m
//  SLTStickyCollectionViewLayout
//
//  Created by Andrei Raifura on 4/9/15.
//  Copyright (c) 2015 YOPESO. All rights reserved.
//

#import "SLTUtils.h"

CGRect CGRectFromRectWithX(CGRect rect, CGFloat x) {
    CGRect changedRect = rect;
    changedRect.origin.x = x;
    
    return changedRect;
}


CGFloat SLTMaximumFloat(CGFloat first, CGFloat second, CGFloat third) {
    CGFloat max = first;
    
    if (second > max) {
        max = second;
    }
    
    if (third > max) {
        max = third;
    }
    
    return max;
}


CGFloat SLTNearestNumberToReferenceNumber(CGFloat a, CGFloat b, CGFloat referenceNumber) {
    return (ABS(referenceNumber - b) < ABS(referenceNumber - a)) ? b : a;
}


BOOL SLTFloatIsBetweenFloats(CGFloat number, CGFloat firstNumber, CGFloat secondNumber) {
    if (number > firstNumber && number < secondNumber) return YES;
    if (number < firstNumber && number > secondNumber) return YES;
    
    return NO;
}

const NSRange NSRangeUndefined = {INFINITY,0};


BOOL NSRangeIsUndefined(NSRange range) {
    return NSEqualRanges(range, NSRangeUndefined);
}
