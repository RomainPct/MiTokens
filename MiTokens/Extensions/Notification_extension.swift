//
//  NotificationCenter_extension.swift
//  MiTokens
//
//  Created by Romain Penchenat on 14/07/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    static let ETHPriceIsUpdate = Notification.Name("ETHPriceIsUpdate")
    static let NotificationTokenReceived = Notification.Name(rawValue: "NotificationTokenRecieved")
    
}
