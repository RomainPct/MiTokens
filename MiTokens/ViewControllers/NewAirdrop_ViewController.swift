//
//  NewAirdrop_ViewController.swift
//  MiTokens
//
//  Created by Romain Penchenat on 27/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit
import GoogleMobileAds

class NewAirdrop_ViewController: TopBarAd_ViewController, UITextFieldDelegate {

    var wasEdited:Bool = false
    
    @IBOutlet weak var ui_nameInput: MiTokens_TextField!
    @IBOutlet weak var ui_symbolInput: MiTokens_TextField!
    @IBOutlet weak var ui_amountInput: MiTokens_TextField!
    @IBOutlet weak var ui_referralAmountInput: MiTokens_TextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ui_nameInput.delegate = self
        ui_symbolInput.delegate = self
        ui_amountInput.delegate = self
        ui_referralAmountInput.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    Text field delegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case ui_nameInput: ui_amountInput.becomeFirstResponder()
        case ui_symbolInput: ui_symbolInput.resignFirstResponder()
        default: break
        }
        return true
    }
    
//    Action : "Ajouter un airdrop"
    @IBAction func createAirdrop(_ sender: MiTokens_button) {
        if let name = verifInput(input: ui_nameInput, isAnAmount: false),
            let symbol = verifInput(input: ui_symbolInput, isAnAmount: false),
            let amount = verifInput(input: ui_amountInput, isAnAmount: true),
            let referral = verifInput(input: ui_referralAmountInput, isAnAmount: true) {
            let newAirdrop = Airdrop(name: name, symbol: symbol, amount: amount, referral: referral)
            Singletons.AirdropsDB.addAirdrop(airdrop: newAirdrop)
            wasEdited = true
            performSegue(withIdentifier: "goBackHome", sender: nil)
        }
    }
    
    private func verifInput(input:MiTokens_TextField, isAnAmount:Bool) -> String? {
        guard let value = input.text else {
            input.inputState = .empty
            return nil
        }
        if (isAnAmount && value.isAnAmount) || (!isAnAmount && !value.isEmpty) {
            input.inputState = .filled
            return value
        } else {
            input.inputState = .empty
            return nil
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Prepare segue : \(segue)")
        if wasEdited,
            let nextVC = segue.destination as? HomeViewController {
            nextVC._needReload = true
            nextVC.ui_collectionView.reloadData()
        }
    }

}
