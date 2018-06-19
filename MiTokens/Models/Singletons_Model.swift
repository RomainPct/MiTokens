//
//  SingletonManager_Model.swift
//  MiTokens
//
//  Created by Romain Penchenat on 06/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

class Singletons {
    
    static var AirdropsDB = AirdropsDatabase()
    static var WalletsDB = WalletsDatabase()
    static let API = APIManager()
    static var LinksDB = LinksDatabase()
    static var Values = ValuesManager()
    
}
