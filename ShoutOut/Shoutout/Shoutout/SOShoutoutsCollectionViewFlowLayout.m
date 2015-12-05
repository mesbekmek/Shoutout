//
//  SOShoutoutsCollectionViewFlowLayout.m
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 12/5/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOShoutoutsCollectionViewFlowLayout.h"

@implementation SOShoutoutsCollectionViewFlowLayout
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
