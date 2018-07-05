//
//  ValuesManager_Model.swift
//  MiTokens
//
//  Created by Romain Penchenat on 03/06/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import RealmSwift
import SwiftyJSON

class ValuesManager {
    
//    Variables
    internal let _realm:Realm?
    private var _coinMarketCapListing:Listing?
    
//    Init
    init() {
        if let url = Realm.Configuration.defaultConfiguration.fileURL?.deletingLastPathComponent().appendingPathComponent("values.realm") {
            do {
                _realm = try Realm(fileURL: url)
            } catch {
                print("ERROR : \(error)")
                _realm = nil
            }
        } else {
            _realm = nil
        }
    }
    
//    Récupérer la valeur d'un token
    func getValue(ofLink link:Link, handler:@escaping(JSON?) -> Void ) {
        getCMCId(forLink: link) { (idResponse) in
            if let id = idResponse {
                Singletons.API.getValue(forCMCId: id, handler: { (responseJSON) in
                    handler(responseJSON["data"]["quotes"]["EUR"])
//                    REPONSE JSON ( responseJSON["data"]["quotes"]["EUR"] ) :
//                    {
//                        "percent_change_24h" : -9.5399999999999991,
//                        "volume_24h" : 585414.35615690425,
//                        "percent_change_1h" : -0.41999999999999998,
//                        "percent_change_7d" : 1.01,
//                        "market_cap" : 10400120,
//                        "price" : 0.0278965688
//                    }
                })
            } else {
                handler(nil)
            }
        }
    }
    
// Récuperer l'id CoinMarketCap d'un smartContract
    func getCMCId(forLink link:Link, handler:@escaping(String?) -> Void) {
        if let id = searchCMCIdInDatabase(forSmartContract: link.smartContract) {
            handler(id)
        } else {
            // Si la liste est enregistré depuis plus de 10min ou n'est pas enregistré
            if _coinMarketCapListing == nil || !Date().timeIntervalSince(_coinMarketCapListing!.downloadingDate).isLess(than: 600) {
                Singletons.API.getCoinMarketCapListing { (listJSON) in
                    self._coinMarketCapListing = Listing(listing: listJSON["data"], downloadingDate: Date())
                    handler(self.getIdInCMCList(forLink: link))
                }
            } else {
                handler(getIdInCMCList(forLink: link))
            }
        }
    }
    
    // Rechercher l'id d'un token dans la DB
    fileprivate func searchCMCIdInDatabase(forSmartContract smartContract:String) -> String? {
        if let value = _realm?.objects(Value.self).filter("_smartContract == '\(smartContract)'").first {
            return value.coinMarketCapID
        } else {
            return nil
        }
    }
    
    // Rechercher l'id d'un token dans le listing
    fileprivate func getIdInCMCList(forLink link:Link) ->  String? {
        if let list = _coinMarketCapListing!.listing.arrayObject as? [Dictionary<String, Any>] {
//            let results = list.filter { $0["symbol"] as! String == link.tokenSymbol && link.tokenName.contains($0["name"] as! String) }
            let results = list.filter { $0["symbol"] as! String == link.tokenSymbol }
            if let result = results.first,
                let idInt = result["id"] as? Int {
                // Enregistré la valeur dans la db
                save(id: String(idInt), forSmartContract: link.smartContract)
                return String(idInt)
            }
        }
        return nil
    }
    
    // Enregistrer un lien smartContract/Id CMC dans la db
    fileprivate func save(id:String, forSmartContract smartContract:String) {
        let value = Value(forSmartContract: smartContract, linkToCMCId: id)
        try? _realm?.write {
            _realm?.add(value)
        }
    }
    
}
