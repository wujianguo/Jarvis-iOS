//
//  MediaPreviewCollectionViewCell.swift
//  Jarvis
//
//  Created by Jianguo Wu on 2018/10/25.
//  Copyright © 2018年 wujianguo. All rights reserved.
//

import UIKit
import SnapKit

class MediaPreviewCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "MediaPreviewCollectionViewCellIdentifier"
    
    lazy var thumbnailView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var statusIconView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        contentView.addSubview(thumbnailView)
        thumbnailView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
        contentView.addSubview(statusIconView)
        statusIconView.snp.makeConstraints { (make) in
            make.trailing.equalTo(contentView.snp_trailingMargin)
            make.bottom.equalTo(contentView.snp_bottomMargin)
        }
    }
}
