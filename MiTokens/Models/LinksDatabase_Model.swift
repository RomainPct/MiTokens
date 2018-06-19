//
//  LinksDatabase_Model.swift
//  MiTokens
//
//  Created by Romain Penchenat on 30/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import RealmSwift

class LinksDatabase {
    
//    Variables
    internal let _realm:Realm?
    
//    Init
    init() {
        if let url = Realm.Configuration.defaultConfiguration.fileURL?.deletingLastPathComponent().appendingPathComponent("links.realm") {
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
    
//    Créer un lien
    func addALink(link:Link){
        try? _realm?.write {
            _realm?.add(link)
        }
    }
    
//    Récupérer un lien
    func getLink(forAirdrop airdrop:Airdrop) -> Link? {
        if let links = _realm?.objects(Link.self).filter("_airdropId == \(airdrop.airdropID)") {
            if links.count > 1 {
                // Semble impossible
                print("Many links (\(links.count)")
                print(links)
            }
            return links.first
        } else {
            return nil
        }
    }
    func getLink(forToken token:token, inWallet wallet:Wallet) -> Link? {
        if let links = _realm?.objects(Link.self).filter("_smartContract == '\(token.smartContract)' AND _walletAddress == '\(wallet.erc20Address)'") {
            if links.count > 1 {
                // Possibilité d'adapter l'affichage
                print("Many links (\(links.count)")
                print(links)
            }
            return links.first
        } else {
            return nil
        }
    }
    
//    Supprimer un lien
    func deleteLink(forAirdrop airdrop:Airdrop) {
        if let link = getLink(forAirdrop: airdrop) {
            try? _realm?.write {
                _realm?.delete(link)
            }
        }
    }
    
}
