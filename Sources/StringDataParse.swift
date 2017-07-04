//
//  StringDataParse.swift
//  xqShopPerfect
//
//  Created by David on 2017/6/30.
//

import Foundation
import PerfectLib

class StringDataParse {
    
    static func parseKindStringFile(_ fileName: String) {
        
        let thisFile = File("./foods/\(fileName)")
        
        
        guard let contents = try? thisFile.readString(),
            let result = (try? contents.jsonDecode()) as? [String: Any],
        let kinds = result["data"] as? [[String: Any]]
            else{
                return
        }
        
        print("解析到文件KindData.strings")
        
        var kindTables = [KindTable]()
        for dic in kinds {
            if let id = dic["id"] as? Int,
                let sequence = dic["sequence"] as? Int,
                let name = dic["name"] as? String {
                
                let kind = KindTable()
                kind.id = id
                kind.sequence = sequence
                kind.name = name
                kindTables.append(kind)
            }
            if let subWmProducts = dic["subWmProductTagVos"] as? [[String: Any]] {
                for subkindDic in subWmProducts {
                    let subkind = SubKindTable()
                    guard let id = subkindDic["id"] as? Int,
                        let pid = subkindDic["parentId"] as? Int,
                        let sequ = subkindDic["sequence"] as? Int,
                        let subname = subkindDic["name"] as? String else {
                        break
                    }
                    subkind.id = id
                    subkind.pid = pid
                    subkind.sequence = sequ
                    subkind.name = subname
                    // 插入subkind数据
                    SubKindTableOptor.shared.insertAData(subkind)
                }
            }
            
        }
        
        // 插入所有kind数据
        KindTableOptor.shared.insertAllData(kindTables)
    }
    
    
    static func parseFoodsStringFile(_ fileName: String) {
        
        let thisFile = File("./foods/\(fileName)")
        
        
        guard let contents = try? thisFile.readString(),
            let list = (try? contents.jsonDecode()) as? [[String: Any]]
            else{
                return
        }
        
        print("解析到文件\(fileName)")
        
        for dic in list {
            
            guard let data = dic["data"] as? [[String: Any]] else {
                break
            }
            for foodDic in data {
                guard let id = foodDic["id"] as? Int,
                    let pid = foodDic["secondTagId"] as? Int,
                    let ppid = foodDic["tagId"] as? Int,
                    let name = foodDic["name"] as? String,
                    let price = foodDic["price"] as? Double else{
                    break
                }
                
                let food = FoodTable()
                food.id = id
                food.pid = pid
                food.ppid = ppid
                food.name = name
                food.price = price.description
                if let wmProductPicVos = foodDic["wmProductPicVos"] as? [[String: Any]],
                   let img = wmProductPicVos.first?["picUrl"] as? String,
                   let largerImg = wmProductPicVos.first?["picLargeUrl"] as? String {
                    
                    food.img = Utility.downloadImg(urlStr: img)
                }
                // 插入food数据库
                FoodTableOptor.shared.insertAData(food)
                
            }
        }

    }
}





