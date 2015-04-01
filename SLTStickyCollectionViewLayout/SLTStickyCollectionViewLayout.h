//
//  SLTStickyCollectionViewLayout.h
//  SLTStickyCollectionViewLayout
//
//  Created by Andrei Raifura on 4/1/15.
//  Copyright (c) 2015 YOPESO. All rights reserved.
//

// Version 1.0 Beta 2

#import <UIKit/UIKit.h>
@class SLTStickyCollectionViewLayout;

@protocol SLTStickyCollectionViewLayoutDelegate <NSObject>
@optional
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SLTStickyCollectionViewLayout *)layout headerContentWidthInSection:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SLTStickyCollectionViewLayout *)layout footerContentWidthInSection:(NSInteger)section;

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SLTStickyCollectionViewLayout *)layout headerHeightInSection:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SLTStickyCollectionViewLayout *)layout footerHeightInSection:(NSInteger)section;

@end


@interface SLTStickyCollectionViewLayout : UICollectionViewLayout
@property (weak, nonatomic) id<SLTStickyCollectionViewLayoutDelegate> delegate;

/// @note Default: (50.0, 50.0)
@property (assign, nonatomic) CGSize itemSize;

/**
 The minimum distance between 2 lines. The actual distance might differ
 depending on the available vertical space.
 
 @note Default: 10.0
 */
@property (nonatomic) CGFloat minimumLineSpacing;
/**
 The horizontal distance between 2 items.
 
 @note Default: 10.0
 */
@property (nonatomic) CGFloat interitemSpacing;

/**
 If the delegate method isn't implemented, this value determines the height of
 the headers for all sections.
 
 @see collectionView:layout:headerHeightInSection: delegate method.

 @note Default: 0.0
 */
@property (nonatomic) CGFloat headerReferenceHeight;
/**
 If the delegate method isn't implemented, this value determines the height of
 the footers for all sections.
 
 @see collectionView:layout:footerHeightInSection: delegate method.
 
 @note Default: 0.0
 */
@property (nonatomic) CGFloat footerReferenceHeight;

/**
 If the delegate method isn't implemented, this value determines the width of
 the header for all sections.
 
 @see collectionView:layout:headerContentWidthInSection: delegate method.
 
 @note Default: 0.0
 */
@property (nonatomic) CGFloat headerReferenceContentWidth;
/**
 If the delegate method isn't implemented, this value determines the width of
 the footer for all sections.
 
 @see collectionView:layout:footerContentWidthInSection: delegate method.
 
 @note Default: 0.0
 */
@property (nonatomic) CGFloat footerReferenceContentWidth;

/// @note Default: (top=0.0, left=5.0, bottom=0.0, right=5.0)
@property (nonatomic) UIEdgeInsets sectionInset;
/**
 An additional space between sections. Ussualy the distance between sections
 is defined by section insets. This value will be used in case the distance
 should be adjusted.
 It may take positive (distance get bigger) or negative(distance get smaller)
 values.
 
 @note Default: 0.0
 */
@property (nonatomic) CGFloat interSectionSpacing;

/// @note Default: 0.0
@property (nonatomic) CGFloat distanceBetweenHeaderAndItems;
/// @note Default: 0.0
@property (nonatomic) CGFloat distanceBetweenFooterAndItems;

- (CGRect)frameForSectionAtIndex:(NSInteger)sectionIndex;

@end
