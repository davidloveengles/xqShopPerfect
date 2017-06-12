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
        
        if let _ = accessTokenDic,
            let _ = accessTokenDic?["access_token"] as? String,
            let expires_in = accessTokenDic?["expires_in"] as? TimeInterval,
            let saveDate = accessTokenDic?["saveDate"] as? Date{
            
            if Date().timeIntervalSince1970 - saveDate.timeIntervalSince1970 < TimeInterval(expires_in - 600) {
                return true
            }
            return false
        }
         return false
    }
}

