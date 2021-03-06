//
//  TitledCollectionViewCellZoneTests.m
//  TestHorizontalCollectionView
//
//  Created by thelvis on 3/2/15.
//  Copyright (c) 2015 Yopeso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SLTStickyLayoutItemZone.h"

CGRect CGRectMakeWithSize(CGFloat x, CGFloat y, CGSize size) {
    return CGRectMake(x, y, size.width, size.height);
}

@interface SLTStickyLayoutItemZoneTests : XCTestCase

@end

@implementation SLTStickyLayoutItemZoneTests

#pragma mark - Testing frameForItemAtIndex

- (void)testFrameForItemAtIndexWithNoZoneOffset {
    CGSize itemSize = CGSizeMake(30, 10);
    SLTStickyLayoutItemZone *zone = [self itemZoneWithItemSize:itemSize];
    
    CGRect cellRect = [zone frameForItemAtIndex:0];
    CGRect expectedRect = CGRectMakeWithSize(0, 0, itemSize);
    XCTAssertTrue(CGRectEqualToRect(cellRect, expectedRect), @"Item is not positioned correctly");
    
    CGRect cellRect2 = [zone frameForItemAtIndex:3];
    CGRect expectedRect2 = CGRectMakeWithSize(35, 20, itemSize);
    XCTAssertTrue(CGRectEqualToRect(cellRect2, expectedRect2), @"Item is not positioned correctly");
    
}


- (void)testFrameForItemAtIndexWithConstrainedSpace {
    CGSize itemSize = CGSizeMake(30, 40);
    SLTStickyLayoutItemZone *zone = [self itemZoneWithItemSize:itemSize];
    
    CGRect cellRect = [zone frameForItemAtIndex:0];
    CGRect expectedRect = CGRectMakeWithSize(0, 0, itemSize);
    XCTAssertTrue(CGRectEqualToRect(cellRect, expectedRect), @"Item is not positioned correctly");
    
    CGRect cellRect2 = [zone frameForItemAtIndex:3];
    CGRect expectedRect2 = CGRectMakeWithSize(105, 0, itemSize);
    XCTAssertTrue(CGRectEqualToRect(cellRect2, expectedRect2), @"Item is not positioned correctly");
}


- (void)testFrameForItemAtIndexWithZoneOffset {
    CGSize itemSize = CGSizeMake(30, 10);
    SLTMetrics metrics = SLTMetricsMake(30, 65, 30);
    SLTStickyLayoutItemZone *zone = [self itemZoneWithZoneMetrics:metrics itemSize:itemSize];
    
    CGRect cellRect = [zone frameForItemAtIndex:0];
    CGRect expectedRect = CGRectMakeWithSize(30, 65, itemSize);
    XCTAssertTrue(CGRectEqualToRect(cellRect, expectedRect), @"Item is not positioned correctly when item zone has an offset");
    
    CGRect cellRect2 = [zone frameForItemAtIndex:3];
    CGRect expectedRect2 = CGRectMakeWithSize(65, 85, itemSize);
    XCTAssertTrue(CGRectEqualToRect(cellRect2, expectedRect2), @"Item is not positioned correctly when item zone has an offset");
}


#pragma mark - Testing calculateZoneWidth method

- (void)testZoneWidthForZeroCells {
    SLTStickyLayoutItemZone *zone = [self itemZoneForNumberOfItems:0];
    XCTAssertEqual([zone calculateZoneWidth], 0.f, @"The width of the zone should be zero if there are no items");
}


- (void)testZoneWidthForAColumn {
    SLTStickyLayoutItemZone *zone = [self itemZoneForNumberOfItems:1];
    XCTAssertEqual([zone calculateZoneWidth], 30.f, @"The width of the zone should be equal to cell's width if there is on item");
}


- (void)testZoneWidthMultipleColumns {
    SLTStickyLayoutItemZone *zone = [self itemZoneForNumberOfItems:14];
    XCTAssertEqual([zone calculateZoneWidth], 240.f, @"The width of the item zone is not calculated correctly for multiple colums");
}


- (void)testOffsetForNearestColumn {
    [self runTestsForTestingOffsetForNearestColumnWithSectionOffset:0];
    [self runTestsForTestingOffsetForNearestColumnWithSectionOffset:20.5];
    [self runTestsForTestingOffsetForNearestColumnWithSectionOffset:-20];
}


- (void)runTestsForTestingOffsetForNearestColumnWithSectionOffset:(CGFloat)sectionOffset {
    SLTMetrics metrics = SLTMetricsMake(sectionOffset, 0, 90);
    SLTStickyLayoutItemZone *zone = [self itemZoneWithZoneMetrics:metrics itemSize:CGSizeMake(20, 20)];
    zone.numberOfItems = 11;
    
    XCTAssertEqual([zone offsetForNearestColumnToOffset:sectionOffset + 0.0], sectionOffset + 0.0, @"Offset wasn't calculated correctly");
    XCTAssertEqual([zone offsetForNearestColumnToOffset:sectionOffset + 25.0], sectionOffset + 25.0, @"Offset wasn't calculated correctly");
    XCTAssertEqual([zone offsetForNearestColumnToOffset:sectionOffset + 60.0], sectionOffset + 50.0, @"Offset wasn't calculated correctly");
    XCTAssertEqual([zone offsetForNearestColumnToOffset:sectionOffset + 90.0], sectionOffset + 75.0, @"Offset wasn't calculated correctly");
    XCTAssertEqual([zone offsetForNearestColumnToOffset:sectionOffset + 12.5], sectionOffset + 0.0, @"Offset wasn't calculated correctly");
    XCTAssertEqual([zone offsetForNearestColumnToOffset:-INFINITY], sectionOffset + 0.0, @"Offset wasn't calculated correctly if input offset is out of item zone");
    XCTAssertEqual([zone offsetForNearestColumnToOffset:INFINITY], sectionOffset + 75, @"Offset wasn't calculated correctly if input offset is more that last zone point");
}


#pragma mark - Helping methods

- (SLTStickyLayoutItemZone *)itemZoneForNumberOfItems:(NSInteger)numberOfItems {
    SLTStickyLayoutItemZone *zone = [self itemZoneWithZoneMetrics:SLTMetricsMake(30, 65, 30)
                                                         itemSize:CGSizeMake(30, 10)];
    zone.numberOfItems = numberOfItems;
    
    return zone;
}


- (SLTStickyLayoutItemZone *)itemZoneWithItemSize:(CGSize)itemSize {
    SLTMetrics metrics = SLTMetricsMake(0, 0, 30);

    return [self itemZoneWithZoneMetrics:metrics itemSize:itemSize];
}


- (SLTStickyLayoutItemZone *)itemZoneWithZoneMetrics:(SLTMetrics)metrics itemSize:(CGSize)itemSize {
    SLTStickyLayoutItemZone *zone = [self zoneWithMetrics:metrics];
    zone.itemSize = itemSize;
    zone.minimumLineSpacing = 5.f;
    zone.interitemSpacing = 5.f;
    
    return zone;
}


- (SLTStickyLayoutItemZone *)zoneWithMetrics:(SLTMetrics)metrics {
    return [[SLTStickyLayoutItemZone alloc] initWithMetrics:metrics];
}

@end
