//
//  OrderTableOptor.swift
//  xqShopPerfect
//
//  Created by David on 2017/6/7.
//
//

import StORM
import MySQLStORM
import SwiftMoment
import PerfectLib


class OrderTable: MySQLStORM {
    
    var id              : Int = 0
    var openid          : String = ""
    var out_trade_no    : String = ""               //订单号
    var body            : String = ""               //订单数据  {"goods_detail":[{"price":2050,"goods_id":1,"goods_name":"aa-11-1111","quantity":2}]}
    var total_fee       : Int = 0                   //总价格单位（分）
    var userinfo        : String = ""
    var addressinfo     : String = ""               //包含姓名电话地址  {"name":"David","phone":"111233","home":"Bdbdbbd2"}
    var createTime		: String = moment().format("yyyy-MM-dd HH:mm:ss")
    var payWay          : Int = 0                   //1:微信支付2:货到付款
    var status          : Int = 0                   //0:处理中1:成功2:取消
    
    
    override open func table() -> String { return "t_order" }
    
    override func to(_ this: StORMRow) {
        if this.data["id"] is Int32 {
            id = Int(this.data["id"] as? Int32 ?? 0)
        }else{
            id				= this.data["id"] as? Int               ?? 0
        }
        if this.data["total_fee"] is Int32 {
            total_fee = Int(this.data["total_fee"] as? Int32 ?? 0)
        }else{
            total_fee		= this.data["total_fee"] as? Int        ?? 0
        }
        if this.data["payWay"] is Int32 {
            payWay = Int(this.data["payWay"] as? Int32 ?? 0)
        }else{
            payWay          = this.data["payWay"] as? Int           ?? 0
        }
        if this.data["total_fee"] is Int32 {
            status = Int(this.data["status"] as? Int32 ?? 0)
        }else{
            status          = this.data["status"] as? Int           ?? 0
        }
        openid              = this.data["openid"] as? String        ?? ""
        out_trade_no        = this.data["out_trade_no"] as? String  ?? ""
        body                = this.data["body"] as? String          ?? ""
        userinfo            = this.data["userinfo"] as? String      ?? ""
        addressinfo         = this.data["addressinfo"] as? String   ?? ""
        createTime          = this.data["createTime"] as? String ?? ""
    }
    
    func rows() -> [OrderTable] {
        var rows = [OrderTable]()
        for i in 0..<self.results.rows.count {
            let row = OrderTable()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
}

enum payWay: Int {
    case huodaofk = 0
    case paysuccess = 1
    case paycancel = 2
    
    var description: String {
        switch self {
 	case .huodaofk:
            return "货到付款"
        case .paysuccess:
            return "支付成功"
        case .paycancel:
            return "订单已取消"
        }
    }
}
/// 模型
class OrderModel: JSONConvertibleObject {
    
    var id              : Int = 0
    var openid          : String = ""
    var out_trade_no    : String = ""
    var body            : String = ""
    var total_fee       : Int = 0
    var userinfo        : String = ""
    var addressinfo     : String = ""
    var createTime		: String = ""
    var payWay          : String = ""
    var status          : Int = 0
    
    
    override init() {}
    init(table: OrderTable) {
        id = table.id
        openid = table.openid
        out_trade_no = table.out_trade_no
        body = table.body
        total_fee = table.total_fee
        userinfo = table.userinfo
        addressinfo = table.addressinfo
        createTime = table.createTime
        payWay = {
            switch table.payWay {
            case 0:
                return "订单已取消"
            case 1:
                return "支付成功"
            case 2:
                return "货到付款"
            default:
                return ""
            }
        }()
        status = table.status
    }
    
    /// override
    static let registerName = "OrderModel"
    override func setJSONValues(_ values: [String : Any]) {
        self.id = getJSONValue(named: "id", from: values, defaultValue: 0)
        self.openid = getJSONValue(named: "openid", from: values, defaultValue: "")
        self.out_trade_no = getJSONValue(named: "out_trade_no", from: values, defaultValue: "")
        self.body = getJSONValue(named: "body", from: values, defaultValue: "")
        self.total_fee = getJSONValue(named: "total_fee", from: values, defaultValue: 0)
        self.userinfo = getJSONValue(named: "userinfo", from: values, defaultValue: "")
        self.addressinfo = getJSONValue(named: "addressinfo", from: values, defaultValue: "")
        self.createTime = getJSONValue(named: "createTime", from: values, defaultValue: "")
        self.payWay = getJSONValue(named: "payWay", from: values, defaultValue: "")
        self.status = getJSONValue(named: "status", from: values, defaultValue: 0)
    }
    override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:FoodModel.registerName,
            "id":id,
            "openid":openid,
            "out_trade_no":out_trade_no,
            "body":body,
            "total_fee":total_fee,
            "userinfo":userinfo,
            "addressinfo":addressinfo,
            "createTime":createTime,
            "payWay":payWay,
            "status":status
        ]
    }
}



class OrderTableOptor: DBBaseOperator {
    
    static let shared = OrderTableOptor()
    private override init() {
        try? OrderTable().setup()
    }
    
    
    func insertOrder(order: OrderTable) throws {
        do {
            try order.save()
        }catch {
            print(error)
            throw error
        }
    }
    
    
    func queryOrders(openid: String) -> [OrderModel]? {
        
        let food = OrderTable()
        
        do {
            try food.select(whereclause: "openid = ?", params: [openid], orderby: ["id desc"])
        }catch {
            return nil
        }
        
        
        var m_orderList = [OrderModel]()
        for t_order in food.rows() {
            let m_order = OrderModel(table: t_order)
            
            m_orderList.append(m_order)
        }
        
        return m_orderList
    }
    
}

