//
//  SLTUtilitiesTests.m
//  SLTStickyCollectionViewLayout
//
//  Created by Andrei Raifura on 4/3/15.
//  Copyright (c) 2015 YOPESO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SLTMetrics.h"

@interface SLTUtilitiesTests : XCTestCase

@end

@implementation SLTUtilitiesTests

- (void)testExample {
    XCTAssertEqual(nearestNumberToReferenceNumber(69.f, 72.f, 70.f), 69.f, @"Nearest number is not choosed correctly");
    XCTAssertEqual(nearestNumberToReferenceNumber(0.f, 1.f, 0.5f), 0.f, @"Nearest number is not choosed correctly");
    XCTAssertEqual(nearestNumberToReferenceNumber(-15.1f, 21.5f, 2.f), -15.1f, @"Nearest number is not choosed correctly");
}

@end
