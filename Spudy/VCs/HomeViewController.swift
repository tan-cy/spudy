//
//  HomeViewController.swift
//  Spudy
//
//  Created by Cindy Tan on 10/12/21.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var PopularSpotsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PopularSpotsCollectionView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: "MyCollectionViewCell")
        
        PopularSpotsCollectionView.delegate = self
        PopularSpotsCollectionView.dataSource = self
    }

}

// helps pick up interactions with the cell
extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        print("You tapped me!")
        
    }
    
}

// helps with displaying info
extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionViewCell", for: indexPath) as! MyCollectionViewCell
        
        cell.configure(with: UIImage(named: "SAC")!)
        
        return cell
    }
    
}

// lets us specify what is the margin and pattern between each cell
//extension HomeViewController: UICollectionViewDelegateFlowLayout {
//
//}
