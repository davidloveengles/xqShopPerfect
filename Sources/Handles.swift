//
//  Handles.swift
//  xqShopPerfect
//
//  Created by David on 2017/6/6.
//
//

import Foundation
import PerfectLib
import PerfectNet
import PerfectHTTP
import PerfectHTTPServer

import PerfectCrypto
import SwiftRandom
import SwiftMoment

struct Handels {
    
    static func getAllFoods() -> RequestHandler {
        
        return {    request, response in
            
            var status: StatusCode = .Faile
            var msg: String = ""
            var data: Any? = nil
            defer {
                let json = baseResponseJsonData(status: status, msg: msg, data: data)
                response.appendBody(string: json)
                response.completed()
            }
            
            if let kinds = KindTableOptor.shared.queryAllKinds() {
                status = .SUCCESS
                msg = "操作成功"
                data = try? kinds.jsonEncodedString()
                
            }else {
                msg = "操作失败"
            }
            
        }
    }
}


extension Handels {
    
     static func getOpenId() -> RequestHandler {
        
            return {    request, response in

            var status: StatusCode = .Faile
            var msg: String = ""
            var data: Any? = nil
            defer {
                let json = baseResponseJsonData(status: status, msg: msg, data: data)
                response.appendBody(string: json)
                response.completed()
            }

            if let code = request.param(name: "code") {
                
                let url = "https://api.weixin.qq.com/sns/jscode2session?appid=wxcdbda1d1c5fee50f&secret=5a5204a375b200d19a778c28f2d52f1c&js_code=\(code)&grant_type=authorization_code"
                let result = Utility.makeRequest(.get, url)
                
//                071QCuvB1xOpyg0ptDuB1S4kvB1QCuv1
//                {"session_key":"Lk5bFx00A+gzMH9X8OdE8g==","expires_in":7200,"openid":"obdv80MZ8Eqb_q4zy6bizJz6-7Y0"}
                
                print("获取code成功:\(code)")
                print(result)
                if let openid = result["openid"] {
                    status = .SUCCESS
                    msg = "获取openid成功"
                    data = openid
                }else {
                    msg = "获取openid失败"
                }
            }else {
                msg = "参数不够"
            }
        }
    }

    // 商户在小程序中先调用该接口在微信支付服务后台生成预支付交易单，返回正确的预支付交易后调起支付
    // https://pay.weixin.qq.com/wiki/doc/api/wxa/wxa_api.php?chapter=9_1
    static func getOrderData() -> RequestHandler {
        return {    request, response in
            
            var status: StatusCode = .Faile
            var msg: String = ""
            var data: Any? = nil
            defer {
                let json = baseResponseJsonData(status: status, msg: msg, data: data)
                response.appendBody(string: json)
                response.completed()
            }
            
            if let _ = request.param(name: "openid"), let orderList = request.param(name: "orderList"), let total_fee = request.param(name: "total_fee") {
                
                let appid = "wxcdbda1d1c5fee50f"
                let body = orderList
                let mch_id = "商户号"
                let nonce_str = Randoms.randomAlphaNumericString(length: 20)
                let notify_url = "支付后接收微信的通知url-应该写个url接口"
                let out_trade_no = "\(moment().format("yyyyMMddHHmmss"))\(Randoms.randomInt(lower: 1000, 9000))"
                let sign_type = "MD5"
                let spbill_create_ip = request.remoteAddress.host
                let total_fee = "单位为分"
                let trade_type = "JSAPI"
                
                let key = "商户key"// 不参与传值
                
                var sign = ""
                let signStr = "appid=\(appid)&body=\(body)&mch_id=\(mch_id)&nonce_str=\(nonce_str)&notify_url=\(notify_url)&out_trade_no=\(out_trade_no)&sign_type=\(sign_type)&spbill_create_ip=\(spbill_create_ip)&total_fee=\(total_fee)&trade_type=\(trade_type)&key=\(key)"
                if let bytes = signStr.digest(.md5)?.encode(.hex),let md5Sign = String(validatingUTF8: bytes)  {
                    sign = md5Sign.uppercased()
                }
                
                var formData = "<xml>"
                formData += "<appid>" + appid + "</appid>"
                formData += "<body>![CDATA[" + body + "]]</body>"
                formData += "<mch_id>" + mch_id + "</mch_id>"
                formData += "<nonce_str>" + nonce_str + "</nonce_str>"
                formData += "<notify_url>" + notify_url + "</notify_url>"
                formData += "<out_trade_no>" + out_trade_no + "</out_trade_no>"
                formData += "<spbill_create_ip>" + spbill_create_ip + "</spbill_create_ip>"
                formData += "<total_fee>" + total_fee + "</total_fee>"
                formData += "<trade_type>" + trade_type + "</trade_type>"
                formData += "<sign>" + sign + "</sign>"
                formData += "</xml>"
                
                let url = "https://api.mch.weixin.qq.com/pay/unifiedorder"
                let result = Utility.makeRequest(.post, url, body: formData)
               
                print(result)
                //            if let kinds = KindTableOptor.shared.queryAllKinds() {
                //                status = .SUCCESS
                //                msg = "操作成功"
                //                data = try? kinds.jsonEncodedString()
                //
                //            }else {
                //                msg = "操作失败"
                //            }
            }else {
                msg = "参数不够"
            }
        }
    }
    
    // 货到付款方式下单
    static func orderHandel() -> RequestHandler {
        return {    request, response in
            
            var status: StatusCode = .Faile
            var msg: String = ""
            var data: Any? = nil
            defer {
                let json = baseResponseJsonData(status: status, msg: msg, data: data)
                response.appendBody(string: json)
                response.completed()
            }
            
            let params = request.postParams.first?.0
            let paramsDic = try? params?.jsonDecode() as? [String:Any]
        	print(params)   
	 if  let openid = paramsDic??["openid"] as? String,
                let total_fee = paramsDic??["total_fee"] as? Int,
                let payWay = (paramsDic??["payWay"] as? String)?.toInt(),
                let orderList = try? (paramsDic??["orderList"] as? [String:Any]).jsonEncodedString(),
                let userinfo = try? (paramsDic??["userinfo"] as? [String:Any]).jsonEncodedString(),
                let addressinfo = try? (paramsDic??["addressinfo"] as? [String:Any]).jsonEncodedString() {
                
                let order = OrderTable()
                order.openid = openid
                order.body = orderList
                order.userinfo = userinfo
                order.addressinfo = addressinfo
                order.out_trade_no = "\(moment().format("yyyyMMddHHmmss"))\(Randoms.randomInt(lower: 1000, 9000))"
                order.total_fee = total_fee
                order.payWay = payWay
                
                if let _ = try? OrderTableOptor.shared.insertOrder(order: order) {
                    status = .SUCCESS
                    msg = "操作成功"
    
                }else {
                    msg = "操作失败"
                }
            }else {
                msg = "参数不够"
            }
        }
    }
    
}


/// 订单
extension Handels {
    
    static func getAllOrder() -> RequestHandler {
        
        return {    request, response in
            
            var status: StatusCode = .Faile
            var msg: String = ""
            var data: Any? = nil
            defer {
                let json = baseResponseJsonData(status: status, msg: msg, data: data)
                response.appendBody(string: json)
                response.completed()
            }
            
            if let openid = request.param(name: "openid") {
                
                if let orderList = OrderTableOptor.shared.queryOrders(openid: openid) {
                    
                    status = .SUCCESS
                    msg = "操作成功"
                    data = try? orderList.jsonEncodedString()
                }else {
                    msg = "获取失败"
                }
            }else {
                msg = "参数不够"
            }
        }
    }

    
}
