


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


//print("newserver")
//ServerManager(host: "127.0.0.1", port: 8880).startServer()
//
//do {
//    print("newserver")
//    var server = HTTPServer()
//    server.serverName = "127.0.0.1"
//    server.serverPort = 8181
//    var routes = Routes()
//    routes.add(method: .get, uri: "/**", handler: try PerfectHTTPServer.HTTPHandler.redirect(data: ["base":"http://www.baidu.com:80"]))
//    server.addRoutes(routes)
//    try server.start()
//}catch {
//    print(error)
//}
//
//HTTPServer.launch(wait: <#T##Bool#>, [HTTPServer.Server])

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
// 214121370320445  zhangpangpang.cn
// 214124401610445  www.zhangpangpang.cn

//let confData = [
//    "servers": [
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
//            "port":80,
//            "routes":[
//                ["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.redirect,
//                 "base":"www.baidu.com"]
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

