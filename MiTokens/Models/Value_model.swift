//
//  Value_Model.swift
//  MiTokens
//
//  Created by Romain Penchenat on 07/07/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import SwiftyJSON

enum valueSource {
    case CoinMarketCap
    case Idex
}

class Value {
    
    var price:Double = 0
    let diff1h:Double?
    let diff1d:Double?
    let diff1w:Double?
    let lastUpdate:Date
    
    init(source:valueSource, jsonData:JSON) {
//        print("-------------------")
//        print(source)
//        print(jsonData)
//        print(" ")
        lastUpdate = Date()
        switch source {
        case .CoinMarketCap:
            price = jsonData["price"].doubleValue
            diff1h = jsonData["percent_change_24h"].doubleValue
            diff1d = jsonData["percent_change_1h"].doubleValue
            diff1w = jsonData["percent_change_7d"].doubleValue
        case .Idex:
            // Transformer le prix en euro
            diff1h = nil
            diff1d = jsonData["percentChange"].double
            diff1w = nil
            price = jsonData["highestBid"].doubleValue * Singletons.Values.ETHPrice
        }
    }
    
    func getTotalValue(forAmount amount:Double) -> Double {
        return price * amount
    }
    
}
