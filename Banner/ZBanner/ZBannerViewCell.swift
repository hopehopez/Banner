//
//  ZCollectionViewCell.swift
//  Banner
//
//  Created by zsq on 2018/3/11.
//  Copyright © 2018年 zsq. All rights reserved.
//

import UIKit

class ZBannerViewCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        self.contentView.addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
}
