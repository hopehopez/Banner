//
//  ZBannerViewLayout.swift
//  Banner
//
//  Created by zsq on 2018/3/11.
//  Copyright © 2018年 zsq. All rights reserved.
//

import UIKit

class ZBannerViewLayout: UICollectionViewLayout {

    var contentSize:CGSize = .zero
    var leadingSpacing: CGFloat = 0
    var itemSpacing: CGFloat = 0
    var isNeedsReprepare = true
    
    var collectionViewSize: CGSize = .zero
    var numberOfSections: Int = 1
    var numberOfItems: Int = 0
    var actualInteritemSpacing: CGFloat = 0
    var actualItemSize: CGSize = .zero
    
    var bannerView: ZBannerView? {
        return self.collectionView?.superview?.superview as? ZBannerView
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        guard let collectionView = self.collectionView, let bannerView = self.bannerView  else {
            return
        }
        
        guard isNeedsReprepare || collectionViewSize != collectionView.frame.size else {
            return
        }
        
        isNeedsReprepare = false
        collectionViewSize = collectionView.frame.size
        numberOfSections = bannerView.numberOfSections(in: collectionView)
        numberOfItems = bannerView.collectionView(collectionView, numberOfItemsInSection: 0)
        
        actualItemSize = {
            var size = bannerView.itemSize
            if size == .zero {
                size = collectionView.frame.size
            }
            return size
        }()
        
        actualInteritemSpacing = {
            if let transformer = bannerView.transformer {
                return transformer.proposedInteritemSpacing()
            }
            return bannerView.interitemSpacing
        }()
        
        leadingSpacing = (collectionView.frame.size.width - actualItemSize.width)/2.0
        itemSpacing = actualItemSize.width + actualInteritemSpacing
        
        contentSize = {
            let numberOfItems = self.numberOfItems * self.numberOfSections
            var contentSizeWith: CGFloat = self.leadingSpacing * 2
            contentSizeWith += CGFloat(numberOfItems - 1) * self.actualInteritemSpacing
            contentSizeWith += CGFloat(numberOfItems) * self.actualItemSize.width
            let contentSize = CGSize(width: contentSizeWith, height: collectionView.frame.height)
            return contentSize
        }()
        
        adjustCollectionViewBounds()
    }
    
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAtrributes = [UICollectionViewLayoutAttributes]()
        guard itemSpacing > 0 ,!rect.isEmpty else {
            return layoutAtrributes
        }
        
        let rect = rect.intersection(CGRect(origin: .zero, size: contentSize))
        guard !rect.isEmpty else {
            return layoutAtrributes
        }
        
        let numberOfItemsBefore = max(Int((rect.minX - leadingSpacing) / itemSpacing), 0)
        let startPositionX = leadingSpacing + CGFloat(numberOfItemsBefore) * itemSpacing
        let startIndex = numberOfItemsBefore
        var itemIndex = startIndex
        
        var originX = startPositionX
        let maxPositionX = min(rect.maxX, contentSize.width - actualItemSize.width - leadingSpacing)
        
        while originX - maxPositionX <= max(CGFloat(100.0) * .ulpOfOne * fabs(originX+maxPositionX), .leastNonzeroMagnitude) {
            let indexPath = IndexPath(item: itemIndex % numberOfItems, section: itemIndex/numberOfItems)
            let attributes = layoutAttributesForItem(at: indexPath) as! ZBannerViewLayoutAttributes
            applyTransform(to: attributes, with: bannerView?.transformer)
            layoutAtrributes.append(attributes)
            itemIndex += 1
            originX += itemSpacing
        }

        return layoutAtrributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = ZBannerViewLayoutAttributes(forCellWith: indexPath)
        
        let frame = self.frame(for: indexPath)
        let center = CGPoint(x: frame.midX, y: frame.midY)
        attributes.center = center
        attributes.size = actualItemSize
        
        return attributes
    }
    
     override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let collectionView = self.collectionView else {
            return proposedContentOffset
        }
        var proposedContentOffset = proposedContentOffset
        let proposedContentOffsetX:CGFloat = {
            let translation = -collectionView.panGestureRecognizer.translation(in: collectionView).x
            var offset:CGFloat = round(proposedContentOffset.x/itemSpacing) * itemSpacing
            let minFilppingDistance = min(0.5 * itemSpacing, 150)
            let originalContentOffSet = collectionView.contentOffset.x - translation
            if abs(translation) <= minFilppingDistance {
                if abs(velocity.x) >= 0.3 && abs(proposedContentOffset.x - originalContentOffSet) <= itemSpacing * 0.5 {
                    offset += self.itemSpacing * (velocity.x)/abs(velocity.x)
                }
            }
            return offset
        }()
        proposedContentOffset = CGPoint(x: proposedContentOffsetX, y: proposedContentOffset.y)
        
        return proposedContentOffset
    }
    
    internal func forceInvalidate() {
        isNeedsReprepare = true
        invalidateLayout()
    }
    
    func adjustCollectionViewBounds() {
        guard let collectionView = self.collectionView, let bannerView = self.bannerView else {
            return
        }
        
        let currentIndex = max(0, min(bannerView.currentIndex, bannerView.numberOfItems - 1))
        let newIndexPath = IndexPath(item: currentIndex, section: self.numberOfSections / 2)
        let contentOffset = self.contentOffSet(for: newIndexPath)
        let newBounds = CGRect(origin: contentOffset, size: collectionView.frame.size)
        collectionView.bounds = newBounds
        bannerView.currentIndex = currentIndex
        
    }
    
    func contentOffSet(for indexPath:IndexPath) -> CGPoint {
        let origin = self.frame(for: indexPath).origin
        guard let collectionView = self.collectionView else {
            return origin
        }
        
        let contentOffSetX: CGFloat = origin.x - (collectionView.frame.width * 0.5 - actualItemSize.width * 0.5)
        let contentOffSetY: CGFloat = 0
        let contentOffset = CGPoint(x: contentOffSetX, y: contentOffSetY)
        return contentOffset
    }
    
    //计算item的frame
    func frame(for indexPath: IndexPath) -> CGRect {
        let items = self.numberOfItems * indexPath.section + indexPath.item
        let originX: CGFloat = self.leadingSpacing + CGFloat(items) * itemSpacing
        let originY: CGFloat = (self.collectionView!.frame.height - self.actualItemSize.height) * 0.5
        let frame = CGRect(x: originX, y: originY, width: self.actualItemSize.width, height: self.actualItemSize.height)
        return frame
    }
    
    fileprivate func applyTransform(to attributes:ZBannerViewLayoutAttributes, with transformer: ZBannerViewTransformer?) {
        
        guard  let collectionView =  self.collectionView else {
            return
        }
        
        guard let transform = transformer else {
            return
        }
        
        let ruler = collectionView.bounds.midX
        attributes.position = (attributes.center.x - ruler) / itemSpacing
        attributes.zIndex = Int(numberOfItems) - Int(attributes.position)
        transform.applyTransform(to: attributes)
    }
    
}
