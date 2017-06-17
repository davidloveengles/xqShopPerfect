//
//  GlobalData.swift
//  xqShopPerfect
//
//  Created by David on 2017/6/11.
//
//

import Foundation

class GlobalData {
    
    static let share = GlobalData()
    private init () {}
    
    
    // 公众号access_token expires_in saveDate(1970later)
    var accessTokenDic: [String: Any]?
}

extension GlobalData {
    
    // 是否需要从新请求 access_token
    func availableAccessToken () -> Bool {
        print("accessTokenDic:\(accessTokenDic)")
        if let token = accessTokenDic,
            let _ = token["access_token"] as? String,
            let expires_in = token["expires_in"] as? Int,
            let saveDate = token["saveDate"] as? TimeInterval{
            
            if Date().timeIntervalSince1970 - saveDate < TimeInterval(expires_in - 600) {
                return true
            }
            return false
        }
         return false
    }
}

