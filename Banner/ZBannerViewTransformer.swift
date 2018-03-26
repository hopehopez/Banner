//
//  ZBannerViewTransformer.swift
//  Banner
//
//  Created by zsq on 2018/3/13.
//  Copyright © 2018年 zsq. All rights reserved.
//

import UIKit
enum ZBannerViewTransformerTpye: Int {
    case none
    case linear
    case overlap
}

class ZBannerViewTransformer: NSObject {

    weak var bannerView: ZBannerView?
    var type: ZBannerViewTransformerTpye
    
    var minimumScale: CGFloat = 0.65
    
    public init(type: ZBannerViewTransformerTpye) {
        self.type = type
    }
    
    func applyTransform(to attributes:ZBannerViewLayoutAttributes){
        guard bannerView != nil else {
            return
        }
        
        let position = attributes.position
        let scale = max(1 - (1-minimumScale) * abs(position), minimumScale)
        var transform = CGAffineTransform(scaleX: scale, y: scale)
        var x: CGFloat = 0.0
        if position > 0 {
            x = position * 100.0
        } else {
            x = position * 80.0
        }
        
        if x > 50 {
            x = 50
        } else if x < -50 {
            x = -50
        }
        transform = CGAffineTransform.translatedBy(transform)(x: x, y: 0)
        attributes.transform = transform
        let zIndex = (1 - abs(position)) * 10
        attributes.zIndex = Int(zIndex)
        
    }
    
    
    func proposedInteritemSpacing() -> CGFloat {
        guard let bannerView = bannerView  else {
            return 0
        }
        
//        switch type {
//        case .none:
//            return 0
//        case .linear:
//            return -bannerView.itemSize.width * minimumScale * 0.2
//        case .overlap:
            return -bannerView.itemSize.width * minimumScale * 0.6
            
//        }
    }
}
