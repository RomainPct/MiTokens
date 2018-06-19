//
//  String_extension.swift
//  MiTokens
//
//  Created by Romain Penchenat on 06/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//
import UIKit
import Foundation
extension String {
    var isBackspace: Bool {
        let char = self.cString(using: String.Encoding.utf8)!
        return strcmp(char, "\\b") == -92
    }
    
    var isAnAmount:Bool {
        if (Double(self) != nil || self == "") {
            return true
        } else {
            return false
        }
    }
    
    var stringByRemovingWhitespaces: String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    func amountToDouble() -> Double? {
        // Supprimer les espaces -> Remplacer les "," par des "." -> Transformer en Double
        return Double(self.stringByRemovingWhitespaces.replacingOccurrences(of: ",", with: "."))
    }
}
