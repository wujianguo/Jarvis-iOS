//
//  MediaSyncCollectionViewController.swift
//  Jarvis
//
//  Created by Jianguo Wu on 2018/10/11.
//  Copyright © 2018年 wujianguo. All rights reserved.
//

import UIKit
import Photos
import SnapKit

class MediaItemCollectionViewHeader: UICollectionReusableView {
    
    static let identifier = "MediaItemCollectionViewHeaderIdentifier"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var label: UILabel = {
        let label = UILabel()

        return label
    }()
    
    func setup() {
        addSubview(label)
        label.snp.makeConstraints { (make) in
            make.center.equalTo(self)
        }
    }
}

class MediaItemCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "MediaItemCollectionViewCellIdentifier"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var representedAssetIdentifier: String!
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    func setup() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
    }
}

class MediaSyncCollectionViewController: UICollectionViewController {

    private lazy var fetchResult: PHFetchResult<PHAsset> = {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return PHAsset.fetchAssets(with: allPhotosOptions)
    }()
    
    private let imageManager = PHCachingImageManager()
    
    private var availableWidth: CGFloat = 0

    private var layout: UICollectionViewFlowLayout!
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = UIConstants.padding
        layout.minimumInteritemSpacing = UIConstants.padding
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.headerReferenceSize = CGSize(width: 200, height: 20)
        layout.sectionHeadersPinToVisibleBounds = true
        layout.sectionInset = UIEdgeInsets(top: UIConstants.padding, left: UIConstants.padding, bottom: UIConstants.padding, right: UIConstants.padding)
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = UIColor.white
        collectionView.register(MediaItemCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MediaItemCollectionViewHeader.identifier)
        collectionView.register(MediaItemCollectionViewCell.self, forCellWithReuseIdentifier: MediaItemCollectionViewCell.identifier)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let width = view.bounds.inset(by: view.safeAreaInsets).width
        // Adjust the item size if the available width has changed.
        if availableWidth != width {
            availableWidth = width
            let columnCount = (availableWidth / 80).rounded(.towardZero)
            let itemLength = (availableWidth - columnCount - 1) / columnCount
            layout.itemSize = CGSize(width: itemLength, height: itemLength)
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
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaItemCollectionViewCell.identifier, for: indexPath) as! MediaItemCollectionViewCell

//        let asset = fetchResult[indexPath.row]
//        cell.representedAssetIdentifier = asset.localIdentifier
//        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
//            // UIKit may have recycled this cell by the handler's activation time.
//            // Set the cell's thumbnail image only if it's still showing the same asset.
//            if cell.representedAssetIdentifier == asset.localIdentifier {
//                cell.thumbnailImage = image
//            }
//        })

        return cell
    }
    
//    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MediaItemCollectionViewHeader.identifier, for: indexPath) as! MediaItemCollectionViewHeader
//        header.label.text = "hello"
//        return header
//    }

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
