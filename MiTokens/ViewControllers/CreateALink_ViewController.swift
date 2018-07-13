//
//  CreateALink_ViewController.swift
//  MiTokens
//
//  Created by Romain Penchenat on 29/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit

class CreateALink_ViewController: TopBarAd_ViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var nextVCNeedReload:Bool = false
    var token:token?
    var currentWalletAddress:String?
    var airdropsList:[Airdrop] {
        return Singletons.AirdropsDB.getCreateALinkList(forToken: token!)
    }
    
    lazy var cellSize:CGSize = CGSize(width: (UIScreen.main.bounds.width/2) - 18, height: 100)
    
    @IBOutlet weak var ui_youHaveLabel: Subtitle_label!
    @IBOutlet weak var ui_searchBar: MiTokens_searchBar!
    @IBOutlet weak var ui_airdropsCollectionView: UICollectionView!
    @IBOutlet weak var ui_collectionViewFlow: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ui_youHaveLabel.text = """
        Vous avez \(token!.realBalance) \(token!.symbol) (\(token!.name))
        """
        
        ui_airdropsCollectionView.dataSource = self
        ui_collectionViewFlow.itemSize = cellSize
        ui_airdropsCollectionView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    Collection View Data source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return airdropsList.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = ui_airdropsCollectionView.dequeueReusableCell(withReuseIdentifier: "AirdropCell", for: indexPath) as! Airdrop_CollectionViewCell
        cell.bounds.size = cellSize
        if indexPath.row == 0 {
            cell.ui_nameLabel.text = "Nouveau"
            cell.ui_tokensLabel.text = "Choisissez cette option si l'airdrop n'est pas enregistré sur MiTokens"
            cell.tag = 0
        } else {
            let airdrop = airdropsList[indexPath.row - 1]
            cell.ui_nameLabel.text = airdrop.name
            cell.ui_tokensLabel.text = "\(airdrop.totalAmount) \(airdrop.symbol!)"
            cell.tag = airdrop.airdropID
        }
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(cellTaped(_:)))
        cell.addGestureRecognizer(recognizer)
        return cell
    }
    
    @IBAction func cellTaped(_ sender: UITapGestureRecognizer) {
        guard let cellId = sender.view?.tag,
            let index = ui_airdropsCollectionView.indexPathForItem(at: sender.location(in: ui_airdropsCollectionView)) else {
            return
        }
        let airdrop = cellId != 0 ? airdropsList[index.row - 1] : Airdrop(name: token!.name, symbol: token!.symbol, amount: token!.realBalance, referral: "0")
        if cellId != 0 {
            // Changer le symbol du airdrop
            Singletons.AirdropsDB.editSymbol(symbol: token!.symbol, ofAirdrop: airdrop)
            // Changer la quantité du airdrop
            Singletons.AirdropsDB.editAmounts(amount: token!.realBalance, amountReferral: "0", ofAirdrop: airdrop)
        } else {
            Singletons.AirdropsDB.addAirdrop(airdrop: airdrop)
        }
        let id = cellId != 0 ? cellId : airdrop.airdropID
        // Créer le lien
        Singletons.LinksDB.addALink(link: Link(betweenSmartContract: token!.smartContract, withName: token!.name, andSymbol: token!.symbol, andAirdropId: id, forWalletAddress: currentWalletAddress!))
        // Changer l'état du airdrop
        Singletons.AirdropsDB.editState(toState: .received, ofAirdrop: airdrop)
        // Fermer la page, ouvrir la page airdrop
        performSegue(withIdentifier: "unwindToWalletAndReload", sender: nil)
    }
    
//    Collection view delegate
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? Airdrop_CollectionViewCell {
//            print(cell.tag)
            if cell.tag == 0 {
//                print("green")
                cell.ui_colorIndicator.backgroundColor = UIColor(named: "Green")
            } else {
//                print("orange")
                cell.ui_colorIndicator.backgroundColor = UIColor(named: "Orange")
            }
//            print("")
        }
    }
    
// MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToWalletAndReload",
            let nextVC = segue.destination as? Wallets_ViewController {
            nextVC.homeWillNeedReload = true
        }
    }

}
