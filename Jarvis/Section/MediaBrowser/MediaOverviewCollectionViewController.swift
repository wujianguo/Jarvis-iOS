//
//  MediaOverviewCollectionViewController.swift
//  Jarvis
//
//  Created by Jianguo Wu on 2018/10/25.
//  Copyright © 2018年 wujianguo. All rights reserved.
//

import UIKit
import Photos


class MediaOverviewSectionInfo {
    
    let date: Date
    var count: Int = 1
    var startIndex: Int
    
    init(date: Date, startIndex: Int) {
        self.date = date
        self.startIndex = startIndex
    }
    
}

class MediaOverviewCollectionViewController: UICollectionViewController {

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = UIConstants.padding
        layout.minimumInteritemSpacing = UIConstants.padding
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.headerReferenceSize = CGSize(width: 200, height: 20)
        layout.sectionHeadersPinToVisibleBounds = true
        layout.sectionInset = UIEdgeInsets(top: UIConstants.padding, left: UIConstants.padding, bottom: UIConstants.padding, right: UIConstants.padding)
        self.processor = PhotoKitProcessor()
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let processor: MediaProcessor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = UIColor.white
        collectionView.register(MediaSectionHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MediaSectionHeaderCollectionReusableView.identifier)
        collectionView.register(MediaPreviewCollectionViewCell.self, forCellWithReuseIdentifier: MediaPreviewCollectionViewCell.identifier)
        NotificationCenter.default.addObserver(self, selector: #selector(statusDidChanged(notification:)), name: processor.statusDidChangedNotificationName(), object: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "start", style: .plain, target: self, action: #selector(rightClick(sender:)))
        updateRightTitle()
    }
    
    @objc func statusDidChanged(notification: Notification) {
        if let indexPath = notification.userInfo?["IndexPath"] as? IndexPath {
//            print("\(indexPath) \(processor.statusForIndexPath(indexPath: indexPath))")
            collectionView.reloadItems(at: [indexPath])
        }
    }

    @objc func rightClick(sender: UIBarButtonItem) {
        if processor.isSyncing {
            processor.stopSync()
        } else {
            processor.startSync()
        }
        updateRightTitle()
    }
    
    func updateRightTitle() {
        if processor.isSyncing {
            navigationItem.rightBarButtonItem?.title = "stop"
        } else {
            navigationItem.rightBarButtonItem?.title = "start"
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return processor.numberOfSections()
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return processor.numberOfItemsInSection(section: section)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MediaSectionHeaderCollectionReusableView.identifier, for: indexPath) as! MediaSectionHeaderCollectionReusableView
        header.titleLabel.text = processor.titleForSection(section: indexPath.section)
        return header
    }
    

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaPreviewCollectionViewCell.identifier, for: indexPath) as! MediaPreviewCollectionViewCell
        
        let status = processor.statusForIndexPath(indexPath: indexPath)
        switch status {
        case .idle, .uploading, .waiting:
            cell.statusIconView.image = UIImage(named: "waiting_icon")
        case .done:
            cell.statusIconView.image = UIImage(named: "done_icon")
        }
        
        processor.requestThumbnail(indexPath: indexPath) { (originIndex, image) in
            guard indexPath == originIndex else {
                return
            }
            cell.thumbnailView.image = image
        }
    
        return cell
    }
        
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        processor.cancelThumbnail(indexPath: indexPath)
    }
        

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
