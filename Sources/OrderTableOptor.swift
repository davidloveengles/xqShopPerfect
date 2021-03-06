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
    var remark          : String = ""               //客户备注
    var addressinfo     : String = ""               //包含姓名电话地址  {"name":"David","phone":"111233","home":"Bdbdbbd2"}
    var createTime		: String = moment().format("yyyy-MM-dd HH:mm:ss")
    var form_id         : String = ""               //客户备注
    var prepay_id       : String = ""               //微信支付prepay_id
    var payWay          : Int = 0                   //1:微信支付2:货到付款3:支付成功
    var status          : Int = 0                   //0:处理中1:成功2:取消（暂时没用，直接用payWay）
    
    
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
        remark              = this.data["remark"] as? String ?? ""
        prepay_id           = this.data["prepay_id"] as? String ?? ""
        form_id             = this.data["form_id"] as? String ?? ""
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
    var remark          : String = ""
    var prepay_id       : String = ""
    var form_id         : String = ""
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
        remark = table.remark
        form_id = table.form_id
        prepay_id = table.prepay_id
        payWay = {
            switch table.payWay {
            case 1:
                return "支付处理中"
            case 2:
                return "货到付款"
            case 3:
                return "支付成功"
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
        self.remark = getJSONValue(named: "remark", from: values, defaultValue: "")
        self.prepay_id = getJSONValue(named: "prepay_id", from: values, defaultValue: "")
        self.form_id = getJSONValue(named: "form_id", from: values, defaultValue: "")
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
            "remark":remark,
            "prepay_id":prepay_id,
            "form_id":form_id,
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
        print("插入数据order no:\(order.out_trade_no)")
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
    
    func updateOrderPayResult(trade_no: String, payWay: Int) -> OrderTable? {
        
        let order = OrderTable()
        order.out_trade_no = trade_no
        
        do {
            try order.find(["out_trade_no" : trade_no])
            print("trade_no \(trade_no)")
            print("find order \(order.id)")
            try order.update(cols: ["payWay"], params: [payWay], idName: "id", idValue: order.id)
            order.payWay = payWay
            return order
        }catch {
            return nil
        }
        
    }
    
}







