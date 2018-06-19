//
//  Link_Model.swift
//  MiTokens
//
//  Created by Romain Penchenat on 30/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import RealmSwift

class Link: Object {
    
    @objc private dynamic var _smartContract:String?
    @objc private dynamic var _tokenName:String?
    @objc private dynamic var _tokenSymbol:String?
    @objc private dynamic var _walletAddress:String?
    @objc private dynamic var _airdropId:Int = 0
    @objc private dynamic var _creationDate:Date?
    
    var airdropId: Int {
        return _airdropId
    }
    
    var smartContract:String {
        return _smartContract ?? "inconnu"
    }
    
    var tokenName:String {
        return _tokenName!
    }
    
    var tokenSymbol:String {
        return _tokenSymbol!
    }
    
    convenience init(betweenSmartContract smartContract:String, withName name:String, andSymbol symbol:String, andAirdropId airdropId:Int, forWalletAddress walletAddress:String) {
        self.init()
        _smartContract = smartContract
        _tokenName = name
        _tokenSymbol = symbol
        _airdropId = airdropId
        _walletAddress = walletAddress
        _creationDate = Date()
    }
    
    convenience init(fromLink link:Link, withNewAirdropId id:Int) {
        self.init()
        _smartContract = link.smartContract
        _tokenName = link.tokenName
        _tokenSymbol = link.tokenSymbol
        _airdropId = id
        _walletAddress = link._walletAddress
        _creationDate = link._creationDate
    }
    
}
