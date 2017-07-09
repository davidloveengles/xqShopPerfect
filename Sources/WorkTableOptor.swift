//
//  WorkTableOptor.swift
//  xqShopPerfect
//
//  Created by David on 2017/7/8.
//
//


import StORM
import MySQLStORM
import SwiftMoment
import PerfectLib
import PerfectCrypto



class WorkTable: MySQLStORM {
    
    var id              : Int = 0
    var open            : Int = 1  // 0 关闭 1 开启
    var phone           : Int = 0
    var tip             : String = ""
    
    
    
    override open func table() -> String { return "t_work" }
    
    override func to(_ this: StORMRow) {
        if this.data["id"] is Int32 {
            id = Int(this.data["id"] as? Int32 ?? 0)
        }else{
            id          = this.data["id"] as? Int		 ?? 0
        }
        if this.data["open"] is Int32 {
            open = Int(this.data["open"] as? Int32 ?? 1)
        }else{
            open		= this.data["open"] as? Int		 ?? 1
        }
        if this.data["phone"] is Int32 {
            phone = Int(this.data["phone"] as? Int32 ?? 0)
        }else{
            phone		= this.data["phone"] as? Int		 ?? 0
        }
        tip             = this.data["tip"] as? String		 ?? ""
    }
    
    func rows() -> [WorkTable] {
        var rows = [WorkTable]()
        for i in 0..<self.results.rows.count {
            let row = WorkTable()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
}

// 自己添加的
extension Array where Element == WorkTable {
    func rowsJsonString() throws -> String {
        var s = "["
        var first = true
        for v in self {
            if !first {
                s.append(",")
            } else {
                first = false
            }
            s.append(try v.asDataDict().jsonEncodedString())
        }
        s.append("]")
        return s
    }
}


/// 模型
class WorkModel: JSONConvertibleObject {
    
    var id              : Int = 0
    var open            : Int = 1
    var phone           : Int = 0
    var tip             : String = ""
    
    override init() {}
    init(table: WorkTable) {
        super.init()
        id = table.id
        open = table.open
        phone = table.phone
        tip = table.tip
    }
    
    /// override
    static let registerName = "WorkModel"
    override func setJSONValues(_ values: [String : Any]) {
        self.id = getJSONValue(named: "id", from: values, defaultValue: 0)
        self.open = getJSONValue(named: "open", from: values, defaultValue: 1)
        self.phone = getJSONValue(named: "phone", from: values, defaultValue: 0)
        self.tip = getJSONValue(named: "tip", from: values, defaultValue: "")
    }
    override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:FoodModel.registerName,
            "id":id,
            "open":open,
            "phone":phone,
            "open":open,
        ]
    }
}



class WorkTableOptor: DBBaseOperator {
    
    static let shared = WorkTableOptor()
    private override init() {
        do {
            try WorkTable().setup()
        }catch {
            print(error)
        }
    }
    
   
}

