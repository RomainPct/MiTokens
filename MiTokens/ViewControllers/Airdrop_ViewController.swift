//
//  Airdrop_ViewController.swift
//  MiTokens
//
//  Created by Romain Penchenat on 10/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit
import GoogleMobileAds

class Airdrop_ViewController: TopBarAd_ViewController, UITextFieldDelegate {

//    Var
    var airdrop:Airdrop?
    var userIsEditing = false
    var wasEdited = false
    var comeFromWallets = false
    lazy var scrollToEdit = view.convert(ui_amountInput.bounds, from: ui_amountInput.superview).maxY - (view.frame.height/2)
    
//    Outlets
    @IBOutlet weak var ui_scrollView: UIScrollView!
    @IBOutlet weak var ui_nameLabel: Important_label!
    @IBOutlet weak var ui_infoLabel: Body_label!
    @IBOutlet weak var ui_valueFullBox: UIView!
    @IBOutlet weak var ui_notListedContainer: UIView!
    @IBOutlet weak var ui_valueContainer: UIView!
    @IBOutlet weak var ui_listedLabel: Body_label!
    @IBOutlet weak var ui_thisHourLabel: Body_label!
    @IBOutlet weak var ui_thisHourArrow: UIImageView!
    @IBOutlet weak var ui_dayLabel: Body_label!
    @IBOutlet weak var ui_todayArrow: UIImageView!
    @IBOutlet weak var ui_weekLabel: Body_label!
    @IBOutlet weak var ui_weekArrow: UIImageView!
    
//    Etat
    @IBOutlet weak var ui_statesStackView: UIStackView!
    @IBOutlet weak var ui_waitingState: GreyView!
    @IBOutlet weak var ui_receivedState: GreyView!
    @IBOutlet weak var ui_soldState: GreyView!
    @IBOutlet weak var ui_colorIndicator: ColorIndicator_view!
    
//    Modifier
    @IBOutlet weak var ui_editHeaderView: UIView!
    @IBOutlet weak var cs_editHeaderHeight: NSLayoutConstraint!
    @IBOutlet weak var ui_amountInput: UITextField!
    @IBOutlet weak var ui_referralAmountInput: MiTokens_TextField!
    @IBOutlet weak var ui_editingForm: UIView!
    @IBOutlet weak var cs_formHeight: NSLayoutConstraint!
    @IBOutlet weak var ui_editButton: MiTokens_button!
    var cs_editButtonHeight: NSLayoutConstraint?
    @IBOutlet weak var ui_soldSomeTokensButton: MiTokens_button!
    @IBOutlet weak var ui_notReceivedButton: UIButton!
    @IBOutlet weak var cs_notReceivedButtonHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        guard airdrop != nil else {
            dismiss(animated: true, completion: nil)
            return
        }
        super.viewDidLoad()
        // Gérer l'affichage
        ui_nameLabel.text = """
        \(airdrop!.name)
        [\(airdrop!.totalAmount) \(airdrop!.symbol!)]
        """
        setState()
        ui_amountInput.text = airdrop!.amount
        ui_referralAmountInput.text = airdrop?.referral
        
        // Gestion des delegate
        ui_amountInput.delegate = self
        ui_referralAmountInput.delegate = self
    }
    private func setState(){
        switch airdrop!.stateEnum {
        case .waiting:
            // Changer texte description
            ui_infoLabel.text = "réalisé le \(airdrop!.creationDate)"
            // Cacher partie valeur
            ui_valueFullBox.addConstraint(NSLayoutConstraint(item: ui_valueFullBox, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0))
            // Adapter l'affichage à l'état "en attente"
            ui_waitingState.isHidden = false
            ui_colorIndicator.backgroundColor = UIColor(named: "Orange")
            ui_waitingState.alpha = 1
        case .received:
            // Changer texte description
            ui_infoLabel.text = """
            réalisé le \(airdrop!.creationDate.format())
            Adresse du smart contract :
            \(airdrop!.smartContract)
            """
            // Gestion si token listé ou non
            setValue()
            // Adapter l'affichage à l'état "reçu"
            ui_statesStackView.distribution = .fill
            ui_receivedState.isHidden = false
            ui_receivedState.alpha = 1
            ui_soldSomeTokensButton.isHidden = false
            ui_soldSomeTokensButton.setTitle("J'ai vendu des \(airdrop!.symbol!)", for: .normal)
            ui_colorIndicator.backgroundColor = UIColor(named: "Green")
            // Afficher bouton "Je n'ai pas reçu ce airdrop"
            if cs_notReceivedButtonHeight != nil {
                cs_notReceivedButtonHeight.isActive = false
            }
            // Cacher bouton "Modifier"
            hideEditButton()
        case .sold:
            ui_colorIndicator.backgroundColor = UIColor(named: "Blue")
            ui_soldState.alpha = 1
            // Changer texte description
            ui_infoLabel.text = """
            \(airdrop!.totalAmount) \(airdrop!.symbol!) vendus pour \(airdrop!.saleTotalPrice)€ le \(airdrop!.saleDate!.format())
            Airdrop réalisé le \(airdrop!.creationDate.format())
            Adresse du smart contract :
            \(airdrop!.smartContract)
            """
            // Gestion si token listé ou non
            setValue()
            // Adapter l'affichage à l'état "vendu"
            ui_soldState.isHidden = false
            // Cacher bouton "Modifier"
            hideEditButton()
        }
    }
    
    private func setValue(){
        airdrop?.getValue(handler: { (value) in
            if let value = value {
                // Cacher la partie "Non listé"
                self.ui_notListedContainer.addConstraint(NSLayoutConstraint(item: self.ui_notListedContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0))
                
                let totalValue = value.getTotalValue(forAmount: (self.airdrop!.totalAmount.amountToDouble() ?? 0))
                
                self.ui_listedLabel.text = """
                Valeur totale actuelle : \( totalValue.asAmount(withDigits: 2)) €
                Ce token est listé à \(value.price.asAmount(withMaxDigits: 4)) € / \(self.airdrop!.symbol!)
                """
                
                // Changement sur 1H
                var diff1h = "\(value.diff1h?.asAmount(withMaxDigits: 1) ?? "") %"
                if diff1h == " %" {
                    diff1h = "inconnu"
                    self.ui_thisHourArrow.image = #imageLiteral(resourceName: "Middle")
                } else if !diff1h.contains("-") {
                    self.ui_thisHourArrow.image = UIImage(named: "Arrow Up")
                    diff1h = "+\(diff1h)"
                }
                // Changement sur 1 jour
                var diff1d = "\(value.diff1d?.asAmount(withMaxDigits: 1) ?? "") %"
                if diff1d == " %" {
                    diff1d = "inconnu"
                    self.ui_todayArrow.image = #imageLiteral(resourceName: "Middle")
                } else if !diff1d.contains("-") {
                    self.ui_todayArrow.image = UIImage(named: "Arrow Up")
                    diff1d = "+\(diff1d)"
                }
                // Changement sur 1 semaine
                var diff1w = "\(value.diff1w?.asAmount(withMaxDigits: 1) ?? "") %"
                if diff1w == " %" {
                  diff1w = "inconnu"
                    self.ui_weekArrow.image = #imageLiteral(resourceName: "Middle")
                } else if !diff1w.contains("-") {
                    self.ui_weekArrow.image = UIImage(named: "Arrow Up")
                    diff1w = "+\(diff1w)"
                }
                
                // Affichage des valeurs
                self.ui_thisHourLabel.text = """
                \(diff1h)
                cette heure-ci
                """
                self.ui_dayLabel.text = """
                \(diff1d)
                aujourd'hui
                """
                self.ui_weekLabel.text = """
                \(diff1w)
                cette semaine
                """
                
            } else {
                // Cacher la partie des valeurs
                self.ui_valueContainer.addConstraint(NSLayoutConstraint(item: self.ui_valueContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0))
            }
        })

    }
    
    private func hideEditButton() {
        cs_editButtonHeight = NSLayoutConstraint(item: ui_editButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        ui_editButton.addConstraint(cs_editButtonHeight!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    Textfield delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        ui_scrollView.setContentOffset(CGPoint(x: 0, y: scrollToEdit), animated: true)
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        ui_scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        return true
    }
    @IBAction func leftInputs(_ sender: Any) {
        ui_amountInput.resignFirstResponder()
        ui_referralAmountInput.resignFirstResponder()
    }
    

//    Modifier l'aidrop
    fileprivate func closeEditForm() {
        // Fermer le form
        userIsEditing = false
        ui_editButton.setTitle("Modifier", for: .normal)
        cs_formHeight = NSLayoutConstraint(item: ui_editingForm, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        cs_formHeight.isActive = true
        cs_editHeaderHeight = NSLayoutConstraint(item: ui_editHeaderView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        cs_editHeaderHeight.isActive = true
        UIView.animate(withDuration: 0.15) {
            self.ui_receivedState.isHidden = true
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func editAirdrop(_ sender: Any) {
        if userIsEditing {
            ui_amountInput.resignFirstResponder()
            ui_referralAmountInput.resignFirstResponder()
            // Enregistrer les nouveaux montants
            if let amount = ui_amountInput.text?.replacingOccurrences(of: ",", with: "+"),
                let referral = ui_referralAmountInput.text?.replacingOccurrences(of: ",", with: "+"),
                amount.isAnAmount,
                referral.isAnAmount {
                Singletons.AirdropsDB.editAmounts(amount: amount, amountReferral: referral, ofAirdrop: airdrop!)
                ui_nameLabel.text = "\(airdrop!.name) [\(airdrop!.totalAmount) \(airdrop!.symbol!)]"
                wasEdited = true
            }
            closeEditForm()
        } else {
            // Ouvrir le form
            userIsEditing = true
            ui_editButton.setTitle("Enregistrer", for: .normal)
            cs_formHeight.isActive = false
            cs_editHeaderHeight.isActive = false
            UIView.animate(withDuration: 0.15) {
                self.ui_receivedState.isHidden = false
                self.view.layoutIfNeeded()
            }
        }
    }
    
//    Modifier l'état du airdrop
    
    // Passer de "En attente" à "Reçu" manuellement
    @IBAction func setToReceived(_ sender: Any) {
        if userIsEditing {
            // Création de l'alert sheet
            let sheet = UIAlertController(title: "Changement manuel", message: "Si vous changez manuellement l'état de cet airdrop, vous ne pourrez pas être informé de la valeur de celui-ci.", preferredStyle: .actionSheet)
            // Emmener l'utilisateur vers Wallets_VC
            sheet.addAction(UIAlertAction(title: "Lier à un token de votre wallet", style: .default, handler: { (_) in
                self.performSegue(withIdentifier: "finallyGoToWallets", sender: nil)
            }))
            // Faire le changement manuel
            sheet.addAction(UIAlertAction(title: "Continuer manuellement", style: .destructive, handler: { (_) in
                if self.userIsEditing {
                    self.editState(toNewState: .received, newUIState: self.ui_receivedState)
                    self.ui_waitingState.isHidden = true
                    self.setState()
                    self.closeEditForm()
                }
            }))
            // Annuler la procédure
            sheet.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: nil))
            // Présenter l'alerte
            present(sheet, animated: true, completion: nil)
        }
    }
    func editState(toNewState state:states, newUIState:GreyView){
        Singletons.AirdropsDB.editState(toState: state, ofAirdrop: airdrop!)
        wasEdited = true
    }
    
//    Passer de "Reçu" à "En attente"
    @IBAction func IHaveNotReceiveThisAirdrop(_ sender: MiTokens_button) {
        // Création de l'alert sheet
        let sheet = UIAlertController(title: "Je n'ai pas reçu ce airdrop", message: "Souhaitez vous vraiment repasser ce airdrop dans l'état \"En attente\" ?", preferredStyle: .actionSheet)
        
        // Action : passer de "Reçu" à "En attente"
        sheet.addAction(UIAlertAction(title: "Repasser ce airdrop en état \"En attente\"", style: .default, handler: { (_) in
            self.editState(toNewState: .waiting, newUIState: self.ui_waitingState)
            // Supprimer le lien
            Singletons.LinksDB.deleteLink(forAirdrop: self.airdrop!)
            // Gestion de l'affichage
            self.ui_receivedState.isHidden = true
            self.ui_soldSomeTokensButton.isHidden = true
            self.cs_notReceivedButtonHeight = NSLayoutConstraint(item: self.ui_notReceivedButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
            self.cs_editButtonHeight?.isActive = false
            self.cs_notReceivedButtonHeight.isActive = true
            self.setState()
        }))
        
        // Annuler la procédure
        sheet.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: nil))
        
        // Présenter l'alerte
        present(sheet, animated: true, completion: nil)
    }
    @IBAction func deleteThisAirdrop(_ sender: Any) {
        // Action bouton "Supprimer cet airdrop"
        let sheet = UIAlertController(title: "Supprimer cet airdrop", message: "Voulez-vous vraiment supprimer cet airdrop de MiTokens ?", preferredStyle: .actionSheet)
        
        // Supprimer le airdrop
        sheet.addAction(UIAlertAction(title: "Supprimer", style: .destructive, handler: { (_) in
            Singletons.AirdropsDB.deleteAirdrop(forAirdrop: self.airdrop!, handler: {
                self.wasEdited = true
                self.performSegue(withIdentifier: "goBackHome", sender: nil)
            })
        }))
        
        // Annuler la procédure
        sheet.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: nil))
        
        // Présenter l'alerte
        present(sheet, animated: true, completion: nil)
    }
    
//    Quitter l'écran d'airdrop focus
    @IBAction func leaveAirdropFocused(_ sender: Any) {
        if comeFromWallets {
            performSegue(withIdentifier: "goBackToWallets", sender: nil)
        } else {
            performSegue(withIdentifier: "goBackHome", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if wasEdited,
            let nextVC = segue.destination as? HomeViewController {
            nextVC._needReload = true
            nextVC.ui_collectionView.reloadData()
        } else if segue.identifier == "goToNewSale",
            let nextVC = segue.destination as? NewSale_ViewController {
            nextVC.airdrop = airdrop
        }
    }
    
}
