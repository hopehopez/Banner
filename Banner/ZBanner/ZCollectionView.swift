//
//  ZCollectionView.swift
//  Banner
//
//  Created by zsq on 2018/3/11.
//  Copyright © 2018年 zsq. All rights reserved.
//

import UIKit

class ZCollectionView: UICollectionView {

    fileprivate var pagerView: ZBannerView? {
        return self.superview?.superview as? ZBannerView
    }
    
    #if !os(tvOS)
    override var scrollsToTop: Bool {
        set {
            super.scrollsToTop = false
        }
        get {
            return false
        }
    }
    #endif
    
    override var contentInset: UIEdgeInsets {
        set {
            super.contentInset = .zero
            if (newValue.top > 0) {
                let contentOffset = CGPoint(x:self.contentOffset.x, y:self.contentOffset.y+newValue.top);
                self.contentOffset = contentOffset
            }
        }
        get {
            return super.contentInset
        }
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    fileprivate func commonInit() {
        self.contentInset = .zero
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        if #available(iOS 10.0, *) {
            self.isPrefetchingEnabled = false
        }
        if #available(iOS 11.0, *) {
            self.contentInsetAdjustmentBehavior = .never
        }
        #if !os(tvOS)
            self.scrollsToTop = false
            self.isPagingEnabled = false
        #endif
    }

}
