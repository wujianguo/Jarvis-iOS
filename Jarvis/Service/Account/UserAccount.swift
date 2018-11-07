//
//  UserAccount.swift
//  Jarvis
//
//  Created by Jianguo Wu on 2018/10/11.
//  Copyright © 2018年 wujianguo. All rights reserved.
//

import Foundation
import LeanCloud
import SQLite.Swift

typealias Completion = (Error?) -> Void

let AccountStatusChangedNotificationName = Notification.Name("AccountStatusChangedNotificationName")


struct AccountSignupData: Codable {
    
    let username: String
    
    let password: String
    
    let nickname: String
}

struct AccountSigninData: Codable {
    
    let username: String
    
    let password: String
    
}

struct AccountUser: Codable {
    
    let username: String
    
    let sessionToken: String
    
    let accid: String
}


protocol AccountProtocol {

    static func canAutoSignin() -> Bool
    
    static func lastUsername() -> String?
    
    func signup(data: AccountSignupData, complete: Completion?)
    
    func signin(data: AccountSigninData, complete: Completion?)
    
    func autoSignin(complete: Completion?)
    
    func signout(complete: Completion?)

}

//class AppUser: LCUser {
//
//}

class UserAccount: AccountProtocol {

    static let UserNameKey     = "Account.UserName"
    static let SessionTokenKey = "Account.SessionToken"

    static func canAutoSignin() -> Bool {
//        return true
//        return false
        guard UserDefaults.standard.string(forKey: UserAccount.UserNameKey) != nil else {
            return false
        }
        guard UserDefaults.standard.string(forKey: UserAccount.SessionTokenKey) != nil else {
            return false
        }
        return true
    }
    
    static func lastUsername() -> String? {
        return UserDefaults.standard.string(forKey: UserAccount.UserNameKey)
    }
    
    static let current: UserAccount = UserAccount()
    
    var userId: String {
        return LCUser.current?.objectId?.stringValue ?? ""
    }
    
    
    func signup(data: AccountSignupData, complete: Completion?) {
        let user = LCUser()
        user.username = LCString(data.username)
        user.password = LCString(data.password)

//        user.signUp { (result) in
//            if result.isSuccess {
//                UserDefaults.standard.set(data.username, forKey: UserAccount.UserNameKey)
//            }
//            complete?(result.error)
//        }
    }
    
    func signin(data: AccountSigninData, complete: Completion?) {
        _ = LCUser.logIn(username: data.username, password: data.password) { (result) in
            if let token = result.object?.sessionToken?.stringValue {
                UserDefaults.standard.set(token, forKey: UserAccount.SessionTokenKey)
            }
            UserDefaults.standard.set(data.username, forKey: UserAccount.UserNameKey)
            if result.isSuccess {
                self.onSigninSuccess()
            }
            complete?(result.error)
        }
    }
    
    func autoSignin(complete: Completion?) {
        guard let token = UserDefaults.standard.string(forKey: UserAccount.SessionTokenKey) else {
            assert(false)
            complete?(nil)
            return
        }
        _ = LCUser.logIn(sessionToken: token) { (result) in
            if result.isSuccess {
                self.onSigninSuccess()
            }
            complete?(result.error)
        }
    }
    
    func signout(complete: Completion?) {
        LCUser.logOut()
        UserDefaults.standard.removeObject(forKey: UserAccount.SessionTokenKey)
        complete?(nil)
    }
    
    private var db: Connection! = nil
    private func onSigninSuccess() {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(userId)
        try? FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
        db = try! Connection(path.appendingPathComponent("media.sqlite3").absoluteString)
        
        let media = Table("media")
        let id = Expression<Int64>("id")
        let localIdentifier = Expression<String>("localIdentifier")
        _ = try? db.run(media.create { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(localIdentifier, unique: true)
        })
    }
    
    func save(localIdentifier: String) {
        let media = Table("media")
        let localIdentifierEx = Expression<String>("localIdentifier")
        let insert = media.insert(localIdentifierEx <- localIdentifier)
        _ = try? db.run(insert)
    }
    
    func query(localIdentifier: String) -> Bool {
        let media = Table("media")
        let localIdentifierEx = Expression<String>("localIdentifier")
        let query = media.filter(localIdentifierEx == localIdentifier)
        if let count = try? db.scalar(query.count) {
            return count > 0
        }
        return false
    }
    
}
