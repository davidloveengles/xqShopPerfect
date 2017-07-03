//
//  SubKindTableOptor.swift
//  xqShopPerfect
//
//  Created by David on 2017/6/3.
//
//


import StORM
import MySQLStORM
import SwiftMoment
import PerfectLib


/// 表
class SubKindTable: MySQLStORM {
    
    var id              : Int = 0
    var pid             : Int = 0
    var name            : String = ""
  
    
    
    override open func table() -> String { return "t_kind_sub" }
    
    override func to(_ this: StORMRow) {
        if this.data["id"] is Int32 {
            id = Int(this.data["id"] as? Int32 ?? 0)
        }else{
            id				= this.data["id"] as? Int		 ?? 0
        }
        name                = this.data["name"] as? String		 ?? ""
    }
    
    func rows() -> [SubKindTable] {
        var rows = [SubKindTable]()
        for i in 0..<self.results.rows.count {
            let row = SubKindTable()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
}


/// 模型
class SubKindModel: JSONConvertibleObject {
    
    var id              : Int = 0
    var name            : String = ""
    
    var open            : Bool = false
    var count           : Int = 0
    var foods           : [FoodModel] = []
    
    override init() {}
    init(table: SubKindTable) {
        id = table.id
        name = table.name
    }
    
    /// override
    static let registerName = "KindModel"
    override func setJSONValues(_ values: [String : Any]) {
        self.id = getJSONValue(named: "id", from: values, defaultValue: 0)
        self.name = getJSONValue(named: "name", from: values, defaultValue: "")
        self.open = getJSONValue(named: "open", from: values, defaultValue: false)
        self.count = getJSONValue(named: "count", from: values, defaultValue: 0)
        self.foods = getJSONValue(named: "foods", from: values, defaultValue: [])
    }
    override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:FoodModel.registerName,
            "id":id,
            "name":name,
            "open":open,
            "count":count,
            "foods":foods
        ]
    }
}


/// 表操作
class SubKindTableOptor: DBBaseOperator {
    
    static let shared = SubKindTableOptor()
    private override init() {
        try? SubKindTable().setup()
    }
    
    
    func querySubKind(pid: Int) -> [SubKindModel]? {
        
        let subkind = SubKindTable()
        
        do {
            try subkind.select(whereclause: "pid = ?", params: [pid], orderby: ["id"])
        }catch {
            return nil
        }
        
        
        var m_subkindList = [SubKindModel]()
        for t_subkind in subkind.rows() {
            let m_subkind = SubKindModel(table: t_subkind)
            
            if let m_foods = FoodTableOptor.shared.queryFoods(pid: m_subkind.id, ppid: pid) {
                m_subkind.foods = m_foods
            }

            m_subkindList.append(m_subkind)
        }
        
        
        return m_subkindList
    }
    
    
    func insertAData(_ subKind: SubKindTable) {
        
        do {
            _ = try subKind.insert(cols: ["id", "pid", "name"], params: [subKind.id, subKind.pid, subKind.name])
        }catch {
            print("插入一条kind数据错误： \(error)")
        }
    }
}


