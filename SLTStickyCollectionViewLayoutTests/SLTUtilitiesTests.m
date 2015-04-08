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
    XCTAssertEqual(SLTNearestNumberToReferenceNumber(69.f, 72.f, 70.f), 69.f, @"Nearest number is not choosed correctly");
    XCTAssertEqual(SLTNearestNumberToReferenceNumber(0.f, 1.f, 0.5f), 0.f, @"Nearest number is not choosed correctly");
    XCTAssertEqual(SLTNearestNumberToReferenceNumber(-15.1f, 21.5f, 2.f), -15.1f, @"Nearest number is not choosed correctly");
}


- (void)testObjectExistsInArray {
    NSNumber *anObject = @14;
    XCTAssertFalse([@[] containsObjectAtIndex:0], @"There is no object in an empty array");
    XCTAssert([@[anObject] containsObjectAtIndex:0], @"Array contains an object.");
    NSArray *anArray = @[anObject, anObject, anObject];
    XCTAssert([anArray containsObjectAtIndex:2], @"The array contains onject for index");
    XCTAssertFalse([anArray containsObjectAtIndex:3], @"The array contains onject for index");
}

@end
