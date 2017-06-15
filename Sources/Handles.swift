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

    static func payResultHandler() -> RequestHandler {
        
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
            print("微信返回的支付结果：")
            print(params)
            
//            if let code = request.param(name: "code") {
//                
//                if let openid = result["openid"] {
//                    status = .SUCCESS
//                    msg = "获取openid成功"
//                    data = openid
//                }else {
//                    msg = "获取openid失败"
//                }
//            }else {
//                msg = "参数不够"
//            }
        }
    }
    
    
    // 商户在小程序中先调用该接口在微信支付服务后台生成预支付交易单，返回正确的预支付交易后调起支付
    // https://pay.weixin.qq.com/wiki/doc/api/wxa/wxa_api.php?chapter=9_1
    static func payOrderHandle() -> RequestHandler {
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
                let payWay = paramsDic??["payWay"] as? Int,
                let orderList = try? (paramsDic??["orderList"] as? [String:Any]).jsonEncodedString(),
                let userinfo = try? (paramsDic??["userinfo"] as? [String:Any]).jsonEncodedString(),
                let addressinfo = try? (paramsDic??["addressinfo"] as? [String:Any]).jsonEncodedString(),
                let remark = paramsDic??["remark"] as? String,
                let form_id = paramsDic??["form_id"] as? String {
                
//                let order = OrderTable()
//                order.openid = openid
//                order.body = orderList
//                order.userinfo = userinfo
//                order.addressinfo = addressinfo
//                order.out_trade_no = "\(moment().format("yyyyMMddHHmmss"))\(Randoms.randomInt(lower: 1000, 9000))"
//                order.total_fee = total_fee
//                order.payWay = payWay
//                order.remark = remark
                
                
                /** 调用下单接口*/
                let appid = "wxcdbda1d1c5fee50f"
//                let body = orderList
                let body = "海选便利店-超市商品购买"
                let mch_id = "1482367232"
                let nonce_str = Randoms.randomAlphaNumericString(length: 20)
                let notify_url = "https://www.zhangpangpang.cn/xq/order/payresult"
                let out_trade_no = "\(moment().format("yyyyMMddHHmmss"))\(Randoms.randomInt(lower: 1000, 9000))"
                let sign_type = "MD5"
                let spbill_create_ip = request.remoteAddress.host
                let trade_type = "JSAPI"
                
                let key = "aaaaaaaaaaaaaaaa1111111111111111"// 商户key，不参与传值
                
                var sign = ""
                let signStr = "appid=\(appid)&body=\(body)&mch_id=\(mch_id)&nonce_str=\(nonce_str)&notify_url=\(notify_url)&openid=\(openid)&out_trade_no=\(out_trade_no)&spbill_create_ip=\(spbill_create_ip)&total_fee=\(total_fee)&trade_type=\(trade_type)&key=\(key)"
                if let bytes = signStr.digest(.md5)?.encode(.hex),let md5Sign = String(validatingUTF8: bytes)  {
                    sign = md5Sign.uppercased()
                }
                print("sign:")
                print(sign)
                
                var formData = "<xml>"
                formData += "<appid>" + appid + "</appid>"
//                formData += "<body>![CDATA[" + body + "]]</body>"
                formData += "<body>" + body + "</body>"
                formData += "<mch_id>" + mch_id + "</mch_id>"
                formData += "<nonce_str>" + nonce_str + "</nonce_str>"
                formData += "<notify_url>" + notify_url + "</notify_url>"
                formData += "<openid>" + openid + "</openid>"
                formData += "<out_trade_no>" + out_trade_no + "</out_trade_no>"
                formData += "<spbill_create_ip>" + spbill_create_ip + "</spbill_create_ip>"
                formData += "<total_fee>" + "\(total_fee)" + "</total_fee>"
                formData += "<trade_type>" + trade_type + "</trade_type>"
                formData += "<sign>" + sign + "</sign>"
                formData += "</xml>"
                
                let url = "https://api.mch.weixin.qq.com/pay/unifiedorder"
                let result = Utility.makeRequest(.post, url, body: formData)
                
                print("支付下单后返回的结果：")
                print(result)
               
                
                
                
//                if let _ = try? OrderTableOptor.shared.insertOrder(order: order) {
//                    status = .SUCCESS
//                    msg = "操作成功"
//                    
//                    // 给公众号发送订单消息
//                    _ = self.postTemplateMsg(order: order,form_id: form_id, isMaster: true)
//                    _ = self.postTemplateMsg(order: order,form_id: form_id, isMaster: false)
//                    
//                }else {
//                    msg = "操作失败"
//                }
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
                let payWay = paramsDic??["payWay"] as? Int,
                let orderList = try? (paramsDic??["orderList"] as? [String:Any]).jsonEncodedString(),
                let userinfo = try? (paramsDic??["userinfo"] as? [String:Any]).jsonEncodedString(),
                let addressinfo = try? (paramsDic??["addressinfo"] as? [String:Any]).jsonEncodedString(),
                let remark = paramsDic??["remark"] as? String,
                let form_id = paramsDic??["form_id"] as? String {
                
                let order = OrderTable()
                order.openid = openid
                order.body = orderList
                order.userinfo = userinfo
                order.addressinfo = addressinfo
                order.out_trade_no = "\(moment().format("yyyyMMddHHmmss"))\(Randoms.randomInt(lower: 1000, 9000))"
                order.total_fee = total_fee
                order.payWay = payWay
                order.remark = remark
                
                if let _ = try? OrderTableOptor.shared.insertOrder(order: order) {
                    status = .SUCCESS
                    msg = "操作成功"
    
                    // 给公众号发送订单消息
                    _ = self.postTemplateMsg(order: order,form_id: form_id, isMaster: true)
                    _ = self.postTemplateMsg(order: order,form_id: form_id, isMaster: false)
                    
                }else {
                    msg = "操作失败"
                }
            }else {
                msg = "参数不够"
            }
        }
    }
    
    /// 订单
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


/// 模板消息操作
extension Handels {
    
    static func getAccesstoken() -> String? {
        
        if GlobalData.share.availableAccessToken() {
            print("使用缓存的access_token")
            return GlobalData.share.accessTokenDic?["access_token"] as? String
        }
        
        let appid = "wxcdbda1d1c5fee50f";
        let secret = "5a5204a375b200d19a778c28f2d52f1c";
        let url = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=\(appid)&secret=\(secret)"
        let result = Utility.makeRequest(.get, url)
        
        // expires_in现在是7200s
        if let access_token = result["access_token"] as? String, let expires_in = result["expires_in"] {
            
            GlobalData.share.accessTokenDic = ["access_token": access_token,
                                               "expires_in": expires_in,
                                               "saveDate": Date().timeIntervalSince1970]
            print("获取access_token成功")
          return access_token
        }
        print("获取access_token失败")
        return nil
    }

    /// 发送模板消息
    static func postTemplateMsg(order: OrderTable, form_id: String, isMaster: Bool) -> [String:Any]? {
        
        guard let access_token = self.getAccesstoken() else{
            return nil
        }
        
        if let body = (try? order.body.jsonDecode()) as? [String: Any],
            let orders = body["goods_detail"] as? [[String: Any]]
            {
            
            var orderInfo = ""
            for var order in orders {
                if  let goods_name = order["goods_name"],
                    let quantity = order["quantity"],
                    let price = order["price"] as? Int{
                    orderInfo.append("\(goods_name) x\(quantity) ¥\(Float(price) / 100.0)\n")
                }
            }
            orderInfo = orderInfo.substring(0, length: orderInfo.length - 1)
            
            let addressinfo = try? order.addressinfo.jsonDecode() as? [String: Any]
            let personHome = (addressinfo??["home"] as? String) ?? ""
            let personPhone = (addressinfo??["phone"] as? String) ?? ""
            let perdonName = (addressinfo??["name"] as? String) ?? ""
            
                
            let body: [String : Any]
                
            if isMaster {
                // 发送给老板
                body  = ["touser": "ozxD-0OHB7p9Uvv-Xhcxf-zwjqnM",
                    "template_id": "M1AmRRh4blf5aHiyq8vXusayQiTwhRJm5DslO0vs1_0",   //模板ID(新订单通知)
                    "page": "pages/shop/shop",
                    "form_id": form_id,
                    "data": [
                        "keyword1": ["value": order.out_trade_no, "color": "#173177"],
                        "keyword2": ["value": orderInfo, "color": "#173177"],
                        "keyword3": ["value": perdonName, "color": "#173177"],
                        "keyword4": ["value": "货到付款", "color": "#173177"],
                        "keyword5": ["value": order.createTime, "color": "#173177"],
                        "keyword6": ["value": "\(Float(order.total_fee) / 100)元", "color": "#991199"],
                        "keyword7": ["value": personPhone, "color": "#173177"],
                        "keyword8": ["value": personHome, "color": "#173177"],
                        "keyword9": ["value": order.remark, "color": "#173177"]
                    ]
                ]
            } else {
                // 发送给用户
               body  = ["touser": order.openid,                 //接收者openid
                    "template_id": "hGDvSoPKzpxlRQZPBSdBvYyulTSz0pmRjNyb6bClF38",   //模板ID(订单提交成功通知)
                    "page": "shop",
                    "form_id": form_id,
                    "data": [
                        "keyword1": ["value": order.out_trade_no, "color": "#173177"],
                        "keyword2": ["value": orderInfo, "color": "#173177"],
                        "keyword3": ["value": "\(Float(order.total_fee) / 100)元", "color": "#173177"],
                        "keyword4": ["value": personHome, "color": "#173177"],
                        "keyword5": ["value": order.createTime, "color": "#173177"],
                        "keyword6": ["value": "感谢你的使用", "color": "#173177"]
                    ]
                ]
            }
                
            let url =  "https://api.weixin.qq.com/cgi-bin/message/wxopen/template/send?access_token=\(access_token)"
            let result = Utility.makeRequest(.post, url, body: (try? body.jsonEncodedString()) ?? "")
            
            print(result)
            return result
            }
            return nil
        }
        
        
       
    

}



