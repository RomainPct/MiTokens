//
//  Wallet_Model.swift
//  MiTokens
//
//  Created by Romain Penchenat on 06/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import RealmSwift
import SwiftyJSON
import Realm

class Wallet:Object {
    
    @objc private dynamic var _name:String?
    @objc private dynamic var _erc20Address:String?
    private var _tokensList:[token] = []
    lazy var notifManager = NotificationManager()
    var lastUpdate:Date?
    
    var name: String {
        return _name!
    }
    var erc20Address: String {
        return _erc20Address!.trimmingCharacters(in: .whitespaces)
    }
    var tokensList:[token] {
        return _tokensList
    }
    
    private func setBalance(forBalance balance:String, andDecimals decimals:Int)->String {
        if let eIndex = balance.index(of: "e"),
            let plusIndex = balance.index(of: "+"),
            let power = Double(balance[plusIndex...]),
            let amount = Double(balance[..<eIndex]){
            let realAmount = amount * pow(10, power - Double(decimals))
            return realAmount.asAmount(withMaxDigits: 6)
        } else if let amount = Double(balance) {
            let realAmount = amount / pow(10, Double(decimals))
            return realAmount.asAmount(withMaxDigits: 6)
        }
        return "0"
    }
    
    convenience init(dataFromEthphlorer data:JSON, withName name:String) {
        self.init()
        _name = name
        _erc20Address = data["address"].stringValue
        setBalances(data: data)
    }
    
    func updateBalances(forcing:Bool = false, handler:@escaping ()->Void) {
        if lastUpdate == nil || !Date().timeIntervalSince(lastUpdate!).isLess(than: 60) || forcing {
            Singletons.API.getTokensOnAccount(withPublicKey: erc20Address) { (data) in
                if data != nil {
                    self.setBalances(data: data!)
                }
                self.lastUpdate = Date()
                handler()
            }
        } else {
            handler()
        }
    }
    
    private func setBalances(data:JSON){
        _tokensList = []
        _tokensList.append(token(name: "Ethereum", symbol: "ETH", smartContract: "ethereum", realBalance: data["ETH"]["balance"].doubleValue.asAmount(withMaxDigits: 12), decimals: 0))
        for tokenData in data["tokens"] {
            let balance = tokenData.1["balance"].stringValue
            let decimals = tokenData.1["tokenInfo"]["decimals"].intValue
            let newToken = token(name: tokenData.1["tokenInfo"]["name"].stringValue,
                                 symbol: tokenData.1["tokenInfo"]["symbol"].stringValue,
                                 smartContract: tokenData.1["tokenInfo"]["address"].stringValue,
                                 realBalance: setBalance(forBalance: balance, andDecimals: decimals),
                                 decimals: decimals)
            _tokensList.append(newToken)
            notifManager.newTokenForNotification(newToken)
        }
    }
    
}
