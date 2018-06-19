//
//  Value_model.swift
//  MiTokens
//
//  Created by Romain Penchenat on 03/06/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import RealmSwift
import Realm

class Value:Object {
    
    @objc private dynamic var _smartContract:String
    @objc private dynamic var _coinMarketCapID:String
    
    var coinMarketCapID: String {
        return _coinMarketCapID
    }
    
    required init() {
        _smartContract = ""
        _coinMarketCapID = ""
        super.init()
    }
    
    init(forSmartContract smartContract:String, linkToCMCId id:String) {
        _smartContract = smartContract
        _coinMarketCapID = id
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        _smartContract = ""
        _coinMarketCapID = ""
        super.init(realm: realm, schema: schema)
    }

    required init(value: Any, schema: RLMSchema) {
        _smartContract = ""
        _coinMarketCapID = ""
        super.init(value: value, schema: schema)

    }
    
}
