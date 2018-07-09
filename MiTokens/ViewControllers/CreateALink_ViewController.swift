//
//  CreateALink_ViewController.swift
//  MiTokens
//
//  Created by Romain Penchenat on 29/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit

class CreateALink_ViewController: TopBarAd_ViewController, UICollectionViewDataSource {

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
        ui_youHaveLabel.text = "Vous avez \(token!.realBalance) \(token!.symbol)"
        
        ui_airdropsCollectionView.dataSource = self
        ui_collectionViewFlow.itemSize = cellSize
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    Collection View Data source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return airdropsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = ui_airdropsCollectionView.dequeueReusableCell(withReuseIdentifier: "AirdropCell", for: indexPath) as! Airdrop_CollectionViewCell
        cell.bounds.size = cellSize
        let airdrop = airdropsList[indexPath.row]
        cell.ui_nameLabel.text = airdrop.name
        cell.ui_tokensLabel.text = "\(airdrop.totalAmount) \(airdrop.symbol!)"
        cell.tag = airdrop.airdropID
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(cellTaped(_:)))
        cell.addGestureRecognizer(recognizer)
        return cell
    }
    
    @IBAction func cellTaped(_ sender: UITapGestureRecognizer) {
        guard let id = sender.view?.tag,
            let index = ui_airdropsCollectionView.indexPathForItem(at: sender.location(in: ui_airdropsCollectionView)) else {
            return
        }
        // Créer le lien
        Singletons.LinksDB.addALink(link: Link(betweenSmartContract: token!.smartContract, withName: token!.name, andSymbol: token!.symbol, andAirdropId: id, forWalletAddress: currentWalletAddress!))
        let airdrop = airdropsList[index.row]
        // Changer l'état du airdrop
        Singletons.AirdropsDB.editState(toState: .received, ofAirdrop: airdrop)
        // Changer le symbol du airdrop
        Singletons.AirdropsDB.editSymbol(symbol: token!.symbol, ofAirdrop: airdrop)
        // Changer la quantité du airdrop
        Singletons.AirdropsDB.editAmounts(amount: token!.realBalance, amountReferral: "0", ofAirdrop: airdrop)
        // Fermer la page, ouvrir la page airdrop
        performSegue(withIdentifier: "unwindToWalletAndReload", sender: nil)
    }
    
// MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToWalletAndReload",
            let nextVC = segue.destination as? Wallets_ViewController {
            nextVC.homeWillNeedReload = true
        }
    }

}
