//
//  SLTStickyCollectionViewLayout.m
//  SLTStickyCollectionViewLayout
//
//  Created by Andrei Raifura on 4/1/15.
//  Copyright (c) 2015 YOPESO. All rights reserved.
//

#import "SLTStickyCollectionViewLayout.h"
#import "SLTStickyLayoutSection.h"

@interface SLTStickyCollectionViewLayout ()
@property (copy, nonatomic) NSArray *sections;

@end

@implementation SLTStickyCollectionViewLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupDefaultDimensions];
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupDefaultDimensions];
    }
    return self;
}


- (CGRect)frameForSectionAtIndex:(NSInteger)sectionIndex {
    if (sectionIndex < 0)                   return CGRectZero;
    if (sectionIndex >= [_sections count])  return CGRectZero;
    
    return [_sections[sectionIndex] sectionRect];
}


#pragma mark - Override Methods

- (void)prepareLayout {
    [super prepareLayout];
    
    NSInteger numSections = [self.collectionView numberOfSections];
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:numSections];
    for(NSInteger sectionNumber = 0; sectionNumber < numSections; sectionNumber++) {
        SLTMetrics metrics = (0 == sectionNumber) ? [self metricsForFirstSection] : [self metricsForSectionFollowingSection:[sections lastObject]];
        SLTStickyLayoutSection *section = [[SLTStickyLayoutSection alloc] initWithMetrics:metrics];
        [self configureSection:section sectionNumber:sectionNumber];
        [sections addObject:section];
    }
    
    self.sections = sections;
}


- (CGSize)collectionViewContentSize {
    SLTStickyLayoutSection *section = [self.sections lastObject];
    CGRect lastSectionRect = [section sectionRect];
    
    CGFloat width = CGRectGetMaxX(lastSectionRect) + self.sectionInset.right;
    CGFloat height = self.collectionView.bounds.size.height;
    
    return CGSizeMake(width, height);
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSSet *sections = [self sectionsIntersectingRect:rect];
    NSArray *itemIndexPaths = [self indexPathsOfItemsInSections:sections intersectingRect:rect];
    
    NSMutableArray *itemAttributes = [NSMutableArray array];
    for (NSIndexPath *indexPath in itemIndexPaths) {
        [itemAttributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    
    NSMutableArray *attributes = [NSMutableArray arrayWithArray:itemAttributes];
    
    CGRect visibleRect = rect;
    visibleRect.origin.x = self.collectionView.contentOffset.x;
    
    for (SLTStickyLayoutSection *section in sections) {
        if ([section headerIsVisibleInRect:visibleRect]) {
            CGRect headerRect = [section headerFrameForVisibleRect:visibleRect];
            UICollectionViewLayoutAttributes *headerAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                      atIndexPath:[section headerIndexPath]];
            [headerAttributes setFrame:headerRect];
            [attributes addObject:headerAttributes];
        }
        
        if ([section footerIsVisibleInRect:visibleRect]) {
            CGRect footerRect = [section footerFrameForVisibleRect:visibleRect];
            UICollectionViewLayoutAttributes *footerAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                                      atIndexPath:[section footerIndexPath]];
            [footerAttributes setFrame:footerRect];
            [attributes addObject:footerAttributes];
        }
    }
    
    return attributes;
}


- (NSArray *)indexPathsOfItemsInSections:(NSSet *)sections intersectingRect:(CGRect)rect {
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    for (SLTStickyLayoutSection *section in sections) {
        [indexPaths addObjectsFromArray:[section indexPathsOfItemsInRect:rect]];
    }
    
    return [NSArray arrayWithArray:indexPaths];
}


- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    SLTStickyLayoutSection *section = self.sections[indexPath.section];
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = [section frameForItemAtIndex:indexPath.row];
    
    return attributes;
}


- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    return [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
}


// return YES to cause the collection view to requery the layout for geometry information
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
    //    CGFloat oldWidth = self.collectionView.bounds.size.width;
    //    return (oldWidth != newBounds.size.width);
}


#pragma mark - Private Methods

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


- (void)configureSection:(SLTStickyLayoutSection *)section sectionNumber:(NSInteger)sectionNumber {
    section.sectionNumber = sectionNumber;
    section.numberOfCells = [self.collectionView numberOfItemsInSection:sectionNumber];
    section.itemSize = _itemSize;
    section.minimumLineSpacing = _minimumLineSpacing;
    section.minimumInteritemSpacing = _interitemSpacing;
    section.distanceBetweenHeaderAndCells = _distanceBetweenHeaderAndItems;
    section.distanceBetweenFooterAndCells = _distanceBetweenFooterAndItems;
    section.headerHeight = [self headerHeightForSectionWithSectionNumber:sectionNumber];
    section.footerHeight = [self footerHeightForSectionWithSectionNumber:sectionNumber];
    section.headerContentWidth = [self headerContentWidthForSectionWithSectionNumber:sectionNumber];
    section.footerContentWidth = [self footerContentWidthForSectionWithSectionNumber:sectionNumber];
    section.headerInset = _sectionInset.left;
    [section prepareIntermediateMetrics];
}


- (CGFloat)headerHeightForSectionWithSectionNumber:(NSInteger)sectionNumber {
    SEL selector = @selector(collectionView:layout:headerHeightInSection:);
    
    if ([self.delegate respondsToSelector:selector]) {
        return [self.delegate collectionView:self.collectionView
                                      layout:self
                       headerHeightInSection:sectionNumber];
    } else {
        return _headerReferenceHeight;
    }
}


- (CGFloat)footerHeightForSectionWithSectionNumber:(NSInteger)sectionNumber {
    SEL selector = @selector(collectionView:layout:footerHeightInSection:);
    
    if ([self.delegate respondsToSelector:selector]) {
        return [self.delegate collectionView:self.collectionView
                                      layout:self
                       footerHeightInSection:sectionNumber];
    } else {
        return _footerReferenceHeight;
    }
}


- (CGFloat)headerContentWidthForSectionWithSectionNumber:(NSInteger)sectionNumber {
    SEL selector = @selector(collectionView:layout:headerContentWidthInSection:);
    
    if ([self.delegate respondsToSelector:selector]) {
        return [self.delegate collectionView:self.collectionView
                                      layout:self
                 headerContentWidthInSection:sectionNumber];
    } else {
        return _headerReferenceContentWidth;
    }
}


- (CGFloat)footerContentWidthForSectionWithSectionNumber:(NSInteger)sectionNumber {
    SEL selector = @selector(collectionView:layout:footerContentWidthInSection:);
    
    if ([self.delegate respondsToSelector:selector]) {
        return [self.delegate collectionView:self.collectionView
                                      layout:self
                 footerContentWidthInSection:sectionNumber];
    } else {
        return _footerReferenceContentWidth;
    }
}


- (SLTMetrics)metricsForFirstSection {
    CGSize collectionViewSize = self.collectionView.bounds.size;
    UIEdgeInsets insets = self.sectionInset;
    
    CGFloat xOrigin = insets.left;
    CGFloat yOrigin = insets.top;
    CGFloat height = collectionViewSize.height - insets.top - insets.bottom;
    
    return SLTMetricsMake(xOrigin, yOrigin, height);
}


- (SLTMetrics)metricsForSectionFollowingSection:(SLTStickyLayoutSection *)section {
    CGRect previousSectionRect = [section sectionRect];
    
    CGSize collectionViewSize = self.collectionView.bounds.size;
    UIEdgeInsets insets = self.sectionInset;
    
    CGFloat lastXPosition = CGRectGetMaxX(previousSectionRect);
    CGFloat xOrigin = lastXPosition + insets.right + self.interSectionSpacing + insets.left;
    CGFloat yOrigin = insets.top;
    CGFloat height = collectionViewSize.height - insets.top - insets.bottom;
    
    return SLTMetricsMake(xOrigin, yOrigin, height);
}


- (NSSet *)sectionsIntersectingRect:(CGRect)rect {
    NSMutableSet *intersectingSections = [[NSMutableSet alloc] init];
    
    for (SLTStickyLayoutSection *section in self.sections) {
        if (CGRectIntersectsRect([section sectionRect], rect)) {
            [intersectingSections addObject:section];
        }
    }
    
    return [NSSet setWithSet:intersectingSections];
}

@end