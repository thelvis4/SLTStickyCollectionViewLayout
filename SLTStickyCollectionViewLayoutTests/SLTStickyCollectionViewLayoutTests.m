//
//  SLTStickyCollectionViewLayoutTests.m
//  SLTStickyCollectionViewLayout
//
//  Created by Andrei Raifura on 4/3/15.
//  Copyright (c) 2015 YOPESO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "OCMock.h"
#import "SLTStickyCollectionViewLayout.h"

static NSInteger const SLTNumberOfSections = 10;

@interface SLTStickyCollectionViewLayoutTests : XCTestCase
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) SLTStickyCollectionViewLayout *layout;

@end

@implementation SLTStickyCollectionViewLayoutTests

- (void)setUp {
    [super setUp];
    self.layout = [self createLayout];
    
    self.collectionView = [self createFakeCollectionView];
    [self.layout setValue:self.collectionView forKey:@"collectionView"];
    
    self.layout.delegate = [self createFakeDelegate];
    [self.layout prepareLayout];
}


- (void)tearDown {
    self.layout = nil;
    self.collectionView = nil;
    
    [super tearDown];
}


- (void)testLayoutReturnCorrectAttributes {
    CGSize size = [self.layout collectionViewContentSize];
    XCTAssert(CGSizeEqualToSize(size, CGSizeMake(13330, 176)), @"CollectionView size is not calculated correctly.");
    
    NSArray *array = [self.layout layoutAttributesForElementsInRect:CGRectMake(0, 0, 568, 568)];
    XCTAssertNotEqual([array count], 0, @"It should return some attributes");
    
    NSIndexPath *itemIndexPath = [NSIndexPath indexPathForItem:10 inSection:0];
    UICollectionViewLayoutAttributes *itemAttributes = [self.layout layoutAttributesForItemAtIndexPath:itemIndexPath];
    XCTAssert(CGRectEqualToRect(itemAttributes.frame, CGRectMake(375, 22, 70, 70)), @"Frame of item is not calculated correctly");
    
    NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes *headerAttributes = [self headerAttributesInArray:array indexPath:headerIndexPath];
    XCTAssertNotNil(headerAttributes, @"There should be header attributes.");
    XCTAssert(CGRectEqualToRect(headerAttributes.frame, CGRectMake(0, 0, 131, 22)), @"Frame of the header is not calculated correctly");
}


- (void)testLayoutDoesNotReachInfiniteLoop {
    OCMStub([self.collectionView bounds]).andReturn(CGRectMake(0, 0, 320, 157));
    NSArray *array = [self.layout layoutAttributesForElementsInRect:CGRectMake(0, 0, 568, 568)];
    
    XCTAssertNotEqual([array count], 0, @"It should return some attributes");
}


- (void)testTargetOffsetWhenScrollingNotOptimized {
    self.layout.optimizedScrolling = NO;
    CGPoint proposedOffset = CGPointMake(220.f, 0.f);
    CGPoint returnedOffset = [self.layout targetContentOffsetForProposedContentOffset:proposedOffset withScrollingVelocity:CGPointZero];
    
    XCTAssert(CGPointEqualToPoint(proposedOffset, returnedOffset), @"Target offset should match proposed offset.");
}


- (void)testWhenProposedOffsetIsBetweenSections {
    [self runTestForTargetOffsetWithProposedOffset:CGPointMake(7764.f, 0.f)
                                    expectedOffset:CGPointMake(7785.f, 0.f)];
}


- (void)testWhenProposedOffsetIsAtTheEnd {
    [self runTestForTargetOffsetWithProposedOffset:CGPointMake(10409.f, 0.f)
                                    expectedOffset:CGPointMake(10409.f, 0.f)];
}


- (void)testTargetContentOffsetWhenProposedOffsetDoesNotMatchTargetOffset {
    [self runTestForTargetOffsetWithProposedOffset:CGPointMake(455.f, 0.f)
                                    expectedOffset:CGPointMake(465.f, 0.f)];

}


- (void)testTargetContentOffsetWithBigTargetOffset {
    [self runTestForTargetOffsetWithProposedOffset:CGPointMake(10180.f, 0.f)
                                    expectedOffset:CGPointMake(10215.f, 0.f)];
}


- (void)testTargetContentOffsetWhenPreviousItemShouldBeTaken {
    [self runTestForTargetOffsetWithProposedOffset:CGPointMake(419.f, 0.f)
                                    expectedOffset:CGPointMake(375.f, 0.f)];
}


- (void)testTargetContentOffsetWhenProposedOffsetMatchesTargetOffset {
    CGPoint proposedOffset = CGPointMake(300.f, 0.f);
    [self runTestForTargetOffsetWithProposedOffset:proposedOffset
                                    expectedOffset:proposedOffset];
}


#pragma mark - Performance tests

- (void)testScrollingPerformance {
    [self measureBlock:^{
        [self simulateScrolling];
    }];
}


#pragma mark - Private Methods

- (void)simulateScrolling {
    CGFloat startX = 0;
    CGFloat lastX = 9000;
    for (CGFloat offset = startX; offset < lastX; offset+=2.) {
        if ([self.layout shouldInvalidateLayoutForBoundsChange:CGRectMake(0, 0, 320, 176)]) {
            [self.layout prepareLayout];
            [self.layout layoutAttributesForElementsInRect:CGRectMake(offset, 0, 568, 568)];
        }
    }
    
    for (CGFloat offset = startX; offset < lastX; offset+=200.f) {
        [self.layout targetContentOffsetForProposedContentOffset:CGPointMake(offset, 0.f)
                                           withScrollingVelocity:CGPointZero];
    }
}


- (UICollectionViewLayoutAttributes *)headerAttributesInArray:(NSArray *)array indexPath:(NSIndexPath *)indexPath {
    for (UICollectionViewLayoutAttributes *attributes in array) {
        if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            if ([attributes.indexPath isEqual:indexPath]) {
                return attributes;
            }
        }
    }
    
    return nil;
}


- (SLTStickyCollectionViewLayout *)createLayout {
    SLTStickyCollectionViewLayout *layout = [[SLTStickyCollectionViewLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 2.0, 0);
    layout.itemSize = CGSizeMake(70.0, 70.0);
    layout.headerReferenceHeight = 22.0;
    layout.interSectionSpacing = 20.0;
    layout.minimumLineSpacing = 10.0;
    layout.interitemSpacing = 5.0;
    
    return layout;
}


- (UICollectionView *)createFakeCollectionView {
    UICollectionView *mock = OCMClassMock([UICollectionView class]);
    OCMStub([mock bounds]).andReturn(CGRectMake(0, 0, 320, 176));
    OCMStub([mock contentOffset]).andReturn(CGPointMake(0, 0));
    OCMStub([mock contentSize]).andReturn(CGSizeMake(10730, 176));
    OCMStub([mock numberOfSections]).andReturn(SLTNumberOfSections);
    
    for (NSInteger section = 0; section < SLTNumberOfSections; section++) {
        OCMStub([mock numberOfItemsInSection:section]).andReturn([self numberOfItemsForSection:section]);
    }
    
    return mock;
}


- (id<SLTStickyCollectionViewLayoutDelegate>)createFakeDelegate {
    id<SLTStickyCollectionViewLayoutDelegate> mock = OCMProtocolMock(@protocol(SLTStickyCollectionViewLayoutDelegate));
    SLTStickyCollectionViewLayout *layout = self.layout;
    UICollectionView *collectionView = self.collectionView;
    
    for (NSInteger section = 0; section < SLTNumberOfSections; section++) {
        OCMStub([mock collectionView:collectionView layout:layout headerContentWidthInSection:section]).andReturn([self headerWidthForSection:section]);
        OCMStub([mock collectionView:collectionView layout:layout headerHeightInSection:section]).andReturn(22.f);
        OCMStub([mock collectionView:collectionView layout:layout footerContentWidthInSection:section]).andReturn(0);
        OCMStub([mock collectionView:collectionView layout:layout footerHeightInSection:section]).andReturn(0);
    }
    
    return mock;
}


- (NSInteger)numberOfItemsForSection:(NSInteger)section {
    switch (section) {
        case 0: return 12;
        case 1: return 144;
        case 2: return 27;
        case 3: return 22;
        case 4: return 28;
        case 5: return 23;
        case 6: return 25;
        case 7: return 18;
        case 8: return 25;
        case 9: return 24;
    }
    
    return 0;
}


- (CGFloat)headerWidthForSection:(NSInteger)section {
    switch (section) {
        case 0: return 131.0;
        case 1: return 169.0;
        case 2: return 53.0;
        case 3: return 89.0;
        case 4: return 74.0;
        case 5: return 106.0;
        case 6: return 97.0;
        case 7: return 60.0;
        case 8: return 65.0;
        case 9: return 320.0;
    }
    
    return 0;
}


- (void)runTestForTargetOffsetWithProposedOffset:(CGPoint)proposedOffset expectedOffset:(CGPoint)expectedOffset {
    self.layout.optimizedScrolling = YES;
    CGPoint returnedOffset = [self.layout targetContentOffsetForProposedContentOffset:proposedOffset withScrollingVelocity:CGPointZero];
    
    XCTAssert(CGPointEqualToPoint(expectedOffset, returnedOffset), @"Target offset is not correct.");
}

@end
