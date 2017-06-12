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


struct MySQLConnect {

    static func config() {
        
        MySQLConnector.host		= "127.0.0.1"
        MySQLConnector.username	= "root"
        MySQLConnector.password	= "daixeibing:DAI2529926"
        #if os(Linux)
            MySQLConnector.database	= "shop_db"
        #else
            MySQLConnector.database	= "shopdatabase1"
        #endif
        MySQLConnector.port		= 3306
        
        // 创建表
        _ = SubKindTableOptor.shared
        _ = FoodTableOptor.shared
        _ = KindTableOptor.shared
        _ = OrderTableOptor.shared
        
        
        // 注册可json的模型类
        JSONDecoding.registerJSONDecodable(name: KindModel.registerName, creator: { return KindModel() })
        JSONDecoding.registerJSONDecodable(name: SubKindModel.registerName, creator: { return SubKindModel() })
        JSONDecoding.registerJSONDecodable(name: FoodModel.registerName, creator: { return FoodModel() })
        JSONDecoding.registerJSONDecodable(name: OrderModel.registerName, creator: { return OrderModel() })
    }
    
}

