//
//  MediaItem.swift
//  Jarvis
//
//  Created by Jianguo Wu on 2018/10/11.
//  Copyright © 2018年 wujianguo. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


enum UploadStatus {
    case idle
    case waiting
    case uploading
    case done
}


enum MediaItemType {
    case image(image: UIImage)
    case video(video: AVAsset)
}

protocol MediaItemAsset {
    
    var date: Date { get }
    
    var thumbnail: UIImage? { get set }
    
    var asset: MediaItemType? { get set }
}

protocol MediaSectionItem {
    
    var date: Date { get }
    
    var count: Int { get }
    
}

protocol MediaProcessor {
    
    func statusDidChangedNotificationName() -> Notification.Name
    
    func statusForIndexPath(indexPath: IndexPath) -> UploadStatus
    
    func numberOfSections() -> Int
    
    func numberOfItemsInSection(section: Int) -> Int
    
    func titleForSection(section: Int) -> String
    
    func requestThumbnail(indexPath: IndexPath, complete: @escaping (IndexPath, UIImage) -> Void)
    
    func cancelThumbnail(indexPath: IndexPath)
    
    func startSync()
    
    func stopSync()
    
    var isSyncing: Bool { get }
    
}
