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
    var phone           : String = ""
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
        phone             = this.data["phone"] as? String		 ?? ""
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
    var phone           : String = ""
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
        self.phone = getJSONValue(named: "phone", from: values, defaultValue: "")
        self.tip = getJSONValue(named: "tip", from: values, defaultValue: "")
    }
    override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:FoodModel.registerName,
            "id":id,
            "open":open,
            "phone":phone,
            "open":open
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
    
    
    func queryWorkMsg() -> WorkModel? {
        let work = WorkTable()
        do {
            try work.select(whereclause: "", params: [], orderby: [])
            if work.rows().count > 0 {
                let t_work = work.rows().first!
                let m_work = WorkModel(table: t_work)
                print(m_work.id)
                print(m_work.tip)
                print(m_work.phone)
                print(m_work.open)
                return m_work
            }
            return nil
        }catch {
            return nil
        }
    }
    
    func setWorkMsg(open: Int, tip: String, phone: String) throws {
        
        let work = WorkTable()
        do {
            try work.select(whereclause: "", params: [], orderby: [])
            if work.rows().count == 0 {
                work.open = open
                work.tip = tip
                work.phone = phone
                try work.save()
            }else {
                let t_w = work.rows().first!
                t_w.open = open
                t_w.tip = tip
                t_w.phone = phone
                try t_w.update(cols: ["open", "tip", "phone"], params: [open, tip, phone], idName: "id", idValue: t_w.id)
            }
        }catch {
            throw(error)
        }
    }
   
}






