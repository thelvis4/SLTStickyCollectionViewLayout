//
//  Utils.h
//  SLTStickyCollectionViewLayout
//
//  Created by Andrei Raifura on 4/9/15.
//  Copyright (c) 2015 YOPESO. All rights reserved.
//

#import <UIKit/UIKit.h>

CGRect CGRectFromRectWithX(CGRect rect, CGFloat x);

CGFloat SLTMaximumFloat(CGFloat first, CGFloat second, CGFloat third);
CGFloat SLTNearestNumberToReferenceNumber(CGFloat a, CGFloat b, CGFloat referenceNumber);

extern const NSRange NSRangeUndefined;
BOOL NSRangeIsUndefined(NSRange range);
