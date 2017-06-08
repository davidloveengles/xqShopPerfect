



import PackageDescription

let package = Package(
    name: "xqShopPerfect",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 2),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-MySQL.git", majorVersion: 2),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-Mustache.git", majorVersion: 2),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-Logger.git", majorVersion: 1),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-RequestLogger.git", majorVersion: 1),
        .Package(url: "https://github.com/SwiftORM/MySQL-StORM", majorVersion: 1),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-Crypto.git", majorVersion: 1),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-CURL.git", majorVersion: 2),
        .Package(url: "https://github.com/iamjono/SwiftString.git", majorVersion: 1),
        
        ]
        
    
//        "https://github.com/PerfectlySoft/Perfect-HTTPServer.git",
//        "https://github.com/PerfectlySoft/Perfect-FastCGI.git",
//        "https://github.com/PerfectlySoft/Perfect-CURL.git",
//        "https://github.com/PerfectlySoft/Perfect-PostgreSQL.git",
//        "https://github.com/PerfectlySoft/Perfect-SQLite.git",
//        "https://github.com/PerfectlySoft/Perfect-Redis.git",
//        "https://github.com/PerfectlySoft/Perfect-MySQL.git",
//        "https://github.com/PerfectlySoft/Perfect-MongoDB.git",
//        "https://github.com/PerfectlySoft/Perfect-WebSockets.git",
//        "https://github.com/PerfectlySoft/Perfect-Notifications.git",
//        "https://github.com/PerfectlySoft/Perfect-Mustache.git"
//    https://github.com/PerfectlySoft/Perfect-Logger.git
//    https://github.com/PerfectlySoft/Perfect-RequestLogger
    
//        StORM
//    https://github.com/SwiftORM/MySQL-StORM
)

