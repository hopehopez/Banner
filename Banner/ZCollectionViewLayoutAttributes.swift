//
//  ZCollectionViewLayoutAttributes.swift
//  Banner
//
//  Created by zsq on 2018/3/11.
//  Copyright © 2018年 zsq. All rights reserved.
//

import UIKit

class ZCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {

    var position: CGFloat = 0
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? ZCollectionViewLayoutAttributes else {
            return false
        }
        
        var isEqual = super.isEqual(object)
        isEqual = isEqual && (position == object.position)
        return isEqual
        
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! ZCollectionViewLayoutAttributes
        copy.position = self.position
        return copy
    }
    
}
