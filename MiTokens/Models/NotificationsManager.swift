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
    
    fileprivate let _KEY_tokendReceived = "TokenReceivedNotification"
    fileprivate let _KEY_tokenListed = "TokenListedNotification"
    fileprivate let _KEY_notificationToken = "notificationToken"
    
    var TokensReceivedNotification: Bool {
        return Bool(_keychain[_KEY_tokendReceived] ?? "false") ?? false
    }
    
    var TokenListedNotification: Bool {
        return Bool(_keychain[_KEY_tokenListed] ?? "false") ?? false
    }
    
    var notificationToken: String? {
        return _keychain[_KEY_notificationToken]
    }
    
//    Gestion du token de notification
    func setNotificationToken(_ notifToken:Data){
        _ = Singletons.WalletsDB
        DispatchQueue.global(qos: .background).async {
            let notifTokenStr = (notifToken as NSData).description.replacingOccurrences(of: "[ <>]", with: "", options: .regularExpression, range: nil)
            if !notifTokenStr.isEmpty {
                if self.notificationToken != nil,
                    notifTokenStr != self.notificationToken {
                    if Singletons.WalletsDB.wallets_list.count == 0 {
                        // Supprimer tout ceux avec l'ancien token
                        self.deleteAllData(forNotifToken: notifTokenStr)
                    } else {
                        // Changer le token dans la db
                        self.updateNotifTokenInDB(forOldNotifToken: self.notificationToken!, withNewNotifToken: notifTokenStr)
                    }
                }
                // Enregistrer dans _keychain[_KEY_notificationToken]
                self._keychain[self._KEY_notificationToken] = notifTokenStr
                NotificationCenter.default.post(name: NSNotification.Name.NotificationTokenReceived, object: nil)
            }
        }
    }
    fileprivate func updateNotifTokenInDB(forOldNotifToken oldNotifToken:String, withNewNotifToken newNotifToken: String) {
        // Changer dans la db pour chaque wallet
        var updateObject:[String:String] = [:]
        ref.child(_KEY_tokendReceived).queryOrdered(byChild: "notifToken").queryEqual(toValue: oldNotifToken).observeSingleEvent(of: .value) { (snapshot) in
            for snap in snapshot.children.allObjects as! [DataSnapshot] {
                updateObject["/TokenReceivedNotification/\(snap.key)/notifToken"] = newNotifToken
            }
            // Changer dans la db pour chaque token
            self.ref.child(self._KEY_tokenListed).queryOrdered(byChild: "notifToken").queryEqual(toValue: oldNotifToken).observeSingleEvent(of: .value) { (snapshot) in
                for snap in snapshot.children.allObjects as! [DataSnapshot] {
                    updateObject["/TokenListedNotification/\(snap.key)/notifToken"] = newNotifToken
                }
                self.ref.updateChildValues(updateObject)
            }
        }
    }
    fileprivate func deleteAllData(forNotifToken notifToken:String){
        // Supprimer les notifs lorsqu'on reçoit des tokens pour cette adresse
        ref.child(_KEY_tokendReceived).queryOrdered(byChild: "notifToken").queryEqual(toValue: notifToken).observeSingleEvent(of: .value) { (snapshot) in
            for snap in snapshot.children.allObjects as! [DataSnapshot] {
                snap.ref.removeValue()
            }
        }
        // Supprimer les notifs que l'on reçoit lorsqu'un token est listé
        removeTokenListedNotificationFromDB(forNotificationToken: notifToken)
    }
    
//    Gestion ouverture de l'app sans authorisation pour les notifications
    func notAuthorizedToSendNotifications() {
        DispatchQueue.global(qos: .background).async {
            // Si un token est cependant déja enregistré
            if self.notificationToken != nil {
                // Supprimer les enregistrements de la db
                self.deleteAllData(forNotifToken: self.notificationToken!)
                // Reset les variables keychain
                self._keychain[self._KEY_tokendReceived] = false.description
                self._keychain[self._KEY_tokenListed] = false.description
                self._keychain[self._KEY_notificationToken] = nil
            }
        }
    }
    
//    Token Received Notifications
    fileprivate func executeturnOnTokenReceivedNotification(_ handler: () -> Void) {
        _keychain[_KEY_tokendReceived] = true.description
        for wallet in Singletons.WalletsDB.wallets_list {
            self.newWalletForNotification(wallet)
        }
        handler()
    }
    
    func turnOnTokenReceivedNotification(handler:@escaping ()->Void){
        if notificationToken != nil {
            executeturnOnTokenReceivedNotification(handler)
        } else {
            NotificationCenter.default.addObserver(forName: NSNotification.Name.NotificationTokenReceived, object: nil, queue: nil) { (_) in
                self.executeturnOnTokenReceivedNotification(handler)
            }
        }
//        DispatchQueue.global(qos: .background).async {
//            while self.notificationToken == nil {
//                sleep(1)
//            }
//            self._keychain[self._KEY_tokendReceived] = true.description
//            DispatchQueue.main.sync {
//                for wallet in Singletons.WalletsDB.wallets_list {
//                    self.newWalletForNotification(wallet)
//                }
//                handler()
//            }
//        }
    }
    func turnOffTokenReceivedNotification(){
        self._keychain[self._KEY_tokendReceived] = false.description
        for wallet in Singletons.WalletsDB.wallets_list {
            self.deleteWalletForNotification(wallet)
        }
    }
    func newWalletForNotification(_ wallet:Wallet){
        if self.TokensReceivedNotification,
            let notifToken = self.notificationToken,
            !notifToken.isEmpty {
            self.ref.child(self._KEY_tokendReceived).childByAutoId().setValue([
                "wallet" : wallet.erc20Address,
                "notifToken" : notifToken,
                "wallet_notifToken" : "\(wallet.erc20Address)_\(notifToken)" ])
        } else { print("ERREUR : le notification token est vide : \(self.notificationToken ?? "_")") }
    }
    func deleteWalletForNotification(_ wallet:Wallet){
        if let notifToken = self.notificationToken,
            !notifToken.isEmpty {
            // On récupére toutes les entrées avec le bon wallet et le bon notifToken
            self.ref.child(self._KEY_tokendReceived).queryOrdered(byChild: "wallet_notifToken").queryEqual(toValue: "\(wallet.erc20Address)_\(notifToken)").observeSingleEvent(of: .value) { (snapshot) in
                // Puis on les supprime une à une
                for snap in snapshot.children.allObjects as! [DataSnapshot] {
                    snap.ref.removeValue()
                }
            }
        }
    }
    
// Token Listed Notification
    fileprivate func executeTurnOnTokenListedNotification(_ handler: () -> Void) {
        _keychain[_KEY_tokenListed] = true.description
        for wallet in Singletons.WalletsDB.wallets_list {
            // En mettant a jour les wallets, les tokens s'enregistrent automatiquement dans la db
            wallet.updateBalances(forcing: true, handler: {})
        }
        handler()
    }
    
    func turnOnTokenListedNotification(handler:@escaping ()->Void){
        if notificationToken != nil {
            executeTurnOnTokenListedNotification(handler)
        } else {
            NotificationCenter.default.addObserver(forName: NSNotification.Name.NotificationTokenReceived, object: nil, queue: nil) { (_) in
                self.executeTurnOnTokenListedNotification(handler)
            }
        }
//        DispatchQueue.global(qos: .background).async {
//            while self.notificationToken == nil {
//                sleep(1)
//            }
//            self._keychain[self._KEY_tokenListed] = true.description
//            DispatchQueue.main.async {
//                executeTurnOnTokenListedNotification()
//            }
//        }
    }
    func turnOffTokenListedNotification(handler:@escaping ()->Void){
        DispatchQueue.global(qos: .background).async {
            self._keychain[self._KEY_tokenListed] = false.description
            if let notifToken = self.notificationToken,
                !notifToken.isEmpty {
                self.removeTokenListedNotificationFromDB(forNotificationToken: notifToken)
            }
            DispatchQueue.main.sync {
                handler()
            }
        }
    }
    fileprivate func removeTokenListedNotificationFromDB(forNotificationToken notifToken: String) {
        // On récupére toutes les entrées avec le bon notifToken
        ref.child(self._KEY_tokenListed).queryOrdered(byChild: "notifToken").queryEqual(toValue: notifToken).observeSingleEvent(of: .value) { (snapshot) in
            // Puis on les supprime une à une
            for snap in snapshot.children.allObjects as! [DataSnapshot] {
                snap.ref.removeValue()
            }
        }
    }
    func newTokenForNotification(_ token:token){
        if self.TokenListedNotification,
            let notifToken = self.notificationToken,
            !notifToken.isEmpty {
            token.getValue(ofSmartContract: token.smartContract, wName: token.name, wSymbol: token.symbol) { (answer) in
                if answer == nil {
                    // On vérifie si la demande notif est déja enregistré dans la base de données
                    self.ref.child(self._KEY_tokenListed).queryOrdered(byChild: "smartContract_notifToken").queryEqual(toValue: "\(token.smartContract)_\(notifToken)").observeSingleEvent(of: .value, with: { (snapshot) in
                        if !snapshot.exists() {
                            // Si il n'existe pas dans la db alors on l'enregistre
                            self.ref.child(self._KEY_tokenListed).childByAutoId().setValue([
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
