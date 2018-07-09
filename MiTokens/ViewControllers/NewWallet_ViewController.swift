//
//  NewWallet_ViewController.swift
//  MiTokens
//
//  Created by Romain Penchenat on 23/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit

class NewWallet_ViewController: TopBarAd_ViewController, UITextFieldDelegate {

    @IBOutlet weak var ui_nameInput: MiTokens_TextField!
    @IBOutlet weak var ui_publicKeyInput: MiTokens_TextField!
    @IBOutlet weak var ui_AddWalletFormButton: MiTokens_button!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ui_nameInput.delegate = self
        ui_publicKeyInput.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    Formulaire d'ajout de wallet
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case ui_nameInput:
            ui_publicKeyInput.becomeFirstResponder()
            break
        case ui_publicKeyInput:
            ui_publicKeyInput.resignFirstResponder()
            createNewWallet()
            break
        default:
            break
        }
        return false
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let input = textField as? MiTokens_TextField,
            let text = input.text {
            input.inputState = text.count == 0 ? .empty : .filled
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == ui_publicKeyInput,
            range.location == 0,
            string.count > 1 {
            ui_publicKeyInput.text = string.trimmingCharacters(in: .whitespaces)
            return false
        } else if textField == ui_nameInput,
            let currentString = textField.text,
            (currentString.count + string.count) > 10 {
            return false
        } else {
            return true
        }
    }

    
//    Action "Ajouter ce wallet"
    
    @IBAction func addANewWallet(_ sender: Any) {
        createNewWallet()
    }
    
    private func createNewWallet(){
        // Vérifier l'input nom
        if let name = ui_nameInput.text,
            let publicKey = ui_publicKeyInput.text?.stringByRemovingWhitespaces,
            name.count != 0,
            name.count <= 10 {
            // Vérifier que ce wallet n'est pas déja enregistré dans l'app
            if Singletons.WalletsDB.verifIfWalletAddressIsNotAlreadyRegister(publicKey) {
                // Informer l'utilisateur
                ui_AddWalletFormButton.setTitle("Ajout en cours ...", for: .normal)
                // Vérifier l'existence du wallet
                Singletons.API.getTokensOnAccount(withPublicKey: publicKey) { (jsonResponse) in
                    self.ui_AddWalletFormButton.setTitle("Ajouter ce wallet", for: .normal)
                    if jsonResponse != nil {
                        // Ajouter le compte à la base de données
                        let newWallet = Wallet(dataFromEthphlorer: jsonResponse!, withName: name)
                        Singletons.WalletsDB.addWallet(wallet: newWallet)
                        // Vider le formulaire
                        self.ui_nameInput.text = ""
                        self.ui_nameInput.inputState = .empty
                        self.ui_publicKeyInput.text = ""
                        self.ui_nameInput.inputState = .empty
                        // Afficher dans la liste
                        self.performSegue(withIdentifier: "walletAdded", sender: nil)
                    } else {
                        // Afficher erreur adresse erc20
                        self.ui_publicKeyInput.inputState = .wError
                    }
                }
            } else {
                ui_publicKeyInput.inputState = .wError
            }
        } else {
            // Afficher erreur nom vide
            ui_nameInput.inputState = .wError
        }
    }
    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "walletAdded",
            let destination = segue.destination as? Wallets_ViewController {
            destination.newWalletAdded()
        }
    }

}
