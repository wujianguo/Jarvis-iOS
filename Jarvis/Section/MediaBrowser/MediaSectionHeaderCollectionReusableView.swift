//
//  MediaSectionHeaderCollectionReusableView.swift
//  Jarvis
//
//  Created by Jianguo Wu on 2018/10/28.
//  Copyright © 2018年 wujianguo. All rights reserved.
//

import UIKit
import SnapKit

class MediaSectionHeaderCollectionReusableView: UICollectionReusableView {

    static let identifier = "MediaSectionHeaderCollectionReusableViewIdentifier"

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textAlignment = .left
        return label
    }()
    
    func setup() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.snp_leadingMargin)
            make.trailing.equalTo(self.snp_trailingMargin)
            make.top.bottom.equalTo(self)
        }
    }
}
