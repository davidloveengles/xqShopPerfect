//
//  StringDataParse.swift
//  xqShopPerfect
//
//  Created by David on 2017/6/30.
//

import Foundation
import PerfectLib

class StringDataParse {
    
    static func parseStringFile(_ fileName: String) {
        
        let thisFile = File("./foods/KindData.strings")
        
        
        guard let contents = try? thisFile.readString(),
            let result = try? contents.jsonDecode() as? [String: Any],
        let kinds = result?["data"] as? [[String: Any]]
            else{
                return
        }
        
        print("解析到文件KindData.strings")
        
        var kindTables = [KindTable]()
        for dic in kinds {
            if let id = dic["id"] as? Int, let name = dic["name"] as? String {
                let kind = KindTable()
                kind.id = id
                kind.name = name
                kindTables.append(kind)
            }
            if let subWmProducts = dic["subWmProductTagVos"] as? [[String: Any]] {
                for subkindDic in subWmProducts {
                    let subkind = SubKindTable()
                    guard let id = subkindDic["id"] as? Int, let pid = subkindDic["parentId"] as? Int, let subname = subkindDic["name"] as? String else {
                        break
                    }
                    subkind.id = id
                    subkind.pid = pid
                    subkind.name = subname
                    // 插入subkind数据
                    SubKindTableOptor.shared.insertAData(subkind)
                }
            }
            
        }
        
        // 插入所有kind数据
        KindTableOptor.shared.insertAllData(kindTables)
    }
}
