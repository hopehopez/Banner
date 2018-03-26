//
//  ViewController.swift
//  Banner
//
//  Created by zsq on 2018/3/11.
//  Copyright © 2018年 zsq. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var bannerView: ZBannerView!{
        didSet{
            self.bannerView.register(cellClass: ZBannerViewCell.self, forCellWithReuseIdentifier: "cell")
            
            
        }
    }
    
    @IBOutlet weak var testView: UIView!
    fileprivate let imageNames = ["1.jpg","2.jpg","3.jpg","4.jpg","5.jpg","6.jpg","7.jpg"]
    fileprivate var numberOfItems = 7
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        bannerView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        testView.bounds = CGRect(x: 50, y: 0, width: 100, height: 50)
        self.bannerView.transformer = ZBannerViewTransformer.init(type: .overlap)
        let transform = CGAffineTransform(scaleX: 0.7, y: 1.0)
        self.bannerView.itemSize = self.bannerView.frame.size.applying(transform)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: ZBannerViewDataSource, ZBannerViewDelegate{
    func numberOfItems(in pagerView: ZBannerView) -> Int {
        return numberOfItems
    }
    
    func bannerView(_ bannerView: ZBannerView, cellForItemAt index: Int) -> ZBannerViewCell {
        let cell = bannerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        let image = UIImage.init(named: imageNames[index])
        
        cell.imageView.image = image
        return cell
        
    }
    
    func bannerView(_ bannerView: ZBannerView, didSelectItemAt index: Int) {
        
    }
}

