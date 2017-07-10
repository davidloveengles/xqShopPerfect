//
//  FoodTableOptor.swift
//  xqShopPerfect
//
//  Created by David on 2017/6/3.
//
//

import StORM
import MySQLStORM
import SwiftMoment
import PerfectLib


class FoodTable: MySQLStORM {
    
    var id              : Int = 0
    var pid             : Int = 0
    var ppid            : Int = 0
    var name            : String = ""
    var img             : String = ""
    var largerImg       : String = ""
    var price           : String = ""
    var createTime		: String = moment().format("yyyy-MM-dd HH:mm:ss")
    
    
    override open func table() -> String { return "t_food" }
    
    override func to(_ this: StORMRow) {
        if this.data["id"] is Int32 {
            id = Int(this.data["id"] as? Int32 ?? 0)
        }else{
            id				= this.data["id"] as? Int		 ?? 0
        }
        if this.data["pid"] is Int32 {
            pid = Int(this.data["pid"] as? Int32 ?? 0)
        }else{
            pid				= this.data["pid"] as? Int		 ?? 0
        }
        if this.data["ppid"] is Int32 {
            ppid = Int(this.data["ppid"] as? Int32 ?? 0)
        }else{
            ppid				= this.data["ppid"] as? Int		 ?? 0
        }
        name                = this.data["name"] as? String		 ?? ""
        img                 = this.data["img"] as? String		 ?? ""
        largerImg           = this.data["img"] as? String		 ?? ""
        price               = this.data["price"] as? String		 ?? ""
        createTime          = this.data["createTime"] as? String     ?? ""
    }
    
    func rows() -> [FoodTable] {
        var rows = [FoodTable]()
        for i in 0..<self.results.rows.count {
            let row = FoodTable()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
}

/// 模型
class FoodModel: JSONConvertibleObject {
    
    var id              : Int = 0
    var pid             : Int = 0
    var ppid            : Int = 0
    var name            : String = ""
    var img             : String = ""
    var largerImg       : String = ""
    var price           : String = ""
    
    var count           : Int = 0
    
    override init() {}
    init(table: FoodTable) {
        id = table.id
        pid = table.pid
        ppid = table.ppid
        name = table.name
        img = table.img
        largerImg = table.largerImg
        price = table.price
    }
    
    /// override
    static let registerName = "FoodModel"
    override func setJSONValues(_ values: [String : Any]) {
        self.id = getJSONValue(named: "id", from: values, defaultValue: 0)
        self.pid = getJSONValue(named: "pid", from: values, defaultValue: 0)
        self.ppid = getJSONValue(named: "ppid", from: values, defaultValue: 0)
        self.name = getJSONValue(named: "name", from: values, defaultValue: "")
        self.img = getJSONValue(named: "img", from: values, defaultValue: "")
        self.largerImg = getJSONValue(named: "largerImg", from: values, defaultValue: "")
        self.price = getJSONValue(named: "price", from: values, defaultValue: "")
        self.count = getJSONValue(named: "count", from: values, defaultValue: 0)
    }
    override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:FoodModel.registerName,
            "id":id,
            "pid":pid,
            "ppid":ppid,
            "name":name,
            "img":img,
            "largerImg":largerImg,
            "price":price,
            "count":count,
        ]
    }
}


class FoodTableOptor: DBBaseOperator {
    
    static let shared = FoodTableOptor()
    private override init() {
        try? FoodTable().setup()
    }
    
    
    func queryFoods(pid: Int, ppid: Int) -> [FoodModel]? {
        
        let food = FoodTable()
        
        do {
            try food.select(whereclause: "pid = ? AND ppid = ?", params: [pid, ppid], orderby: ["id DESC"])
        }catch {
            return nil
        }
        
        
        var m_foodList = [FoodModel]()
        for t_food in food.rows() {
            let m_food = FoodModel(table: t_food)
            
            m_foodList.append(m_food)
        }
        
        return m_foodList
    }
    
    
    func insertAData(_ food: FoodTable) {
        
        do {
            _ = try food.insert(cols: ["id", "pid", "ppid", "name", "price", "img", "largerImg"], params: [food.id, food.pid, food.ppid,food.name, food.price, food.img, food.largerImg])
        }catch {
            print("插入一条food数据错误： \(error)")
        }
    }
    
}
