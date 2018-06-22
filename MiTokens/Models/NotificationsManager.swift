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
    private lazy var notifQueue = DispatchQueue(label: "notifToken", qos: .background)
    
    var TokensReceivedNotification: Bool {
        return Bool(_keychain["TokensReceivedNotification"] ?? "false") ?? false
    }
    
    var TokenListedNotification: Bool {
        return Bool(_keychain["TokenListedNotification"] ?? "false") ?? false
    }
    
    var notificationToken: String? {
        return _keychain["notificationToken"]
    }
    
//    Gestion du token de notification
    func setNotificationToken(_ notifToken:Data){
        notifQueue.sync {
            let notifTokenStr = (notifToken as NSData).description.replacingOccurrences(of: "[ <>]", with: "", options: .regularExpression, range: nil)
            if !notifTokenStr.isEmpty {
                if _keychain["notificationToken"] != nil {
                    if notifTokenStr != _keychain["notificationToken"] {
                        if Singletons.WalletsDB.wallets_list.count == 0 {
                            // Supprimer tout ceux avec l'ancien tokens
                            deleteAllData(forNotifToken: notifTokenStr)
                        } else {
                            // Changer le token dans la db
                            updateNotifTokenInDB(forOldNotifToken: _keychain["notificationToken"]!, withNewNotifToken: notifTokenStr)
                        }
                    }
                }
                // Enregistrer dans _keychain["notificationToken"]
                _keychain["notificationToken"] = notifTokenStr
            }
        }
    }
    fileprivate func updateNotifTokenInDB(forOldNotifToken oldNotifToken:String, withNewNotifToken newNotifToken: String) {
        // Changer dans la db pour chaque wallet
        var updateObject:[String:String] = [:]
        ref.child("TokenReceivedNotification").queryOrdered(byChild: "notifToken").queryEqual(toValue: oldNotifToken).observeSingleEvent(of: .value) { (snapshot) in
            for snap in snapshot.children.allObjects as! [DataSnapshot] {
                updateObject["/TokenReceivedNotification/\(snap.key)/notifToken"] = newNotifToken
            }
            // Changer dans la db pour chaque token
            self.ref.child("TokenListedNotification").queryOrdered(byChild: "notifToken").queryEqual(toValue: oldNotifToken).observeSingleEvent(of: .value) { (snapshot) in
                for snap in snapshot.children.allObjects as! [DataSnapshot] {
                    updateObject["/TokenListedNotification/\(snap.key)/notifToken"] = newNotifToken
                }
                self.ref.updateChildValues(updateObject)
            }
        }
    }
    fileprivate func deleteAllData(forNotifToken notifToken:String){
        // Supprimer les notifs lorsqu'on reçoit des tokens pour cette adresse
        ref.child("TokenReceivedNotification").queryOrdered(byChild: "notifToken").queryEqual(toValue: notifToken).observeSingleEvent(of: .value) { (snapshot) in
            for snap in snapshot.children.allObjects as! [DataSnapshot] {
                snap.ref.removeValue()
            }
        }
        // Supprimer les notifs que l'on reçoit lorsqu'un token est listé
        removeTokenListedNotificationFromDB(forNotificationToken: notifToken)
    }
    
//    Token Received Notifications
    func turnOnTokenReceivedNotification(){
        notifQueue.sync {
            while notificationToken == nil {
                sleep(1)
            }
            _keychain["TokensReceivedNotification"] = true.description
            for wallet in Singletons.WalletsDB.wallets_list {
                newWalletForNotification(wallet)
            }
        }
    }
    func turnOffTokenReceivedNotification(){
        notifQueue.sync {
            _keychain["TokensReceivedNotification"] = false.description
            for wallet in Singletons.WalletsDB.wallets_list {
                deleteWalletForNotification(wallet)
            }
        }
    }
    func newWalletForNotification(_ wallet:Wallet){
        notifQueue.sync {
            if TokensReceivedNotification,
                let notifToken = notificationToken,
                !notifToken.isEmpty {
                ref.child("TokenReceivedNotification").childByAutoId().setValue([
                    "wallet" : wallet.erc20Address,
                    "notifToken" : notifToken,
                    "wallet_notifToken" : "\(wallet.erc20Address)_\(notifToken)" ])
            } else { print("ERREUR : le notification token est vide : \(notificationToken ?? "_")") }
        }
    }
    func deleteWalletForNotification(_ wallet:Wallet){
        notifQueue.sync {
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
    }
    
// Token Listed Notification
    func turnOnTokenListedNotification(){
        notifQueue.sync {
            while notificationToken == nil {
                sleep(1)
            }
            _keychain["TokenListedNotification"] = true.description
            for wallet in Singletons.WalletsDB.wallets_list {
                // En mettant a jour les wallets, les tokens s'enregistrent automatiquement dans la db
                wallet.updateBalances {}
            }
        }
    }
    func turnOffTokenListedNotification(){
        notifQueue.sync {
            _keychain["TokenListedNotification"] = false.description
            if let notifToken = notificationToken,
                !notifToken.isEmpty {
                removeTokenListedNotificationFromDB(forNotificationToken: notifToken)
            }
        }
    }
    fileprivate func removeTokenListedNotificationFromDB(forNotificationToken notifToken: String) {
        // On récupére toutes les entrées avec le bon notifToken
        ref.child("TokenListedNotification").queryOrdered(byChild: "notifToken").queryEqual(toValue: notifToken).observeSingleEvent(of: .value) { (snapshot) in
            // Puis on les supprime une à une
            for snap in snapshot.children.allObjects as! [DataSnapshot] {
                snap.ref.removeValue()
            }
        }
    }
    func newTokenForNotification(_ token:token){
        notifQueue.sync {
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
    
}
