//
//  ServerManager.swift
//  PerfectDemo3
//
//  Created by David on 2017/5/18.
//
//

import PerfectLib
import PerfectNet
import PerfectHTTP
import PerfectHTTPServer

import PerfectCrypto
import SwiftRandom
import SwiftMoment

enum StatusCode: Int {
    case Faile = -1
    case SUCCESS = 1
}


class ServerManager {
    
    private var server = HTTPServer()
    
    init(root: String = "./webroot", host: String, port: UInt16) {
        
        server.documentRoot = root
        server.serverPort = port
        server.serverName = host
        
        var routes = Routes()
        configRoutes(routes: &routes)
        server.addRoutes(routes)
        
        
        #if os(Linux)
            server.ssl = (sslCert: "/home/aliyunhttps/214124401610445/214124401610445.pem", sslKey: "/home/aliyunhttps/214124401610445/214124401610445.key")
            server.certVerifyMode = OpenSSLVerifyMode.sslVerifyPeer
        #else
            
        #endif
        
        
        
        server.setResponseFilters([(FilterResponse(), .high)])
    }
    
    func startServer() {
        do {
            try server.start()
        } catch PerfectError.networkError(let error, let msg) {
            print("网络出现错误: \(error) \(msg)")
        } catch {
            print("网络未知错误:\(error)")
        }

    }
    
        
        func configRoutes(routes: inout Routes) {
            
            // 增加静态根路径
            do {
                routes.add(method: .get, uri: "/**", handler: try PerfectHTTPServer.HTTPHandler.staticFiles(data: [:]))
            }catch {
                print(error)
            }
            
            
            // 查找用户
            routes.add(method: .get, uri: "/xq/allfoods/query", handler: Handels.getAllFoods())
            
            routes.add(method: .get, uri: "/xq/openid", handler: Handels.getOpenId())
            
            routes.add(method: .post, uri: "/xq/order/order", handler: Handels.orderHandel())
            
            routes.add(method: .get, uri: "/xq/order/all", handler: Handels.getAllOrder())
        }

    
}


    /// 通用响应格式
    func baseResponseJsonData(status: StatusCode, msg: String, data: Any?) -> String {
        
        var result = [String: Any]()
        result.updateValue(status.rawValue, forKey: "status")
        result.updateValue(msg, forKey: "msg")
        if data != nil {
            result.updateValue(data!, forKey: "data")
        }else {
            result.updateValue("", forKey: "data")
        }
        
        guard let json = try? result.jsonEncodedString() else{
            return ""
        }
        
        return json
    }
    
    /// 过滤某些响应
    struct FilterResponse: HTTPResponseFilter {
        
        func filterHeaders(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
            switch response.status {
            case .notFound:// 过滤404
                response.setBody(string: "404")
            default:
                callback(.continue)
            }
        }
        
        func filterBody(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
            callback(.continue)
        }
    }

