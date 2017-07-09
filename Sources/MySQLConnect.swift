//
//  MySQLConnect.swift
//  PerfectDemo3
//
//  Created by David on 2017/5/18.
//
//


import PerfectLib
import StORM
import MySQLStORM
import MySQL
import PerfectCURL


struct MySQLConnect {

    static func config() {
        
        MySQLConnector.host		= "127.0.0.1"
        MySQLConnector.username	= "root"
        MySQLConnector.password	= "daixeibing:DAI2529926"
        #if os(Linux)
            MySQLConnector.database	= "shop_db"
        #else
            MySQLConnector.database	= "shop_db"
        #endif
        MySQLConnector.port		= 3306
        
        // 编码
        _ = MySQL().setOption(MySQLOpt.MYSQL_SET_CHARSET_NAME, "utf8mb4")
        
        
        // 创建表
        _ = SubKindTableOptor.shared
        _ = FoodTableOptor.shared
        _ = KindTableOptor.shared
        _ = OrderTableOptor.shared
        _ = WorkTableOptor.shared
        
        
        // 注册可json的模型类
        JSONDecoding.registerJSONDecodable(name: KindModel.registerName, creator: { return KindModel() })
        JSONDecoding.registerJSONDecodable(name: SubKindModel.registerName, creator: { return SubKindModel() })
        JSONDecoding.registerJSONDecodable(name: FoodModel.registerName, creator: { return FoodModel() })
        JSONDecoding.registerJSONDecodable(name: OrderModel.registerName, creator: { return OrderModel() })
        JSONDecoding.registerJSONDecodable(name: WorkModel.registerName, creator: { return WorkModel() })
    
        
      
        
        // 数据库插入所有数据
        StringDataParse.parseKindStringFile("KindData.strings")
        StringDataParse.parseFoodsStringFile("1xiangyan.strings")
        StringDataParse.parseFoodsStringFile("2binglang.strings")
        StringDataParse.parseFoodsStringFile("3yingping.strings")
        StringDataParse.parseFoodsStringFile("4jiulei.strings")
        StringDataParse.parseFoodsStringFile("5lingshi.strings")
        StringDataParse.parseFoodsStringFile("6tangguo.strings")
        StringDataParse.parseFoodsStringFile("7niunai.strings")
        StringDataParse.parseFoodsStringFile("8fangbian.strings")
        StringDataParse.parseFoodsStringFile("9lingying.strings")
        StringDataParse.parseFoodsStringFile("10zhiping.strings")
        StringDataParse.parseFoodsStringFile("11xitiao.strings")
        StringDataParse.parseFoodsStringFile("12jisheng.strings")
        StringDataParse.parseFoodsStringFile("13riyong.strings")
        StringDataParse.parseFoodsStringFile("14tiaowei.strings")
        StringDataParse.parseFoodsStringFile("15luwei.strings")
    }
    
}




