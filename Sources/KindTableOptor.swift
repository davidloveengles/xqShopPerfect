//
//  KindTableOptor.swift
//  xqShopPerfect
//
//  Created by David on 2017/6/3.
//
//

import StORM
import MySQLStORM
import SwiftMoment
import PerfectLib




class KindTable: MySQLStORM {
    
    var id              : Int = 0
    var name            : String = ""
//    var open            : Bool = false
//    var count           : Int = 0
//    var subKinds        : [SubKindTable] = []

    
    override open func table() -> String { return "t_kind" }
    
    override func to(_ this: StORMRow) {
        if this.data["id"] is Int32 {
            id = Int(this.data["id"] as? Int32 ?? 0)
        }else{
            id				= this.data["id"] as? Int		 ?? 0
        }
        name                = this.data["name"] as? String		 ?? ""
//        if this.data["count"] is Int32 {
//            count = Int(this.data["count"] as? Int32 ?? 0)
//        }else{
//            count           = this.data["count"] as? Int		 ?? 0
//        }
//        open                = this.data["open"] as? Bool     ?? false
//        subKinds            = this.data["subKinds"] as? []     ?? false
    }
    
    func rows() -> [KindTable] {
        var rows = [KindTable]()
        for i in 0..<self.results.rows.count {
            let row = KindTable()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
}

// 自己添加的
extension Array where Element == KindTable {
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
class KindModel: JSONConvertibleObject {
    
    var id              : Int = 0
    var name            : String = ""
    
    var open            : Bool = false
    var count           : Int = 0
    var subKinds        : [SubKindModel] = []
    
    override init() {}
    init(table: KindTable) {
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
        self.subKinds = getJSONValue(named: "subKinds", from: values, defaultValue: [])
    }
    override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:FoodModel.registerName,
            "id":id,
            "name":name,
            "open":open,
            "count":count,
            "subKinds":subKinds
        ]
    }
}



class KindTableOptor: DBBaseOperator {
    
    static let shared = KindTableOptor()
    private override init() {
        do {
        try KindTable().setup()
        }catch {
            print(error)
        }
    }
    
    
    func queryAllKinds() -> [KindModel]? {
        
        let kind = KindTable()
        
        do {
//            try kind.findAll()
            try kind.select(whereclause: "", params: [], orderby: ["id"])
        }catch {
            return nil
        }
        
        var m_kindList = [KindModel]()
        for t_kind in kind.rows() {
            let m_kind = KindModel(table: t_kind)
            
            if let m_subkinds = SubKindTableOptor.shared.querySubKind(pid: m_kind.id) {
                m_kind.subKinds = m_subkinds
            }
            
            m_kindList.append(m_kind)
        }
        
        return m_kindList
    }
}
