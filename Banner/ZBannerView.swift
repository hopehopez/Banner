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
    
}


class ZBannerView: UIView {

    @IBOutlet weak var dataSource: ZBannerViewDataSource?
    @IBOutlet weak var delegate: ZBannerViewDelegate?
    
    private weak var contentView: UIView!
    private weak var collectionVeiw: ZCollectionView!
    private weak var collectionViewLayout: ZCollectionViewLayout!
    
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
        
        let layout = ZCollectionViewLayout()
        let collectionView = ZCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.orange
        collectionView.isPagingEnabled = true
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
        guard timer == nil else {
            return
        }
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(flipNext), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .defaultRunLoopMode)
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
    
}