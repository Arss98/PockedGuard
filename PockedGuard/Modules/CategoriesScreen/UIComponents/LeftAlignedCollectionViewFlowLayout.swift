//
//  LeftAlignedCollectionViewFlowLayout.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 20.09.2025.
//

import UIKit

final class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    private let itemsPerRow: CGFloat = 5
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView: UICollectionView = collectionView else { return }
        
        let totalPadding: CGFloat = sectionInset.left + sectionInset.right
        let totalSpacing: CGFloat = minimumInteritemSpacing * (itemsPerRow - 1)
        let availableWidth: CGFloat = collectionView.bounds.width - totalPadding - totalSpacing
        
        guard availableWidth > 0 else { return }
        
        let itemWidth: CGFloat = availableWidth / itemsPerRow
        itemSize = CGSize(width: itemWidth, height: itemWidth)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin: CGFloat = sectionInset.left
        var maxY: CGFloat = -1.0
        
        attributes?.forEach { layoutAttribute in
            guard layoutAttribute.representedElementCategory == .cell else { return }
            
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        
        return attributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
