


import PerfectLib
import PerfectNet
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache




MySQLConnect.config()



#if os(Linux)
    let host = "47.93.30.83"
    ServerManager(host: host, port: 443).startServer()
#else
    let host = "127.0.0.1"
    ServerManager(host: host, port: 8888).startServer()
#endif


// 启动一个服务器处理静态页面
//do {
//    let tls = TLSConfiguration(certPath: "/home/aliyunhttps/214124401610445/214124401610445.pem", keyPath: "/home/aliyunhttps/214124401610445/214124401610445.key", caCertPath: nil, certVerifyMode: OpenSSLVerifyMode.sslVerifyPeer)
//    let routes  = [Route(method: .get, uri: "/", handler: try HTTPHandler.staticFiles(data: [:]))]
//    try  HTTPServer.launch([.secureServer(tls, name: host, port: 443, routes: [])])
//}catch {
//    
//}



//var host = "47.93.30.83"
//let port1 = 443, port2 = 80
//// 214121370320445  zhangpangpang.cn
//// 214124401610445  www.zhangpangpang.cn
//
//let confData = [
//    "servers": [
//        // Configuration data for one server which:
//        //	* Serves the hello world message at <host>:<port>/
//        //	* Serves static files out of the "./webroot"
//        //		directory (which must be located in the current working directory).
//        //	* Performs content compression on outgoing data when appropriate.
//        [
//            "name":host,
//            "port":port1,
//            "routes":[
//                ["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.staticFiles,
//                 "documentRoot":"./webroot",
//                 "allowResponseFilters":true]
//            ],
//            "filters":[
//                [
//                    "type":"response",
//                    "priority":"high",
//                    "name":PerfectHTTPServer.HTTPFilter.contentCompression,
//                    ]
//            ],
//            "tlsConfig":[
//                "certPath": "/home/aliyunhttps/214124401610445/214124401610445.pem",
//                "verifyMode": "peer",
//                "keyPath": "/home/aliyunhttps/214124401610445/214124401610445.key"
//            ]
//        ],
//        [
//            "name":host,
//            "port":port2,
//            "routes":[
//                ["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.redirect,
//                 "base":"https://www.zhangpangpang.cn:\(port1)"]
//            ]
//        ]
//    ]
//]
//
//do {
//    try HTTPServer.launch(configurationData: confData)
//} catch {
//    fatalError("\(error)")
//}

