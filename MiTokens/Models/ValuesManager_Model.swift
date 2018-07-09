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
    private var valuesList:[String:Value] = [:]
    
    var ETHPrice: Double {
        return valuesList["ETH"]?.price  ?? 0
    }
    
    func setETHPrice(handler:@escaping () -> Void) {
        if valuesList["ETH"] != nil,
            Date().timeIntervalSince(valuesList["ETH"]!.lastUpdate).isLess(than: 60) {
            handler()
        } else {
            print("setETHPrice")
            Singletons.API.getValueOnCMC(forCMCId: "1027") { (jsonData) in
                self.valuesList["ETH"] = Value(source: .CoinMarketCap, jsonData: jsonData["data"]["quotes"]["EUR"])
                handler()
            }
        }
    }
    
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
    func getValue(ofLink link:Link, handler:@escaping(Value?) -> Void ) {
        setETHPrice {
            // Vérifier si la valeur est déja enregistré et si elle est récente
            if self.valuesList[link.tokenSymbol] != nil {
                print(Date().timeIntervalSince(self.valuesList[link.tokenSymbol]!.lastUpdate).isLess(than: 60))
            }
            if self.valuesList[link.tokenSymbol] == nil ||
                !Date().timeIntervalSince(self.valuesList[link.tokenSymbol]!.lastUpdate).isLess(than: 60) {
                // Récupérer le l'id Coin Market Cap
                self.getCMCId(forLink: link) { (idResponse) in
                    // Si il existe, lire la valeur sur CMC
                    if let id = idResponse {
                        Singletons.API.getValueOnCMC(forCMCId: id, handler: { (responseJSON) in
                            let val = Value(source: .CoinMarketCap, jsonData: responseJSON["data"]["quotes"]["EUR"])
                            self.valuesList[link.tokenSymbol] = val
                            handler(val)
                        })
                    } else {
                        // Sinon chercher la valeur sur Idex
                        Singletons.API.getValueOnIdex(forSymbol: link.tokenSymbol, handler: { (responseJSON) in
                            if responseJSON.count != 0 {
                                let val = Value(source: .Idex, jsonData: responseJSON)
                                self.valuesList[link.tokenSymbol] = val
                                handler(val)
                            } else {
                                handler(nil)
                            }
                        })
                    }
                }
            } else {
                handler(self.valuesList[link.tokenSymbol])
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
        if let value = _realm?.objects(CMClinkForValue.self).filter("_smartContract == '\(smartContract)'").first {
            return value.coinMarketCapID
        } else {
            return nil
        }
    }
    
    // Rechercher l'id d'un token dans le listing
    fileprivate func getIdInCMCList(forLink link:Link) ->  String? {
        if let list = _coinMarketCapListing!.listing.arrayObject as? [Dictionary<String, Any>] {
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
        let value = CMClinkForValue(forSmartContract: smartContract, linkToCMCId: id)
        try? _realm?.write {
            _realm?.add(value)
        }
    }
    
}
