//
//  NotificationsManager.swift
//  MiTokens
//
//  Created by Romain Penchenat on 16/06/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import KeychainAccess
import Firebase

class NotificationManager {
    
    private let _keychain = Keychain(service: "fr.romainpenchenat.MiTokens").synchronizable(true)
    private lazy var ref:DatabaseReference! = Database.database().reference()
    
    var TokensReceivedNotification: Bool {
        return Bool(_keychain["TokensReceivedNotification"] ?? "false") ?? false
    }
    
    var TokenListedNotification: Bool {
        return Bool(_keychain["TokenListedNotification"] ?? "false") ?? false
    }
    
    var notificationToken: String? {
        return _keychain["notificationToken"]
    }
    
    func setNotificationToken(_ token:Data){
        _keychain["notificationToken"] = (token as NSData).description.replacingOccurrences(of: "[ <>]", with: "", options: .regularExpression, range: nil)
    }
    
//    Token Received Notifications
    func turnOnTokenReceivedNotification(){
        _keychain["TokensReceivedNotification"] = true.description
        for wallet in Singletons.WalletsDB.wallets_list {
            newWalletForNotification(wallet)
        }
    }
    func turnOffTokenReceivedNotification(){
        _keychain["TokensReceivedNotification"] = false.description
        for wallet in Singletons.WalletsDB.wallets_list {
            deleteWalletForNotification(wallet)
        }
    }
    func newWalletForNotification(_ wallet:Wallet){
        if TokensReceivedNotification,
            let notifToken = notificationToken,
            !notifToken.isEmpty {
            ref.child("TokenReceivedNotification").childByAutoId().setValue([
                "wallet" : wallet.erc20Address,
                "notifToken" : notifToken,
                "wallet_notifToken" : "\(wallet.erc20Address)_\(notifToken)" ])
        } else { print("ERREUR : le notification token est vide : \(notificationToken ?? "_")") }
    }
    func deleteWalletForNotification(_ wallet:Wallet){
        if let notifToken = notificationToken,
            !notifToken.isEmpty {
            // On récupére toutes les entrées avec le bon wallet et le bon notifToken
            ref.child("TokenReceivedNotification").queryOrdered(byChild: "wallet_notifToken").queryEqual(toValue: "\(wallet.erc20Address)_\(notifToken)").observeSingleEvent(of: .value) { (snapshot) in
                // Puis on les supprime une à une
                for snap in snapshot.children.allObjects as! [DataSnapshot] {
                    snap.ref.removeValue()
                }
            }
        }
    }
    
// Token Listed Notification
    func turnOnTokenListedNotification(){
        _keychain["TokenListedNotification"] = true.description
        for wallet in Singletons.WalletsDB.wallets_list {
            // En mettant a jour les wallets, les tokens s'enregistrent automatiquement dans la db
            wallet.updateBalances {}
        }
    }
    func turnOffTokenListedNotification(){
        _keychain["TokenListedNotification"] = false.description
        // Supprimer les enregistrements dans la db
        if let notifToken = notificationToken,
            !notifToken.isEmpty {
            // On récupére toutes les entrées avec le bon notifToken
            ref.child("TokenListedNotification").queryOrdered(byChild: "notifToken").queryEqual(toValue: notifToken).observeSingleEvent(of: .value) { (snapshot) in
                // Puis on les supprime une à une
                for snap in snapshot.children.allObjects as! [DataSnapshot] {
                    snap.ref.removeValue()
                }
            }
        }
    }
    func newTokenForNotification(_ token:token){
        if TokenListedNotification,
            let notifToken = notificationToken,
            !notifToken.isEmpty {
            token.getValue(ofSmartContract: token.smartContract, wName: token.name, wSymbol: token.symbol) { (answer) in
                if answer == nil {
                    // On vérifie si la demande notif est déja enregistré dans la base de données
                    self.ref.child("TokenListedNotification").queryOrdered(byChild: "smartContract_notifToken").queryEqual(toValue: "\(token.smartContract)_\(notifToken)").observeSingleEvent(of: .value, with: { (snapshot) in
                        if !snapshot.exists() {
                            // Si il n'existe pas dans la db alors on l'enregistre
                            self.ref.child("TokenListedNotification").childByAutoId().setValue([
                                "smartContract": token.smartContract,
                                "notifToken":notifToken,
                                "smartContract_notifToken":"\(token.smartContract)_\(notifToken)"])
                            // On vérifie que le token est enregistré en tant que "recherché"
                            self.ref.child("TokenReasearchedOnTradingPlateforms").child(token.smartContract).observeSingleEvent(of: .value, with: { (snapshot) in
                                // Si il n'est pas enregistré alors on l'enregistre
                                if !snapshot.exists() {
                                    self.ref.child("TokenReasearchedOnTradingPlateforms").child(token.smartContract).setValue([
                                        "name":token.name,
                                        "symbol":token.symbol])
                                }
                            })
                        }
                    })
                }
            }
        }
    }
    
}
