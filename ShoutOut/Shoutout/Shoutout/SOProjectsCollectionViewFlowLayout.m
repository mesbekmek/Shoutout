//
//  SOProjectsCollectionViewFlowLayout.m
//  Shoutout
//
//  Created by Jason Wang on 12/2/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOProjectsCollectionViewFlowLayout.h"

@implementation SOProjectsCollectionViewFlowLayout


- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)offset
                                 withScrollingVelocity:(CGPoint)velocity {

    CGRect collectionViewBounds = self.collectionView.bounds;
    CGFloat halfWidth = collectionViewBounds.size.width * 0.5f;
    CGFloat proposedContentOffsetCenterX = offset.x + halfWidth;

    NSArray *attributesArray = [self layoutAttributesForElementsInRect:collectionViewBounds];

    UICollectionViewLayoutAttributes *candidateAttributes;
    for (UICollectionViewLayoutAttributes *attributes in attributesArray) {
        if (fabs(attributes.center.x - proposedContentOffsetCenterX) <
            fabs(candidateAttributes.center.x - proposedContentOffsetCenterX)) {
            candidateAttributes = attributes;
        }
    }

    return CGPointMake(candidateAttributes.center.x - halfWidth, offset.y);
}

@end
