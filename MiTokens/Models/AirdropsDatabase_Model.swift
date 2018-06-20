//
//  DatabaseManager_Model.swift
//  MiTokens
//
//  Created by Romain Penchenat on 06/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import RealmSwift
import SwiftyLevenshtein

class AirdropsDatabase {
    
//    Variables
    internal let _realm:Realm?
    private var _airdrops_list:[Airdrop] = []
    private var _filtered_list:FilteredList = FilteredList(wWaiting: true, wReceived: true, wSold: true, wSearchTherm: nil, list: [])
    private var tokenList:[String:[Airdrop]] = [:]
    
    init() {
        let url = APIManager._URL_library.appendingPathComponent("airdrops.realm")
        do {
            _realm = try Realm(fileURL: url)
        } catch {
            print("ERROR : \(error)")
            _realm = nil
        }
        getWalletsFromDB()
        _filtered_list.list = _airdrops_list
    }
    
    private func getWalletsFromDB() {
        if let airdrops = _realm?.objects(Airdrop.self).sorted(byKeyPath: "_creationDate", ascending: false) {
            for airdrop in airdrops {
                _airdrops_list.append(airdrop)
            }
        }
    }
    
    func getNewId() -> Int {
        var id = 0
        if let lastID = _realm?.objects(Airdrop.self).sorted(byKeyPath: "_airdropId").last?.airdropID {
            id = lastID + 1
        }
        return id
    }
    
//    Compter les résultats
    func countAirdrops(withState state:states) -> Int{
        return _airdrops_list.filter { $0.stateEnum == state }.count
    }
    
    func countValue(forState state:states) -> Double {
        let list = _airdrops_list.filter { $0.stateEnum == state }
        var value = 0.0
        for airdrop in list {
            value += airdrop.saleTotalPrice.amountToDouble() ?? 0
        }
        return value
    }
    
//    Récupérer une liste suivant la demande
    
    private func setList(wWaiting:Bool, wReceived:Bool, wSold:Bool, wSearchTherm:String?) {
        _filtered_list = FilteredList(wWaiting: wWaiting, wReceived: wReceived, wSold: wSold, wSearchTherm: wSearchTherm, list: _airdrops_list)
        if wSearchTherm != nil {
            _filtered_list.list = _filtered_list.list.filter { $0.name.range(of: wSearchTherm!, options: .caseInsensitive) != nil }
        }
        if !wWaiting || !wReceived || !wSold {
            if !wWaiting {
                _filtered_list.list = _filtered_list.list.filter { $0.stateEnum != .waiting }
            }
            if !wReceived {
                _filtered_list.list = _filtered_list.list.filter { $0.stateEnum != .received }
            }
            if !wSold {
                _filtered_list.list = _filtered_list.list.filter { $0.stateEnum != .sold }
            }
        }
    }
    
    func getList(wWaiting:Bool, wReceived:Bool, wSold:Bool, wSearchTherm:String?, needReload:Bool) -> [Airdrop] {
        // si la _filtered_list ne correspond pas à nos critères alors on la paramètre
        if (_filtered_list.wWaiting != wWaiting || _filtered_list.wReceived != wReceived || _filtered_list.wSold != wSold || _filtered_list.wSearchTherm != wSearchTherm) || needReload {
            setList(wWaiting: wWaiting, wReceived: wReceived, wSold: wSold, wSearchTherm: wSearchTherm)
        }
        return _filtered_list.list
    }
    
    func getCreateALinkList(forToken token:token) -> [Airdrop] {
        if let list = tokenList[token.smartContract] {
            // Si la liste associé à ce token a déja été créé, ne pas la recharger
            return list
        } else {
            // Chercher uniquement dans les en attente
            let fullList = _airdrops_list.filter { $0.stateEnum == .waiting && $0.link == nil }
            var levenshteinArray:[Int:[Airdrop]] = [0:[],1:[],2:[],3:[],4:[],5:[],6:[],7:[],8:[],9:[],10:[]]
            for airdrop in fullList {
                if let levenshteinSymbol = airdrop.symbol?.getLevenshtein(target: token.symbol) {
                    levenshteinArray[min(airdrop.name.getLevenshtein(target: token.name), levenshteinSymbol)]?.append(airdrop)
                } else {
                    levenshteinArray[airdrop.name.getLevenshtein(target: token.name)]?.append(airdrop)
                }
            }
            tokenList[token.smartContract] = []
            var i = 0
            while i <= 10{
                for airdrop in levenshteinArray[i] ?? [] {
                    tokenList[token.smartContract]!.append(airdrop)
                }
                i += 1
            }
            return tokenList[token.smartContract]!
        }
    }
    
    func getAirdrop(withId id:Int) -> Airdrop? {
        return _airdrops_list.filter { $0.airdropID == id }.first
    }
    
//    Ajouter un airdrop
    func addAirdrop(airdrop:Airdrop){
        try? _realm?.write {
            _realm?.add(airdrop)
        }
        _airdrops_list.insert(airdrop, at: 0)
        tokenList.removeAll()
    }
    
//    Modifications
    func editState(toState state:states, ofAirdrop airdrop:Airdrop){
        try? _realm?.write {
            airdrop.stateEnum = state
        }
        tokenList.removeAll()
    }
    func editAmounts(amount:String, amountReferral:String, ofAirdrop airdrop:Airdrop){
        try? _realm?.write {
            airdrop.amount = amount.stringByRemovingWhitespaces.replacingOccurrences(of: ",", with: ".")
            airdrop.referral = amountReferral
        }
        tokenList.removeAll()
    }
    func editSymbol(symbol:String, ofAirdrop airdrop:Airdrop){
        try? _realm?.write {
            airdrop.symbol = symbol
        }
        tokenList.removeAll()
    }
    func saveASale(withTotalPrice totalPrice:Double, ofAirdrop airdrop:Airdrop) {
        try? _realm?.write {
            airdrop.setSaleData(totalPrice: totalPrice)
        }
    }

//    Suppression
    func deleteAirdrop(forAirdrop airdrop:Airdrop,handler:@escaping ()->Void){
        if let index = _airdrops_list.index(of: airdrop) {
            _airdrops_list.remove(at: index.hashValue)
        }
        tokenList.removeAll()
        try? _realm?.write {
            _realm?.delete(airdrop)
            handler()
        }
    }
    
}
