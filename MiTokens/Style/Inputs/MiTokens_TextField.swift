//
//  MiTokens_TextField.swift
//  MiTokens
//
//  Created by Romain Penchenat on 06/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit

class MiTokens_TextField: UITextField {
    
    enum state {
        case empty
        case filled
        case wError
    }
    
    private var _inputState:state?
    
    var inputState: state {
        get {
            return _inputState!
        }
        set {
            _inputState = newValue
            switch newValue {
            case .empty:
                layer.borderColor = UIColor(named: "Blue")?.cgColor
            case .filled:
                layer.borderColor = UIColor(named: "Green")?.cgColor
            case .wError:
                layer.borderColor = UIColor(named: "Orange")?.cgColor
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        borderStyle = .none
        layer.cornerRadius = 5
        layer.borderWidth = 1
        font = UIFont(name: "Raleway-Regular", size: 13)
        if _inputState == nil {
            inputState = .empty
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(8, 8, 8, 8))
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(8, 8, 8, 8))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(8, 8, 8, 8))
    }

}
