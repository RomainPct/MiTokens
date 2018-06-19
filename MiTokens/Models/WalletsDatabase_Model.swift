//
//  WalletDatabase_Model.swift
//  MiTokens
//
//  Created by Romain Penchenat on 06/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import RealmSwift

class WalletsDatabase {
    
    internal var _realm:Realm?
    
    var wallets_list:[Wallet] = []
    var isTotalyLoad = false
    
    init() {
        let url = Realm.Configuration.defaultConfiguration.fileURL?.deletingLastPathComponent().appendingPathComponent("wallets.realm")
        do { _realm = try Realm(fileURL: url!) } catch { print("ERROR : \(error)") }
        getWalletsFromDB()
    }
    private func getWalletsFromDB() {
        if let wallets = _realm?.objects(Wallet.self) {
            for wallet in wallets {
                wallets_list.append(wallet)
            }
        }
    }
    
//    Ajouter un wallet dans la db
    func addWallet(wallet:Wallet){
        try? _realm?.write {
            _realm?.add(wallet)
        }
        NotificationManager().newWalletForNotification(wallet)
        wallets_list.append(wallet)
    }
    
//    Supprimer un wallet de la db
    func removeWallet(atIndex index:Int) {
        NotificationManager().deleteWalletForNotification(wallets_list[index])
        try? _realm?.write {
            _realm?.delete(wallets_list[index])
        }
        wallets_list.remove(at: index)
    }
    
//    Vérifier qu'un wallet n'est pas déjà enregistré
    func verifIfWalletAddressIsNotAlreadyRegister(_ erc20address:String) -> Bool {
        for wallet in wallets_list {
            if wallet.erc20Address == erc20address.lowercased() {
                print("false")
                return false
            }
        }
        return true
    }
    
}
