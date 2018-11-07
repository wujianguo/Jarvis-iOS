//
//  PhotoKitProcessor.swift
//  Jarvis
//
//  Created by Jianguo Wu on 2018/10/28.
//  Copyright © 2018年 wujianguo. All rights reserved.
//

import Foundation
import Photos
import LeanCloud
import CommonCrypto


//struct PhotoKitItem: MediaItemAsset {
//
//    var thumbnail: UIImage?
//
//    var asset: MediaItemType?
//
//    var date: Date
//
//}

extension PHAssetMediaType: Decodable {
    
}

//struct CloudMediaItem: Decodable {
//    let width: Float
//    let height: Float
//    let localIdentifier: String
//    let md5: String
//    let creationDate: Date
//    let type: PHAssetMediaType
//    let duration: TimeInterval
//}
//

class PhotoKitSection: MediaSectionItem {
    
    let date: Date
    var count: Int = 1
    var startIndex: Int
    
    init(date: Date, startIndex: Int) {
        self.date = date
        self.startIndex = startIndex
    }

}

class PhotoKitProcessor: MediaProcessor {
    
    func statusDidChangedNotificationName() -> Notification.Name {
        return Notification.Name("UploadStatusDidChangedNotificationName")
    }
    
    func statusForIndexPath(indexPath: IndexPath) -> UploadStatus {
        guard currentIndexPath.section < sections.count else {
            return .done
        }
        let index = sections[indexPath.section].startIndex + indexPath.row
        let current = sections[currentIndexPath.section].startIndex + currentIndexPath.row
        if index > current {
            return .waiting
        } else if index == current {
            if syncing {
                return .uploading
            } else {
                return .waiting
            }
        } else {
            return .done
        }
    }
    
    func numberOfSections() -> Int {
        return sections.count
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        return sections[section].count
    }
    
    func titleForSection(section: Int) -> String {
        return dateFormatter.string(from: sections[section].date)
    }
    
    func requestThumbnail(indexPath: IndexPath, complete: @escaping (IndexPath, UIImage) -> Void) {
        let asset = fetchResult!.object(at: sections[indexPath.section].startIndex + indexPath.row)
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.resizeMode = .exact
        options.deliveryMode = .fastFormat
        options.isNetworkAccessAllowed = true
        
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: options) { (image, info) in
//            print("\(info)")
            complete(indexPath, image ?? UIImage())
        }

    }
    
    func cancelThumbnail(indexPath: IndexPath) {
        
    }
    
    func startSync() {
        syncing = true
        sync(from: currentIndexPath)
    }
    
    func stopSync() {
        syncing = false
    }
    
    var isSyncing: Bool {
        return syncing
    }
    
    func sync(from: IndexPath) {
        guard from.section < sections.count else {
            syncing = false
            return
        }
        let index = sections[from.section].startIndex + from.row

        guard index < fetchResult?.count ?? 0 else {
            syncing = false
            return
        }
        guard syncing == true else {
            return
        }
        
        sync(index: index) { (error) in
            var next: IndexPath! = nil
            if self.sections[from.section].count > from.row + 1 {
                next = IndexPath(row: from.row + 1, section: from.section)
            } else {
                next = IndexPath(row: 0, section: from.section + 1)
            }
            self.currentIndexPath = next
            let preIndex = self.sections[from.section].startIndex + from.row
            let asset = self.fetchResult!.object(at: preIndex)
            NotificationCenter.default.post(name: self.statusDidChangedNotificationName(), object: asset, userInfo: ["IndexPath": from])

            self.sync(from: next)
        }
    }
    
    func sync(index: Int, complete: @escaping (Error?) -> Void) {
        let asset = fetchResult!.object(at: index)
        NotificationCenter.default.post(name: statusDidChangedNotificationName(), object: asset, userInfo: ["IndexPath": currentIndexPath])
        if asset.mediaType != .image {
            DispatchQueue.main.async {
                complete(nil)
            }
            return
        }
        
        if UserAccount.current.query(localIdentifier: asset.localIdentifier) {
            DispatchQueue.main.async {
                complete(nil)
            }
            return
        }
        
        let query = LCQuery(className: "Media")
        query.whereKey("localIdentifier", .equalTo(asset.localIdentifier))
        _ = query.find { (result) in
            switch result {
            case .success(objects: let objects):
                if objects.count > 0 {
                    complete(nil)
                } else {
                    self.upload(asset: asset, complete: complete)
                }
            case .failure(error: _):
                self.upload(asset: asset, complete: complete)
            }
        }
    }
    
    func upload(asset: PHAsset, complete: @escaping (Error?) -> Void) {
        let options = PHImageRequestOptions()
        options.version = .original
        options.isNetworkAccessAllowed = true
        imageManager.requestImageData(for: asset, options: options) { (data, str, orientation, info) in
            guard let data = data else {
                complete(nil)
                return
            }
            let lcImage = LCFile(payload: .data(data: data))
            
            let length = Int(CC_MD5_DIGEST_LENGTH)
            var digest = [UInt8](repeating: 0, count: length)
            _ = data.withUnsafeBytes({ (bytes: UnsafePointer<UInt8>) in
                CC_MD5(bytes, CC_LONG(data.count), &digest)
            })
            
            let dataMd5 = (0..<length).reduce("") {
                $0 + String(format: "%02x", digest[$1])
            }
            
            lcImage.key = dataMd5.lcString
            if let fileURL = info?["PHImageFileURLKey"] as? URL {
                lcImage.name = fileURL.lastPathComponent.lcString
            }
            let metaData = LCDictionary()
            metaData["md5"] = dataMd5.lcValue
            metaData["width"] = asset.pixelWidth.lcValue
            metaData["height"] = asset.pixelHeight.lcValue
            if let creationDate = asset.creationDate {
                metaData["creationDate"] = creationDate.lcValue
            }
            if let location = asset.location {
                let geoPoint = LCGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                metaData["location"] = geoPoint.lcValue
            }
            if asset.duration > 0 {
                metaData["duration"] = asset.duration.lcValue
            }

            lcImage.metaData = metaData
            let acl = LCACL()
            acl.setAccess(LCACL.Permission.read, allowed: true, forUserID: UserAccount.current.userId)
            acl.setAccess(LCACL.Permission.write, allowed: true, forUserID: UserAccount.current.userId)
            lcImage.ACL = acl
            _ = lcImage.save(progress: { (progress) in
                print("progress: \(progress)")
            }, completion: { (result) in
                switch result {
                case .success:
                    let media = LCObject(className: "Media")
                    media.ACL = acl
                    media["asset"] = lcImage
                    try! media.set("md5", value: dataMd5.lcValue)
                    try! media.set("width", value: asset.pixelWidth.lcValue)
                    try! media.set("height", value: asset.pixelHeight.lcValue)
                    try! media.set("localIdentifier", value: asset.localIdentifier)
                    try! media.set("type", value: asset.mediaType.rawValue.lcValue)
                    if let creationDate = asset.creationDate {
                        try! media.set("creationDate", value: creationDate.lcValue)
                    }
                    if let location = asset.location {
                        let geoPoint = LCGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                        try! media.set("location", value: geoPoint.lcValue)
                    }
                    if asset.duration > 0 {
                        try! media.set("duration", value: asset.duration.lcValue)
                    }

                    _ = media.save { (result) in
                        complete(result.error)
                    }
                case .failure(error: let error):
                    complete(error)
                }
            })
        }
    }
    
    
    private var syncing = false {
        didSet {
            UIApplication.shared.isIdleTimerDisabled = syncing
        }
    }
    
//    private var syncIndex = 0
    
    private var currentIndexPath = IndexPath(row: 0, section: 0)
    
    private lazy var dateFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private lazy var fetchResult: PHFetchResult<PHAsset>? = {
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        guard smartAlbums.firstObject != nil else {
            return nil
        }
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]
        return PHAsset.fetchAssets(in: smartAlbums.firstObject!, options: options)
    }()
    
    private lazy var sections: [PhotoKitSection] = {
        var array = [PhotoKitSection]()
        if let fetchResult = fetchResult {
            var info: PhotoKitSection! = nil
            for i in 0..<fetchResult.count {
                let asset = fetchResult.object(at: i)
                var date: Date! = nil
                if let modificationDate = asset.modificationDate {
                    date = modificationDate
                } else if info != nil {
                    date = info.date
                } else {
                    date = Date(timeIntervalSinceNow: 0)
                }
                
                if info != nil && Calendar.current.isDate(date, inSameDayAs: info.date) {
                    info.count = i - info.startIndex + 1
                } else {
                    info = PhotoKitSection(date: date, startIndex: i)
                    array.append(info)
                }
            }
        }
        return array
    }()
    
    private lazy var imageManager: PHCachingImageManager = {
        let manager = PHCachingImageManager()
        return manager
    }()
    
}
