//
//  SLTStickyCollectionViewLayout.m
//  SLTStickyCollectionViewLayout
//
//  Created by Andrei Raifura on 4/1/15.
//  Copyright (c) 2015 YOPESO. All rights reserved.
//

#import "SLTStickyCollectionViewLayout.h"
#import "SLTStickyLayoutSection.h"
#import "SLTUtils.h"
#import "NSArray+Additions.h"

@interface SLTStickyCollectionViewLayout ()
@property (nonatomic) NSMutableArray *sections;
@property (nonatomic) BOOL needsSectionInitialization;
@end

@implementation SLTStickyCollectionViewLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setInitialValues];
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setInitialValues];
    }
    return self;
}


- (CGRect)frameForSectionAtIndex:(NSUInteger)sectionIndex {
    if (![_sections containsObjectAtIndex:sectionIndex]) {
        [self initializeSections];
    }
    
    return [_sections[sectionIndex] sectionRect];
}


- (void)updateLayout {
    _needsSectionInitialization = YES;
    [self invalidateLayout];
}


#pragma mark - Override Methods

- (void)prepareLayout {
    [super prepareLayout];
    
    if (_needsSectionInitialization) {
        [self initializeSections];
    }
}


- (CGSize)collectionViewContentSize {
    CGFloat width = [self lastXPosition] + self.sectionInset.right;
    CGFloat height = CGRectGetHeight(self.collectionView.bounds);
    
    return CGSizeMake(width, height);
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *sections = [self sectionsIntersectingRect:rect];
    NSMutableArray *attributes = [NSMutableArray arrayWithCapacity:300];
    CGRect rectForSuplimentaryViews = [self rectWithVisibleLeftEdgeForRect:rect];
    
    for (SLTStickyLayoutSection *section in sections) {
        [attributes addObjectsFromArray:[section layoutAttributesForItemsInRect:rect]];
        
        if ([section hasHeaderInRect:rectForSuplimentaryViews]) {
            [attributes addObject:[section layoutAttributesForHeaderInRect:rectForSuplimentaryViews]];
        }
        
        if ([section hasFooterInRect:rectForSuplimentaryViews]) {
            [attributes addObject:[section layoutAttributesForFooterInRect:rectForSuplimentaryViews]];
        }
    }
    
    return attributes;
}


- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    SLTStickyLayoutSection *section = _sections[(NSUInteger)indexPath.section];
    
    return [section layoutAttributesForItemAtIndex:indexPath.row];
}


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    _needsSectionInitialization = !CGSizeEqualToSize(newBounds.size, self.collectionView.bounds.size);
    
    return YES;
}


- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    if (!_optimizedScrolling) return proposedContentOffset;
    if (![self shouldOptimizeScrollingForProposedOffset:proposedContentOffset]) return proposedContentOffset;
    
    CGFloat expectedItemPosition = proposedContentOffset.x + _sectionInset.left;
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    
    for (NSUInteger index = 0; index < numberOfSections; index++) {
        SLTStickyLayoutSection *section = _sections[index];
        if ([self proposedXOffset:expectedItemPosition shouldScrollInsideOfSection:section]) {
            CGFloat xOffset = [section offsetForNearestColumnToOffset:expectedItemPosition];
            
            return [self makeTargetOffsetWithProposedOffset:proposedContentOffset calculatedXOffset:xOffset];
        }
        if (index == numberOfSections - 1) continue;
        
        BOOL offsetIsBetweenSections = [self isXPosition:expectedItemPosition
                                          betweenSection:_sections[index]
                                              andSection:_sections[index + 1]];
        if (!offsetIsBetweenSections) continue;
        
        CGFloat firstXTarget = [_sections[index] offsetForNearestColumnToOffset:expectedItemPosition];
        CGFloat secondXTarget = [_sections[index + 1] offsetForNearestColumnToOffset:expectedItemPosition];
        CGFloat xOffset = SLTNearestNumberToReferenceNumber(firstXTarget, secondXTarget, expectedItemPosition);
        
        return [self makeTargetOffsetWithProposedOffset:proposedContentOffset calculatedXOffset:xOffset];
    }
    
    return proposedContentOffset;
}


#pragma mark - Private Methods

- (void)setInitialValues {
    _needsSectionInitialization = YES;
    [self setupDefaultDimensions];
}


- (void)setupDefaultDimensions {
    _itemSize = CGSizeMake(50.f, 50.f);
    _minimumLineSpacing = 10.f;
    _interitemSpacing = 10.f;
    
    _headerReferenceHeight = 0.f;
    _footerReferenceHeight = 0.f;
    
    _headerReferenceContentWidth = 0.f;
    _footerReferenceContentWidth = 0.f;
    
    _sectionInset = UIEdgeInsetsMake(0.f, 5.f, 0.f, 5.f);
    _interSectionSpacing = 0.f;
    
    _distanceBetweenHeaderAndItems = 0.f;
    _distanceBetweenFooterAndItems = 0.f;
}


- (void)initializeSections {
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    
    _sections = [NSMutableArray arrayWithCapacity:(NSUInteger)numberOfSections];
    
    for(NSInteger index = 0; index < numberOfSections; index++) {
        SLTMetrics metrics = [self metricsForSectionAtIndex:index];
        SLTStickyLayoutSection *section = [self instantiateSectionAtIndex:index withMetrics:metrics];
        [_sections addObject:section];
    }
    
    if ([self.delegate respondsToSelector:@selector(collectionView:didFinishUpdateLayout:)]) {
        [self.delegate collectionView:self.collectionView didFinishUpdateLayout:self];
    }
}


- (SLTStickyLayoutSection *)instantiateSectionAtIndex:(NSInteger)index withMetrics:(SLTMetrics)metrics {
    SLTStickyLayoutSection *section = [[SLTStickyLayoutSection alloc] initWithMetrics:metrics];
    section.sectionIndex = index;
    section.itemSize = _itemSize;
    section.minimumLineSpacing = _minimumLineSpacing;
    section.interitemSpacing = _interitemSpacing;
    section.distanceBetweenHeaderAndItems = _distanceBetweenHeaderAndItems;
    section.distanceBetweenFooterAndItems = _distanceBetweenFooterAndItems;
    section.headerInset = _sectionInset.left;
    
    section.numberOfItems = [self.collectionView numberOfItemsInSection:index];
    
    section.headerHeight = [self headerHeightForSectionAtIndex:index];
    section.footerHeight = [self footerHeightForSectionAtIndex:index];
    section.headerContentWidth = [self headerContentWidthForSectionAtIndex:index];
    section.footerContentWidth = [self footerContentWidthForSectionAtIndex:index];
    [section prepareIntermediateMetrics];
    
    return section;
}


- (CGFloat)headerHeightForSectionAtIndex:(NSInteger)sectionIndex {
    SEL selector = @selector(collectionView:layout:headerHeightInSection:);
    
    if ([self.delegate respondsToSelector:selector]) {
        return [self.delegate collectionView:self.collectionView
                                      layout:self
                       headerHeightInSection:sectionIndex];
    } else {
        return _headerReferenceHeight;
    }
}


- (CGFloat)footerHeightForSectionAtIndex:(NSInteger)sectionIndex {
    SEL selector = @selector(collectionView:layout:footerHeightInSection:);
    
    if ([self.delegate respondsToSelector:selector]) {
        return [self.delegate collectionView:self.collectionView
                                      layout:self
                       footerHeightInSection:sectionIndex];
    } else {
        return _footerReferenceHeight;
    }
}


- (CGFloat)headerContentWidthForSectionAtIndex:(NSInteger)sectionIndex {
    SEL selector = @selector(collectionView:layout:headerContentWidthInSection:);
    
    if ([self.delegate respondsToSelector:selector]) {
        return [self.delegate collectionView:self.collectionView
                                      layout:self
                 headerContentWidthInSection:sectionIndex];
    } else {
        return _headerReferenceContentWidth;
    }
}


- (CGFloat)footerContentWidthForSectionAtIndex:(NSInteger)sectionIndex {
    SEL selector = @selector(collectionView:layout:footerContentWidthInSection:);
    
    if ([self.delegate respondsToSelector:selector]) {
        return [self.delegate collectionView:self.collectionView
                                      layout:self
                 footerContentWidthInSection:sectionIndex];
    } else {
        return _footerReferenceContentWidth;
    }
}


- (NSArray *)sectionsIntersectingRect:(CGRect)rect {
    NSMutableArray *intersectingSections = [NSMutableArray array];
    
    for (SLTStickyLayoutSection *section in _sections) {
        if (CGRectIntersectsRect([section sectionRect], rect)) {
            [intersectingSections addObject:section];
        }
    }
    
    return intersectingSections;
}


- (CGRect)rectWithVisibleLeftEdgeForRect:(CGRect)rect {
    return CGRectFromRectWithX(rect, self.collectionView.contentOffset.x);
}


- (BOOL)shouldOptimizeScrollingForProposedOffset:(CGPoint)proposedContentOffset {
    return (proposedContentOffset.x <= [self lastXContentOffset] - _itemSize.width / 2 - _sectionInset.right);
}


- (CGPoint)makeTargetOffsetWithProposedOffset:(CGPoint)proposedOffset calculatedXOffset:(CGFloat)calculatedX {
    return CGPointMake(calculatedX - _sectionInset.left, proposedOffset.y);
}


- (BOOL)proposedXOffset:(CGFloat)offset shouldScrollInsideOfSection:(SLTStickyLayoutSection *)section {
    CGFloat firstSectionX = section.metrics.x;
    CGFloat lastSectionX = [self lastXOffsetScrollingInsideOfSection:section];
    
    return SLTFloatIsBetweenFloats(offset, firstSectionX, lastSectionX);
}


- (BOOL)isXPosition:(CGFloat)offset betweenSection:(SLTStickyLayoutSection *)firstSection andSection:(SLTStickyLayoutSection *)secondSection {
    CGFloat lastX = [self lastXOffsetScrollingInsideOfSection:firstSection];
    
    return SLTFloatIsBetweenFloats(offset, lastX, secondSection.metrics.x);
}


- (CGFloat)lastXOffsetScrollingInsideOfSection:(SLTStickyLayoutSection *)section {
    return CGRectGetMaxX([section sectionRect]) - (_itemSize.width / 2);
}


- (CGFloat)lastXContentOffset {
    return self.collectionView.contentSize.width - CGRectGetWidth(self.collectionView.bounds);
}


#pragma mark - Metrics

- (SLTMetrics)metricsForSectionAtIndex:(NSInteger)sectionIndex {
    CGSize collectionViewSize = self.collectionView.bounds.size;
    UIEdgeInsets insets = _sectionInset;
    
    CGFloat xOrigin = [self xOriginForSectionAtIndex:sectionIndex];
    CGFloat yOrigin = insets.top;
    CGFloat height = collectionViewSize.height - insets.top - insets.bottom;
    
    return SLTMetricsMake(xOrigin, yOrigin, height);
}


- (CGFloat)xOriginForSectionAtIndex:(NSInteger)sectionIndex {
    if (0 == sectionIndex) {
        return _sectionInset.left;
    } else {
        return [self lastXPosition] + [self distanceBetweenSections];
    }
}


- (CGFloat)lastXPosition {
    SLTStickyLayoutSection *section = [_sections lastObject];
    CGRect previousSectionRect = [section sectionRect];
    
    return CGRectGetMaxX(previousSectionRect);
}


- (CGFloat)distanceBetweenSections {
    return _sectionInset.right + _interSectionSpacing + _sectionInset.left;
}

@end