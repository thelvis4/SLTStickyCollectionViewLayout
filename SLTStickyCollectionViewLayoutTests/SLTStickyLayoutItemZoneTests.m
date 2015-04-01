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
    CGRect rect = CGRectMake(30, 65, 100, 30);
    SLTStickyLayoutItemZone *zone = [self itemZoneWithZoneRect:rect itemSize:itemSize];
    
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


#pragma mark - Testing indexesOfItemsInRect method

- (void)testIndexOfItemsInRect {
    CGRect rect = CGRectMake(30, 65, 0, 90);
    SLTStickyLayoutItemZone *zone = [self itemZoneWithZoneRect:rect itemSize:CGSizeMake(30, 10)];
    zone.numberOfItems = 14;
    
    NSArray *indexes = [zone indexesOfItemsInRect:CGRectMake(0, 80, 60, 80)];
    XCTAssertNotEqual([indexes count], 0, @"Item positions are not recognized correctly");
}


- (void)testCellIndexesInWrongRect {
    CGRect rect = CGRectMake(30, 65, 0, 90);
    SLTStickyLayoutItemZone *zone = [self itemZoneWithZoneRect:rect itemSize:CGSizeMake(30, 10)];
    zone.numberOfItems = 14;
    
    NSArray *indexes = [zone indexesOfItemsInRect:CGRectMake(0, 0, 200, 50)];
    XCTAssertEqual([indexes count], 0, @"It should return 0 because there are no cells in given rect");
}


- (void)testCellIndexesAreCorrectInRect {
    CGRect rect = CGRectMake(0, 0, 0, 90);
    SLTStickyLayoutItemZone *zone = [self itemZoneWithZoneRect:rect itemSize:CGSizeMake(20, 20)];
    zone.numberOfItems = 11;
    
    NSArray *indexes = [zone indexesOfItemsInRect:CGRectMake(30, 22, 65, 49)];
    NSSet *indexSet = [NSSet setWithArray:indexes];
    XCTAssertEqual([indexes count], [indexSet count], @"There should not be repetitive objects");
    
    NSSet *expectedIndexes = [NSSet setWithArray:@[@4, @5, @7, @8, @10]];

    XCTAssertTrue([indexSet isEqualToSet:expectedIndexes], @"It returned wrong indexes");
}


#pragma mark - Helping methods

- (SLTStickyLayoutItemZone *)itemZoneForNumberOfItems:(NSInteger)numberOfItems {
    SLTStickyLayoutItemZone *zone = [self itemZoneWithZoneRect:CGRectMake(30, 65, 0, 30)
                                                      itemSize:CGSizeMake(30, 10)];
    zone.numberOfItems = numberOfItems;
    
    return zone;
}


- (SLTStickyLayoutItemZone *)itemZoneWithItemSize:(CGSize)itemSize {
    CGRect rect = CGRectMake(0, 0, 0, 30);
    
    return [self itemZoneWithZoneRect:rect itemSize:itemSize];
}


- (SLTStickyLayoutItemZone *)itemZoneWithZoneRect:(CGRect)rect itemSize:(CGSize)itemSize {
    SLTStickyLayoutItemZone *zone = [self zoneWithRect:rect];
    zone.itemSize = itemSize;
    zone.minimumLineSpacing = 5.f;
    zone.interitemSpacing = 5.f;
    
    return zone;
}

- (SLTStickyLayoutItemZone *)zoneWithRect:(CGRect)rect {
    return [[SLTStickyLayoutItemZone alloc] initWithZoneRect:rect];
}

@end
