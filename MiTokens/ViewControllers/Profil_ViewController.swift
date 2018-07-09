//
//  Profil_ViewController.swift
//  MiTokens
//
//  Created by Romain Penchenat on 06/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit
import Alamofire
import KeychainAccess
import UserNotifications

class Profil_ViewController: UIViewController, UIApplicationDelegate {
    
    let notifManager = NotificationManager()
    
    @IBOutlet weak var ui_statLabel: Body_label!
    @IBOutlet weak var ui_tokensReceivedNotification: ColorIndicator_view!
    @IBOutlet weak var ui_tokensListedNotification: ColorIndicator_view!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStats()
    }
    override func viewDidAppear(_ animated: Bool) {
        setNotifications()
    }
    
    fileprivate func setStats() {
        ui_statLabel.text = """
        Airdrops en attente : \(Singletons.AirdropsDB.countAirdrops(withState: .waiting))
        Airdrops actuellement sur votre wallet : \(Singletons.AirdropsDB.countAirdrops(withState: .received))
        
        Ventes réalisées : \(Singletons.AirdropsDB.countAirdrops(withState: .sold))
        Valeur totale : \(Singletons.AirdropsDB.countValue(forState: .sold).asAmount(withDigits: 2))€
        """
    }
    fileprivate func setNotifications(){
        print("Tokens received : \(notifManager.TokensReceivedNotification)")
        print("Tokens listed : \(notifManager.TokenListedNotification)")
        // Arreter les animations
        ui_tokensReceivedNotification.stopChangingStateAnimation()
        ui_tokensListedNotification.stopChangingStateAnimation()
        ui_tokensReceivedNotification.backgroundColor = notifManager.TokensReceivedNotification ? #colorLiteral(red: 0.1369999945, green: 0.9100000262, blue: 0.3490000069, alpha: 1) : #colorLiteral(red: 1, green: 0.5410000086, blue: 0.09799999744, alpha: 1)
        ui_tokensListedNotification.backgroundColor = notifManager.TokenListedNotification ? #colorLiteral(red: 0.1369999945, green: 0.9100000262, blue: 0.3490000069, alpha: 1) : #colorLiteral(red: 1, green: 0.5410000086, blue: 0.09799999744, alpha: 1)
    }
    
    override func didReceiveMemoryWarning() {
        print("Memory warning")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationManager().setNotificationToken(deviceToken)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }

    fileprivate func verifNotificationAuth(handler:@escaping ()->Void){
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                UNUserNotificationCenter.current().requestAuthorization(options: [.badge,.alert]) { (answer, error) in
                    if answer == true {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                            handler() 
                        }
                    } else {
                        let alert = UIAlertController(title: "Activez les notifications", message: "Afin d'activer cette fonctionnalité, vous devez activer les notifications pour l'application MiTokens dans les Règlages de votre téléphone.", preferredStyle: .actionSheet)
                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } else {
                handler()
            }
        }
    }
    @IBAction func tapOnTokensReceivedNotification(_ sender: Any) {
        ui_tokensReceivedNotification.startChangingStateAnimation()
        verifNotificationAuth {
            self.setTokenReceivedNotification()
        }
    }
    fileprivate func setTokenReceivedNotification() {
        let cancelAction = UIAlertAction(title: "Annuler", style: .cancel) { (_) in
            self.setNotifications()
        }
        if notifManager.TokensReceivedNotification {
            let alert = UIAlertController(title: "Ne plus recevoir de notifications lorsque vous recevez des tokens", message: "Souhaitez-vous vraiment ne plus être alerter lorsque vous recevez des tokens sur vos wallets ?", preferredStyle: .actionSheet)
            alert.addAction(cancelAction)
            alert.addAction(UIAlertAction(title: "Ne plus recevoir de notifs", style: .default, handler: { (_) in
                self.notifManager.turnOffTokenReceivedNotification()
                self.setNotifications()
            }))
            present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Recevoir de notifications lorsque vous recevez des tokens", message: "Souhaitez-vous être notifié lorsque vous recevez des tokens sur vos wallets ?", preferredStyle: .actionSheet)
            alert.addAction(cancelAction)
            alert.addAction(UIAlertAction(title: "Être notifié lorsque je reçois des tokens", style: .default, handler: { (_) in
                self.notifManager.turnOnTokenReceivedNotification {
                    self.setNotifications()
                }
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func tapOnTokenListedNotification(_ sender: Any) {
        ui_tokensListedNotification.startChangingStateAnimation()
        verifNotificationAuth {
            self.setTokenListedNotification()
        }
    }
    fileprivate func setTokenListedNotification() {
        let cancelAction = UIAlertAction(title: "Annuler", style: .cancel) { (_) in
            self.setNotifications()
        }
        if notifManager.TokenListedNotification {
            let alert = UIAlertController(title: "Ne plus recevoir de notifications lorsqu'un de mes tokens est listé", message: "Souhaitez-vous vraiment ne plus être alerter lorsque l'un de vos tokens est listé sur une plateforme d'échange ?", preferredStyle: .actionSheet)
            alert.addAction(cancelAction)
            alert.addAction(UIAlertAction(title: "Ne plus recevoir de notifs", style: .default, handler: { (_) in
                self.notifManager.turnOffTokenListedNotification {
                    self.setNotifications()
                }
            }))
            present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Recevoir de notifications lorsque l'un de mes tokens est listé", message: "Souhaitez-vous être alerter lorsque l'un de vos tokens est listé sur une plateforme d'échange ?", preferredStyle: .actionSheet)
            alert.addAction(cancelAction)
            alert.addAction(UIAlertAction(title: "Être notifié lorsque un token est listé", style: .default, handler: { (_) in
                self.notifManager.turnOnTokenListedNotification {
                    self.setNotifications()
                }
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
}
