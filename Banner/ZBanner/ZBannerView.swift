//
//  ZBannerView.swift
//  Banner
//
//  Created by zsq on 2018/3/11.
//  Copyright © 2018年 zsq. All rights reserved.
//

import UIKit

@objc
protocol ZBannerViewDataSource: NSObjectProtocol {
    
    @objc(numberOfItemsInPagerView:)
    func numberOfItems(in pagerView: ZBannerView) -> Int
    
    @objc(bannerView:CellForItemAtIndex:)
    func bannerView(_ bannerView: ZBannerView, cellForItemAt index: Int) -> ZBannerViewCell
    
    
}

@objc
protocol ZBannerViewDelegate: NSObjectProtocol {
    @objc(bannerView:didSeclectedAtIndex:)
    optional func bannerView(_ bannerView: ZBannerView, didSelectItemAt index:Int)
    
    @objc(bannerViewDidScroll:)
    optional func bannerViewDidScroll(_ bannerView: ZBannerView)
    
}


class ZBannerView: UIView {

    @IBOutlet weak var dataSource: ZBannerViewDataSource?
    @IBOutlet weak var delegate: ZBannerViewDelegate?
    
    private weak var contentView: UIView!
    private weak var collectionVeiw: ZCollectionView!
    private weak var collectionViewLayout: ZBannerViewLayout!
    
    private var timer: Timer?
    
     var numberOfItems = 0
     var numberOfSetions = 0
    fileprivate var dequeingSection = 0
    
    var currentIndex: Int = 0
    
    open var itemSize: CGSize = .zero {
        didSet {
            self.collectionViewLayout.forceInvalidate()
        }
    }
    ///内部item间的间距
    open var interitemSpacing: CGFloat = 0 {
        didSet {
            self.collectionViewLayout.forceInvalidate()
        }
    }
    
    var transformer: ZBannerViewTransformer? {
        didSet {
            self.transformer?.bannerView = self
            self.collectionViewLayout.forceInvalidate()
        }
    }
    
    var scollOffSet: CGFloat {
        let contentOffSet = self.collectionVeiw.contentOffset.x
        let scrollOffSet = contentOffSet / collectionViewLayout.itemSpacing
        return fmod(scrollOffSet, CGFloat(numberOfItems))
    }
    
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        let contentView = UIView.init(frame: .zero)
        contentView.backgroundColor = UIColor.clear
        addSubview(contentView)
        self.contentView = contentView
        
        let layout = ZBannerViewLayout()
        let collectionView = ZCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.orange
        collectionView.alwaysBounceHorizontal = false
        collectionView.alwaysBounceVertical = false
//        collectionView.isPagingEnabled = true
        self.contentView.addSubview(collectionView)
        self.collectionVeiw = collectionView
        self.collectionViewLayout = layout
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            startTimer()
        } else {
            cancelTimer()
        }
    }
    
    func startTimer() {
//        guard timer == nil else {
//            return
//        }
//        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(flipNext), userInfo: nil, repeats: true)
//        RunLoop.main.add(timer!, forMode: .commonModes)
    }
    
    fileprivate func cancelTimer() {
        guard self.timer != nil else {
            return
        }
        self.timer!.invalidate()
        self.timer = nil
    }
    
    @objc func flipNext() {
        guard let _ = superview, let _ = window, numberOfItems > 0 else {
            return
        }
        
        let contentOffSet: CGPoint = {
            let indexPath = self.centermostIndexPath()
            let section = indexPath.section + (indexPath.item + 1) / self.numberOfItems
            let item = (indexPath.item + 1) % self.numberOfItems
            let nextIndexPath = IndexPath(item: item, section: section)
            return self.collectionViewLayout.contentOffSet(for: nextIndexPath)
        }()
        self.collectionVeiw.setContentOffset(contentOffSet, animated: true)
    }
    
    func centermostIndexPath() -> IndexPath {
        guard numberOfItems > 0 , collectionVeiw.contentSize != .zero else {
            return IndexPath(item: 0, section: 0)
        }
        
        let sortedIndexPaths = collectionVeiw.indexPathsForVisibleItems.sorted { (l, r) -> Bool in
            let lframe = collectionViewLayout.frame(for: l)
            let rframe = collectionViewLayout.frame(for: r)
            
            let leftCenter = lframe.midX
            let rightCenter = rframe.midX
            let ruler = collectionVeiw.bounds.midX
            
            return abs(ruler - leftCenter) < abs(ruler - rightCenter)
        }
        
        let index = sortedIndexPaths.first
        if let index = index {
            return index
        }
        return IndexPath(item: 0, section: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        collectionVeiw.frame = contentView.bounds
    }
    
    func register(cellClass: Swift.AnyClass?, forCellWithReuseIdentifier identifier: String) {
        collectionVeiw.register(cellClass, forCellWithReuseIdentifier: identifier)
        
    }
    
    func dequeueReusableCell(withReuseIdentifier identifier:String, at index: Int) -> ZBannerViewCell {
        let indexPath = IndexPath(item: index, section: dequeingSection)
        let cell = collectionVeiw.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        guard cell.isKind(of: ZBannerViewCell.self) else {
            fatalError("Cell class must be subclass of ZBannerViewCell")
        }
        return cell as! ZBannerViewCell
    }
    
    func reloadData() {
        collectionViewLayout.isNeedsReprepare = true
        collectionVeiw.reloadData()
    }
}

extension ZBannerView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let dataSource = dataSource else {
            return 0
        }
        
        numberOfItems = dataSource.numberOfItems(in: self)
        guard numberOfItems > 0 else {
            return 0
        }
        
        numberOfSetions = Int(Int16.max) / numberOfItems
//        numberOfSetions = 1
        return numberOfSetions
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        dequeingSection = indexPath.section
        let cell = dataSource!.bannerView(self, cellForItemAt: indexPath.item)
        return cell
    }
    
}

extension ZBannerView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let function = delegate?.bannerView(_: didSelectItemAt:) else {
            return
        }
        
        let index = indexPath.item % numberOfItems
        function(self, index)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.numberOfItems > 0 {
            let currentIndex = lround(Double(self.scollOffSet)) % numberOfItems
            if currentIndex != self.currentIndex {
                self.currentIndex = currentIndex
            }
        }
        
        guard let function = self.delegate?.bannerViewDidScroll else {
            return
        }
        
        function(self)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        cancelTimer()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        startTimer()
    }
}
