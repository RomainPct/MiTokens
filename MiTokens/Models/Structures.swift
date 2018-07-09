//
//  Structures.swift
//  MiTokens
//
//  Created by Romain Penchenat on 24/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import SwiftyJSON

// Dans Wallet_Model
struct token {
    var name:String
    var symbol:String
    var smartContract:String
    var realBalance:String
    var decimals:Int
    func getLink(inWallet wallet:Wallet) -> Link? {
        return Singletons.LinksDB.getLink(forToken: self, inWallet: wallet)
    }
    func getValue(ofSmartContract thisSmartContract:String, wName:String, wSymbol:String, handler:@escaping(Double?) -> Void) {
        let lk = Link(betweenSmartContract: thisSmartContract, withName: wName, andSymbol: wSymbol, andAirdropId: 0, forWalletAddress: "")
        Singletons.Values.getValue(ofLink: lk) { (value) in
            if value != nil {
                handler(value!.price)
            } else { handler(nil) }
        }
    }
}

// Dans AirdropsDatabse_Model
struct FilteredList {
    var wWaiting:Bool
    var wReceived:Bool
    var wSold:Bool
    var wSearchTherm:String?
    var list:[Airdrop]
}

// Dans ValuesManager_Model
struct Listing {
    var listing:JSON
    var downloadingDate:Date
}

// Enum pour airdrop
enum states:String {
    case waiting = "waiting"
    case received = "received"
    case sold = "sold"
}
