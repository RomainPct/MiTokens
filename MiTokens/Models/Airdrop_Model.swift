//
//  Airdrop_Model.swift
//  MiTokens
//
//  Created by Romain Penchenat on 08/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import Realm
import RealmSwift
import SwiftyJSON

class Airdrop:Object {
    
    @objc private dynamic var _airdropId:Int = 0
    @objc private dynamic var _name:String?
    @objc private dynamic var _symbol:String?
    @objc private dynamic var _amount:String?
    @objc private dynamic var _amountReferral:String?
    @objc private dynamic var _creationDate:Date?
    @objc private dynamic var _state:String?
    @objc private dynamic var _saleDate:Date?
    @objc private dynamic var _saleTotalPrice:String?
    
    func primaryKey() -> String {
        return "_airdropId"
    }
    var airdropID: Int {
        return _airdropId
    }
    
    var name: String {
        return _name ?? "NULL"
    }
    var smartContract: String {
        return link?.smartContract ?? "pas de lien"
    }
    var symbol: String? {
        get {
            return _symbol ?? "tokens"
        }
        set {
            _symbol = newValue
        }
    }
    var totalAmount:String {
        let total = (amount.amountToDouble() ?? 0) + (referral.amountToDouble() ?? 0)
        return total.asAmount(withMaxDigits: 6)
    }
    var amount: String {
        get {
            return _amount ?? "0"
        }
        set {
            _amount = newValue
        }
    }
    var referral: String {
        get {
            return _amountReferral ?? "0"
        }
        set {
            _amountReferral = newValue
        }
    }
    var creationDate: Date {
        return _creationDate!
    }
    var stateEnum: states {
        get {
            return states(rawValue: _state!)!
        }
        set {
            _state = newValue.rawValue
        }
    }
    var saleDate: Date? {
        return _saleDate
    }
    var saleTotalPrice: String {
        return _saleTotalPrice ?? "Inconnu"
    }
    
    var link: Link? {
        return Singletons.LinksDB.getLink(forAirdrop: self)
    }
    
    var value:JSON?
    
    convenience init(name:String,symbol:String,amount:String,referral:String) {
        self.init()
        _name = name
        _symbol = symbol
        _amount = amount
        _amountReferral = referral
        _creationDate = Date()
        _airdropId = Singletons.AirdropsDB.getNewId()
        stateEnum = .waiting
    }
    
    convenience init(fromOtherAirdrop airdrop:Airdrop, withAmount amount:Double, forTotalPrice totalPrice:Double) {
        self.init()
        _name = airdrop.name
        _symbol = airdrop.symbol
        _amount = amount.asAmount(withMaxDigits: 6)
        _amountReferral = "0"
        _creationDate = airdrop.creationDate
        _airdropId = Singletons.AirdropsDB.getNewId()
        stateEnum = .sold
        _saleTotalPrice = totalPrice.asAmount(withDigits: 2)
        _saleDate = Date()
    }
    
    func getValue(handler:@escaping(JSON?)->Void){
        if value == nil {
            if let selfLink = link {
                Singletons.Values.getValue(ofLink: selfLink) { (jsonData) in
                    self.value = jsonData
                    handler(jsonData)
                }
            } else {
                handler(nil)
            }
        } else {
            handler(value)
        }
    }
    
    func setSaleData(totalPrice:Double){
        guard _saleDate == nil,
            _saleTotalPrice == nil else {
            return
        }
        _saleTotalPrice = totalPrice.asAmount(withMaxDigits: 2)
        _saleDate = Date()
    }
    
}
