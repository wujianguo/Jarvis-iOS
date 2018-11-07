//
//  RestAPIRequest.swift
//  Jarvis
//
//  Created by Jianguo Wu on 2018/10/25.
//  Copyright © 2018年 wujianguo. All rights reserved.
//

import Foundation

enum RestAPIError: Error {
    case serverError(Int, String)
    case networkError(Int, String)
    case defaultError
}

protocol RestAPIResponseProtocol: Decodable {
    var msg: String { get }
    var code: Int { get }
    var error: Error? { get }
}

struct RestAPIResponse<T: Decodable> : RestAPIResponseProtocol {
    let msg: String
    let code: Int
    let data: T?
    
    var error: Error? {
        if code != 0 {
            return RestAPIError.serverError(code, msg)
        }
        return nil
    }
}

struct RestAPIRequest {
    
    static func url(endpoint: String) -> URL {
        if endpoint.hasPrefix("http://") || endpoint.hasPrefix("https://") {
            return URL(string: endpoint)!
        }
        return URL(string: "https://yousir.leanapp.cn/")!.appendingPathComponent(endpoint)
    }
    
    let request: URLRequest
    
//    init(get endpoint: String, query: [String: Any]) {
//
//    }
    
    init(post endpoint: String, query: [String: Any] = [:], body: Data) {
        var components = URLComponents(string: RestAPIRequest.url(endpoint: endpoint).absoluteString)!
        var queryItems = [URLQueryItem]()
        for (k, v) in query {
            queryItems.append(URLQueryItem(name: k, value: "\(v)"))
        }
        components.queryItems = queryItems
        var req = URLRequest(url: components.url!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = body
        request = req
    }
    
    @discardableResult
    func response<T: Decodable>(success: ((T)->Void)?, failure: ((Error)->Void)?) -> URLSessionDataTask {
        return responseData(success: { (data) in
            do {
                let ret = try JSONDecoder().decode(RestAPIResponse<T>.self, from: data)
                DispatchQueue.main.async {
                    if let error = ret.error {
                        debugPrint(error)
                        failure?(error)
                    } else if ret.data != nil {
                        success?(ret.data!)
                    } else {
                        failure?(RestAPIError.defaultError)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    debugPrint(error)
                    failure?(error)
                }
            }
        }, failure: failure)
    }
    
    func responseData(success: ((Data)->Void)?, failure: ((Error)->Void)?) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    failure?(error)
                }
            } else if let data = data {
                success?(data)
            } else {
                DispatchQueue.main.async {
                    failure?(RestAPIError.defaultError)
                }
            }
        }
        task.resume()
        return task
    }
    
}
