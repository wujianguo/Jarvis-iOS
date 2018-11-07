//
//  MessageHUD.swift
//  NeteaseIM
//
//  Created by Jianguo Wu on 2018/7/2.
//  Copyright © 2018年 wujianguo. All rights reserved.
//

import Foundation
import PKHUD

extension Error {
    
    var hudDescription: String {
        if let error = self as? DecodingError {
            switch error {
            case .keyNotFound(let codingKey, _):
                return "'\(codingKey.stringValue)' key not found"
            default:
                return "\(error)"
            }
        }
        if let error = self as? NSError {
            if error.code == 302 {
                return Strings.accountPasswordError
            }
            if let des = error.localizedFailureReason {
                return des
            }
            return error.localizedDescription
        }
        return "\(self)"
    }
    
}

struct HUDWrapper {
    
    static func startLoading() {
        HUD.show(.systemActivity)
    }
    
    static func tipSuccessOrFailure(error: Error?) {
        HUD.hide(animated: false)
        if let error = error {
            HUD.flash(.label(error.hudDescription), delay: 2)
        } else {
            HUD.flash(.label(Strings.ok), delay: 2)
        }
    }
    
    static func stopLoading(error: Error?) {
        if let error = error {
            HUD.hide(animated: false)
            HUD.flash(.label(error.hudDescription), delay: 2)
        } else {
            HUD.hide()
        }
    }
    
}
