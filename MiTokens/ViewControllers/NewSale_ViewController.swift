//
//  NewSale_ViewController.swift
//  MiTokens
//
//  Created by Romain Penchenat on 06/06/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit

class NewSale_ViewController: TopBarAd_ViewController, UITextFieldDelegate {
    
    @IBOutlet weak var ui_amountInput: MiTokens_TextField!
    @IBOutlet weak var ui_tokensLabel: Body_label!
    @IBOutlet weak var ui_valueInput: MiTokens_TextField!
    @IBOutlet weak var ui_currencyLabel: Body_label!
    
    var airdrop:Airdrop?
    var targetRedirectionAirdrop:Airdrop?
    
    fileprivate func setScreen() {
        if airdrop != nil {
            ui_amountInput.text = airdrop!.totalAmount.stringByRemovingWhitespaces
            ui_amountInput.inputState = .filled
            ui_tokensLabel.text = airdrop!.symbol!
            airdrop?.getValue(handler: { (value) in
                if value != nil {
                    let totalValue = value!.getTotalValue(forAmount: (self.airdrop!.totalAmount.amountToDouble() ?? 0))
                    self.ui_valueInput.text = totalValue.asAmount(withMaxDigits: 2)
                    self.ui_valueInput.inputState = .filled
                }
            })
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setScreen()
        ui_amountInput.delegate = self
        ui_valueInput.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//    TextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let input = textField as! MiTokens_TextField
        if input.inputState == .wError {
            input.text = ""
            input.inputState = .empty
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        let input = textField as! MiTokens_TextField
        if let value = input.text {
            if value.isAnAmount {
                if value == "" { input.text = "0" }
                input.inputState = .filled
            } else {
                input.inputState = .wError
            }
        }
    }
    
//    "Enregistrer la vente"
    @IBAction func validateTheSale(_ sender: MiTokens_button) {
        ui_amountInput.resignFirstResponder()
        ui_valueInput.resignFirstResponder()
        if let amount = ui_amountInput.text?.amountToDouble(),
            let value = ui_valueInput.text?.amountToDouble(),
            let totalAmount = airdrop!.totalAmount.amountToDouble() {
            if amount > totalAmount {
                ui_amountInput.inputState = .wError
            } else if amount == airdrop!.totalAmount.amountToDouble() {
                // Si la quantité est la quantité totale de l'airdrop
                Singletons.AirdropsDB.editState(toState: .sold, ofAirdrop: airdrop!)
                Singletons.AirdropsDB.saveASale(withTotalPrice: value, ofAirdrop: airdrop!)
                goToAirdropSold(airdrop!)
            } else {
                // Sinon
                let newAirdrop = Airdrop(fromOtherAirdrop: airdrop!, withAmount: amount, forTotalPrice: value)
                Singletons.AirdropsDB.addAirdrop(airdrop: newAirdrop)
                let restAmount = totalAmount - amount
                Singletons.AirdropsDB.editAmounts(amount: restAmount.asAmount(withMaxDigits: 6), amountReferral: "0", ofAirdrop: airdrop!)
                // Créer un nouveau lien
                if let oldLink = airdrop?.link {
                    let newLink = Link(fromLink: oldLink, withNewAirdropId: newAirdrop.airdropID)
                    Singletons.LinksDB.addALink(link: newLink)
                }
                goToAirdropSold(newAirdrop)
            }
        }
    }
    
    func goToAirdropSold(_ airdrop:Airdrop) {
        targetRedirectionAirdrop = airdrop
        performSegue(withIdentifier: "goBackHome", sender: nil)
    }
    
//    Quitter la vente
    @IBAction func cancelSale(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
//    Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goBackHome",
            let nextVC = segue.destination as? HomeViewController {
            nextVC._needReload = true
            nextVC.ui_collectionView.reloadData()
            nextVC.targetAirdropRedirection = targetRedirectionAirdrop
        }
    }
    
}
