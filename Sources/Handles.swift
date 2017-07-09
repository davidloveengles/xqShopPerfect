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

import PerfectXML

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
    
    static func getShopMsg() -> RequestHandler {
        
        return {    request, response in
            
            var status: StatusCode = .SUCCESS
            var msg: String = "请求成功"
            var data = "{\"open\":1,\"tip\":\"营业时间早晨7点到下午10点\",\"phone\":12392392231}"
            defer {
                let json = baseResponseJsonData(status: status, msg: msg, data: data)
                response.appendBody(string: json)
                response.completed()
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
            
            var msg = ""
            var result = ""
            defer {
                print(msg)
                response.appendBody(string: result)
                response.completed()
            }
            
            let params = request.postParams.first?.0
            print("微信返回的支付通知：")
            print(params ?? "null")
            
//            <xml><appid><![CDATA[wxcdbda1d1c5fee50f]]></appid>
//            <bank_type><![CDATA[CFT]]></bank_type>
//            <cash_fee><![CDATA[1]]></cash_fee>
//            <fee_type><![CDATA[CNY]]></fee_type>
//            <is_subscribe><![CDATA[N]]></is_subscribe>
//            <mch_id><![CDATA[1482367232]]></mch_id>
//            <nonce_str><![CDATA[rY3lntn5QRqy6FToEs83]]></nonce_str>
//            <openid><![CDATA[ozxD-0OHB7p9Uvv-Xhcxf-zwjqnM]]></openid>
//            <out_trade_no><![CDATA[201706161351485647]]></out_trade_no>
//            <result_code><![CDATA[SUCCESS]]></result_code>
//            <return_code><![CDATA[SUCCESS]]></return_code>
//            <sign><![CDATA[57397266D0239D66278480C3FB800E94]]></sign>
//            <time_end><![CDATA[20170616135157]]></time_end>
//            <total_fee>1</total_fee>
//            <trade_type><![CDATA[JSAPI]]></trade_type>
//            <transaction_id><![CDATA[4007612001201706165974538874]]></transaction_id>
//            </xml>
            
            guard let xmlstring = params, let xDoc = XDocument(fromSource: xmlstring) else{
                msg = "响应的结果解析错误"
                return
            }
            
            guard let result_code = parseXmlTag(xDoc: xDoc, tagName: "result_code"), result_code == "SUCCESS",
                    let out_trade_no = parseXmlTag(xDoc: xDoc, tagName: "out_trade_no") else {
                let err_code = parseXmlTag(xDoc: xDoc, tagName: "err_code") ?? ""
                let err_code_des = parseXmlTag(xDoc: xDoc, tagName: "err_code_des") ?? ""
                msg = "支付失败--错误码：\(err_code) \(err_code_des)"
                return
            }
            
            if let order =  OrderTableOptor.shared.updateOrderPayResult(trade_no: out_trade_no, payWay: 3) {
                var formData = "<xml>"
                formData += "<return_code><![CDATA[SUCCESS]]></return_code>"
                formData += "<return_msg><![CDATA[OK]]></return_msg>"
                formData += "</xml>"
                result = formData
                msg = "处理支付结果通知成功"
                print("find order payway \(order.payWay)")
                // 给微信发送订单消息
                _ = self.postGZHTemplateMsg(order: order, isMaster: true)
                _ = self.postTemplateMsg(order: order, isMaster: false)
            }
            
        }
    }
    
    
    // 商户在小程序中先调用该接口在微信支付服务后台生成预支付交易单，返回正确的预支付交易后调起支付
    // https://pay.weixin.qq.com/wiki/doc/api/wxa/wxa_api.php?chapter=9_1
    static func payOrderHandle() -> RequestHandler {
        return { (request, response) in
            
            var status: StatusCode = .Faile
            var msg: String = ""
            var data: Any? = nil
            defer {
                print(msg)
                let json = baseResponseJsonData(status: status, msg: msg, data: data)
                response.appendBody(string: json)
                response.completed()
            }
            
            let params = request.postParams.first?.0
            let paramsDic = try? params?.jsonDecode() as? [String:Any]
            print(params ?? "")
            if  let openid = paramsDic??["openid"] as? String,
                let total_fee = paramsDic??["total_fee"] as? Int,
                let payWay = paramsDic??["payWay"] as? Int,
                let orderList = try? (paramsDic??["orderList"] as? [String:Any]).jsonEncodedString(),
                let userinfo = try? (paramsDic??["userinfo"] as? [String:Any]).jsonEncodedString(),
                let addressinfo = try? (paramsDic??["addressinfo"] as? [String:Any]).jsonEncodedString(),
                let remark = paramsDic??["remark"] as? String,
                let form_id = paramsDic??["form_id"] as? String {
                
                /** 插入数据库(查询的时候只查询支付成功的订单)*/
                let order = OrderTable()
                order.openid = openid
                order.body = orderList
                order.userinfo = userinfo
                order.addressinfo = addressinfo
                order.out_trade_no = "\(moment().format("yyyyMMddHHmmss"))\(Randoms.randomInt(lower: 1000, 9000))"
                order.total_fee = total_fee
                order.payWay = payWay
                order.remark = remark
                order.form_id = form_id
               
                
                /** 调用下单接口*/
                let appid = "wxcdbda1d1c5fee50f"
//                let body = orderList
                let body = "海选便利店-超市商品购买"
                let mch_id = "1482367232"
                let nonce_str = Randoms.randomAlphaNumericString(length: 20)
                let notify_url = "https://www.zhangpangpang.cn/xq/order/payresult"
                let out_trade_no = order.out_trade_no
//                let sign_type = "MD5"
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
                let result = Utility.makeRequest(.post, url, body: formData, encoding: "xml")
                
//                Optional("<xml><return_code><![CDATA[SUCCESS]]></return_code>\n<return_msg><![CDATA[OK]]></return_msg>\n<appid><![CDATA[wxcdbda1d1c5fee50f]]></appid>\n<mch_id><![CDATA[1482367232]]></mch_id>\n<nonce_str><![CDATA[2kSNbgTEaOz1kV02]]></nonce_str>\n<sign><![CDATA[A796FB666CB63187E29877248DF324B8]]></sign>\n<result_code><![CDATA[SUCCESS]]></result_code>\n<prepay_id><![CDATA[wx2017061523512830c2f6b7ce0558429784]]></prepay_id>\n<trade_type><![CDATA[JSAPI]]></trade_type>\n</xml>")
                
                print("支付下单后返回的结果：")
                print(result)
                
                /** 处理下单响应*/
                guard let xmlstring = result["response"] as? String, let xDoc = XDocument(fromSource: xmlstring) else{
                    msg = "响应的结果解析错误"
                    return
                }
                
                guard let result_code = parseXmlTag(xDoc: xDoc, tagName: "result_code"), result_code == "SUCCESS" else {
                    let err_code = parseXmlTag(xDoc: xDoc, tagName: "err_code") ?? ""
                    let err_code_des = parseXmlTag(xDoc: xDoc, tagName: "err_code_des") ?? ""
                    msg = "下单失败--错误码：\(err_code) \(err_code_des)"
                    return
                }
                
                let prepay_id = parseXmlTag(xDoc: xDoc, tagName: "prepay_id")
                let nonce_str2 = parseXmlTag(xDoc: xDoc, tagName: "nonce_str")
                
                //插入数据库
                order.prepay_id = prepay_id ?? ""
                guard let _ = try? OrderTableOptor.shared.insertOrder(order: order) else{
                    msg = "插入数据库失败"
                    return
                }
                
                let appId = appid
                let nonceStr = nonce_str2 ?? ""
                let package = "prepay_id=\(prepay_id ?? "")"
                let signType = "MD5"
                let timeStamp = Date().timeIntervalSince1970.description
                var paySign = ""
                let paysignStr = "appId=\(appId)&nonceStr=\(nonceStr)&package=\(package)&signType=\(signType)&timeStamp=\(timeStamp)&key=\(key)"
                if let bytes = paysignStr.digest(.md5)?.encode(.hex),let md5Sign = String(validatingUTF8: bytes)  {
                    paySign = md5Sign.uppercased()
                }
                
                let responDic: [String: Any] = ["nonceStr": nonceStr, "package": package, "signType": signType, "timeStamp": timeStamp, "paySign": paySign]
                
                status = .SUCCESS
                msg = "操作成功"
                data = (try? responDic.jsonEncodedString()) ?? ""
            }else {
                msg = "参数不够"
            }

        }
    }
    
    /// 货到付款方式下单
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
            print(params ?? "")
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
                order.form_id = form_id
                
                if let _ = try? OrderTableOptor.shared.insertOrder(order: order) {
                    status = .SUCCESS
                    msg = "操作成功"
    
                    // 给微信发送订单消息(同一个form_id只能发送给一个人。。。) func，只能发送模板消息给本人！！
                    _ = self.postGZHTemplateMsg(order: order, isMaster: true)
                    _ = self.postTemplateMsg(order: order, isMaster: false)
                    
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


/// 小程序-模板消息操作
extension Handels {
    
    static func getAccesstoken() -> String? {
        
        if GlobalData.share.availableAccessToken() == true {
            print("使用缓存的access_token")
            return GlobalData.share.accessTokenDic?["access_token"] as? String
        }
        
        let appid = "wxcdbda1d1c5fee50f";
        let secret = "5a5204a375b200d19a778c28f2d52f1c";
        let url = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=\(appid)&secret=\(secret)"
        let result = Utility.makeRequest(.get, url)
        
        // expires_in现在是7200s
        if let access_token = result["access_token"] as? String, let expires_in = result["expires_in"] as? Int {
            
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
    static func postTemplateMsg(order: OrderTable, isMaster: Bool) -> [String:Any]? {
        
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
                
                if order.payWay == 3 {
                    
//                    if isMaster {
//                        // 发送给老板 wo:ozxD-0OHB7p9Uvv-Xhcxf-zwjqnM shao:ozxD-0G8VslMeTlo0UUN06M0mYJw w:ozxD-0Ac7ShWvShSFeaRYVTl5iK8
//                        body  = ["touser": "ozxD-0OHB7p9Uvv-Xhcxf-zwjqnM",
//                                 "template_id": "M1AmRRh4blf5aHiyq8vXusayQiTwhRJm5DslO0vs1_0",   //模板ID(新订单通知)
//                            "page": "pages/shop/shop",
//                            "form_id": order.form_id,
//                            "data": [
//                                "keyword1": ["value": order.out_trade_no, "color": "#173177"],
//                                "keyword2": ["value": orderInfo, "color": "#173177"],
//                                "keyword3": ["value": perdonName, "color": "#173177"],
//                                "keyword4": ["value": "支付成功", "color": "#173177"],
//                                "keyword5": ["value": order.createTime, "color": "#173177"],
//                                "keyword6": ["value": "\(Float(order.total_fee) / 100)元", "color": "#991199"],
//                                "keyword7": ["value": personPhone, "color": "#173177"],
//                                "keyword8": ["value": personHome, "color": "#173177"],
//                                "keyword9": ["value": order.remark, "color": "#173177"]
//                            ]
//                        ]
//                    } else {
                        // 发送给用户
                        body  = ["touser": order.openid,                 //接收者openid
                            "template_id": "B9Tnfu8IogA-MhIng3Lg2vBl85J3adE4MB8bC7s-E90",   //模板ID(订单支付成功通知)
                            "page": "shop",
                            "form_id": order.prepay_id,
                            "data": [
                                "keyword1": ["value": order.out_trade_no, "color": "#173177"],
                                "keyword2": ["value": orderInfo, "color": "#173177"],
                                "keyword3": ["value": "\(Float(order.total_fee) / 100)元", "color": "#173177"],
                                "keyword4": ["value": personHome, "color": "#173177"],
                                "keyword5": ["value": order.createTime, "color": "#173177"],
                                "keyword6": ["value": "客服电话：18828288888", "color": "#173177"]
                            ]
                        ]
//                    }

                } else {
                    
//                    if isMaster {
//                        // 发送给老板
//                        body  = ["touser": "ozxD-0OHB7p9Uvv-Xhcxf-zwjqnM",
//                                 "template_id": "M1AmRRh4blf5aHiyq8vXusayQiTwhRJm5DslO0vs1_0",   //模板ID(新订单通知)
//                            "page": "pages/shop/shop",
//                            "form_id": order.form_id,
//                            "data": [
//                                "keyword1": ["value": order.out_trade_no, "color": "#173177"],
//                                "keyword2": ["value": orderInfo, "color": "#173177"],
//                                "keyword3": ["value": perdonName, "color": "#173177"],
//                                "keyword4": ["value": "货到付款", "color": "#173177"],
//                                "keyword5": ["value": order.createTime, "color": "#173177"],
//                                "keyword6": ["value": "\(Float(order.total_fee) / 100)元", "color": "#991199"],
//                                "keyword7": ["value": personPhone, "color": "#173177"],
//                                "keyword8": ["value": personHome, "color": "#173177"],
//                                "keyword9": ["value": order.remark, "color": "#173177"]
//                            ]
//                        ]
//                    } else {
                        // 发送给用户
                        body  = ["touser": order.openid,                 //接收者openid
                            "template_id": "hGDvSoPKzpxlRQZPBSdBvYyulTSz0pmRjNyb6bClF38",   //模板ID(订单提交成功通知)
                            "page": "shop",
                            "form_id": order.form_id,
                            "data": [
                                "keyword1": ["value": order.out_trade_no, "color": "#173177"],
                                "keyword2": ["value": orderInfo, "color": "#173177"],
                                "keyword3": ["value": "\(Float(order.total_fee) / 100)元", "color": "#173177"],
                                "keyword4": ["value": personHome, "color": "#173177"],
                                "keyword5": ["value": order.createTime, "color": "#173177"],
                                "keyword6": ["value": "客服电话：18828288888", "color": "#173177"]
                            ]
                        ]
//                    }
                    
                }
                
                
                
            
            let url =  "https://api.weixin.qq.com/cgi-bin/message/wxopen/template/send?access_token=\(access_token)"
            let result = Utility.makeRequest(.post, url, body: (try? body.jsonEncodedString()) ?? "")
            
            print("发送小程序模板消息：\(result)")
            return result
            }
            return nil
        }
        
    

}


/// 公账号-模板消息操作
extension Handels {
    
    static func getGZHAccesstoken() -> String? {
        
        if GlobalData.share.availableGZHAccessToken() == true {
            print("使用缓存的GZH access_token")
            return GlobalData.share.accessTokenGZHDic?["access_token"] as? String
        }
        
        let appid = "wxdaf2ab4f82bb0073";
        let secret = "beb197db5be1ae86d8e281527df3263f";
        let url = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&&appid=\(appid)&secret=\(secret)"
        let result = Utility.makeRequest(.get, url)
        
        // expires_in现在是7200s
        if let access_token = result["access_token"] as? String, let expires_in = result["expires_in"] as? Int {
            
            GlobalData.share.accessTokenGZHDic = ["access_token": access_token,
                                               "expires_in": expires_in,
                                               "saveDate": Date().timeIntervalSince1970]
            print("获取GZH access_token成功")
            return access_token
        }
        print("获取GZH access_token失败")
        return nil
    }
    
    /// 发送模板消息给邵强公众号
    static func postGZHTemplateMsg(order: OrderTable, isMaster: Bool) -> [String:Any]? {
        
        guard let access_token = self.getGZHAccesstoken() else{
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
            
            if order.payWay == 3 {
                // 支付成功
                body  = ["touser": "oTc4bs8lEe2PsGKceO5YQ8KeKk_g",
                         "template_id": "s1LudmcV7MbUh8jDnKSmxLyxhimtqbrws2BdF0fWy3w",   //模板ID(新订单通知)
                        "data": [
                            "first": ["value": "订单号：\(order.out_trade_no)\n订单状态：支付成功\n下单时间：\(order.createTime)", "color": "#173177"],
                            "keyword1": ["value": perdonName, "color": "#173177"],
                            "keyword2": ["value": personPhone, "color": "#173177"],
                            "keyword3": ["value": personHome, "color": "#173177"],
                            "keyword4": ["value": "\(Float(order.total_fee) / 100)元", "color": "#991199"],
                            "keyword5": ["value": orderInfo, "color": "#173177"],
                            "remark": ["value": "备注：" + order.remark, "color": "#173177"]
                        ]
                ]
                
            } else {
                    // 货到付款
                    body  = ["touser": "oTc4bs8lEe2PsGKceO5YQ8KeKk_g",
                             "template_id": "s1LudmcV7MbUh8jDnKSmxLyxhimtqbrws2BdF0fWy3w",   //模板ID(新订单通知)
                        "data": [
                            "first": ["value": "订单号：\(order.out_trade_no)\n订单状态：货到付款\n下单时间：\(order.createTime)", "color": "#173177"],
                            "keyword1": ["value": perdonName, "color": "#173177"],
                            "keyword2": ["value": personPhone, "color": "#173177"],
                            "keyword3": ["value": personHome, "color": "#173177"],
                            "keyword4": ["value": "\(Float(order.total_fee) / 100)元", "color": "#991199"],
                            "keyword5": ["value": "\n" + orderInfo, "color": "#173177"],
                            "remark": ["value": "备注：" + order.remark, "color": "#173177"]
                        ]
                    ]
            }
            
            
            let url =  "https://api.weixin.qq.com/cgi-bin/message/template/send?access_token=\(access_token)"
            let result = Utility.makeRequest(.post, url, body: (try? body.jsonEncodedString()) ?? "")
            
            print("发送公众号模板消息：\(result)")
            return result
        }
        return nil
    }
    
    
    
}


/// 私有
extension Handels {
    
    /// xml解析单节点
    static func parseXmlTag(xDoc: XDocument, tagName: String) -> String? {
        
        guard let node = xDoc.documentElement?.getElementsByTagName(tagName) else {
            print("未找到标签“\(tagName)”\n")
            return nil
        }
        
        // 如果找到了，就提取首个节点作为代表
        guard let value = node.first?.nodeValue else {
            print("标签“\(tagName)”不包含内容。\n")
            return nil
        }
        
        return value
    }
    
}



