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

@interface SLTStickyLayoutItemZoneTests : XCTestCase

@end

@implementation SLTStickyLayoutItemZoneTests

- (void)testRectForCellIndexWithNoZoneOffset {
    CGRect rect = CGRectMake(0, 0, 100, 30);
    SLTStickyLayoutItemZone *zone = [self zoneWithRect:rect];
    zone.itemSize = CGSizeMake(30, 10);
    zone.minimumLineSpacing = 5.f;
    zone.interitemSpacing = 5.f;
    
    CGRect cellRect = [zone frameForItemAtIndex:0];
    CGRect expectedRect = CGRectMake(0, 0, 30, 10);
    XCTAssertTrue(CGRectEqualToRect(cellRect, expectedRect), @"Cell rect is not equal to expected rect");
    
    CGRect cellRect2 = [zone frameForItemAtIndex:3];
    CGRect expectedRect2 = CGRectMake(35, 20, 30, 10);
    XCTAssertTrue(CGRectEqualToRect(cellRect2, expectedRect2), @"Cell rect is not equal to expected rect");
    
}


- (void)testRectWithNotEnoughSpace {
    CGRect rect = CGRectMake(0, 0, 100, 30);
    SLTStickyLayoutItemZone *zone = [self zoneWithRect:rect];
    zone.itemSize = CGSizeMake(30, 40);
    zone.minimumLineSpacing = 5.f;
    zone.interitemSpacing = 5.f;
    
    CGRect cellRect = [zone frameForItemAtIndex:0];
    CGRect expectedRect = CGRectMake(0, 0, 30, 40);
    XCTAssertTrue(CGRectEqualToRect(cellRect, expectedRect), @"Cell rect is not equal to expected rect");
    
    CGRect cellRect2 = [zone frameForItemAtIndex:3];
    CGRect expectedRect2 = CGRectMake(105, 0, 30, 40);
    XCTAssertTrue(CGRectEqualToRect(cellRect2, expectedRect2), @"Cell rect is not equal to expected rect");
}


- (void)testRectForCellWithZoneOffset {
    CGRect rect = CGRectMake(30, 65, 100, 30);
    SLTStickyLayoutItemZone *zone = [self zoneWithRect:rect];
    zone.itemSize = CGSizeMake(30, 10);
    zone.minimumLineSpacing = 5.f;
    zone.interitemSpacing = 5.f;
    
    CGRect cellRect = [zone frameForItemAtIndex:0];
    CGRect expectedRect = CGRectMake(30, 65, 30, 10);
    XCTAssertTrue(CGRectEqualToRect(cellRect, expectedRect), @"Cell rect is not equal to expected rect");
    
    CGRect cellRect2 = [zone frameForItemAtIndex:3];
    CGRect expectedRect2 = CGRectMake(65, 85, 30, 10);
    XCTAssertTrue(CGRectEqualToRect(cellRect2, expectedRect2), @"Cell rect is not equal to expected rect");
}


- (void)testZoneWidthForZeroCells {
    CGRect rect = CGRectMake(30, 65, 100, 30);
    SLTStickyLayoutItemZone *zone = [self zoneWithRect:rect];
    zone.itemSize = CGSizeMake(30, 10);
    zone.minimumLineSpacing = 5.f;
    zone.interitemSpacing = 5.f;
    zone.numberOfCells = 0;
    
    XCTAssertEqual([zone calculateZoneWidth], 0.f, @"The width of the zone should be zero if there no cell");
}

- (void)testZoneWidthForAColumn {
    CGRect rect = CGRectMake(30, 65, 100, 30);
    SLTStickyLayoutItemZone *zone = [self zoneWithRect:rect];
    zone.itemSize = CGSizeMake(30, 10);
    zone.minimumLineSpacing = 5.f;
    zone.interitemSpacing = 5.f;
    zone.numberOfCells = 1;
    
    XCTAssertEqual([zone calculateZoneWidth], 30.f, @"The width of the zone should be equal to cell's width");
}


- (void)testZoneWidthMultipleColumns {
    CGRect rect = CGRectMake(30, 65, 100, 30);
    SLTStickyLayoutItemZone *zone = [self zoneWithRect:rect];
    zone.itemSize = CGSizeMake(30, 10);
    zone.minimumLineSpacing = 5.f;
    zone.interitemSpacing = 5.f;
    zone.numberOfCells = 14;
    
    XCTAssertEqual([zone calculateZoneWidth], 240.f, @"The width of the zone should be equal to cell's width");
}


- (void)testCellIndexesInRect {
    CGRect rect = CGRectMake(30, 65, 100, 90);
    SLTStickyLayoutItemZone *zone = [self zoneWithRect:rect];
    zone.itemSize = CGSizeMake(30, 10);
    zone.minimumLineSpacing = 5.f;
    zone.interitemSpacing = 5.f;
    zone.numberOfCells = 14;
    
    NSArray *indexes = [zone indexesOfItemsInRect:CGRectMake(0, 80, 60, 80)];
    XCTAssertNotEqual([indexes count], 0, @"It should return cell indexes");
}


- (void)testCellIndexesInWrongRect {
    CGRect rect = CGRectMake(30, 65, 100, 90);
    SLTStickyLayoutItemZone *zone = [self zoneWithRect:rect];
    zone.itemSize = CGSizeMake(30, 10);
    zone.minimumLineSpacing = 5.f;
    zone.interitemSpacing = 5.f;
    zone.numberOfCells = 14;
    
    NSArray *indexes = [zone indexesOfItemsInRect:CGRectMake(0, 0, 200, 50)];
    XCTAssertEqual([indexes count], 0, @"Should return 0 because there are no cells in given rect");
}


- (void)testCellIndexesAreCorrectInRect {
    CGRect rect = CGRectMake(0, 0, 0, 90);
    SLTStickyLayoutItemZone *zone = [self zoneWithRect:rect];
    zone.itemSize = CGSizeMake(20, 20);
    zone.minimumLineSpacing = 5.f;
    zone.interitemSpacing = 5.f;
    zone.numberOfCells = 11;
    
    NSArray *indexes = [zone indexesOfItemsInRect:CGRectMake(30, 22, 65, 49)];
    NSSet *indexSet = [NSSet setWithArray:indexes];
    XCTAssertEqual([indexes count], [indexSet count], @"There should not be repetitive objects");
    
    NSSet *expectedIndexes = [NSSet setWithArray:@[@4, @5, @7, @8, @10]];

    XCTAssertTrue([indexSet isEqualToSet:expectedIndexes], @"It returned wrong indexes");
}


- (SLTStickyLayoutItemZone *)zoneWithRect:(CGRect)rect {
    return [[SLTStickyLayoutItemZone alloc] initWithZoneRect:rect];
}

@end
