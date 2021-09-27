//
//  SentMemeViewController.swift
//  ExperimentApp
//
//  Created by Albert Lin on 2021/9/21.
//

import UIKit

class SentMemeCollectionViewController: UICollectionViewController{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var memes: [Meme]!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add right button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(navigateToMemeEditor))
      
        // setting flow layout
        //let space:CGFloat = 0.5
        //let dimension = (view.frame.size.width - (2 * space)) / 3.0

//        flowLayout.minimumInteritemSpacing = space
//        flowLayout.minimumLineSpacing = space
//        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
    }
    
    @objc func navigateToMemeEditor() {
        
            let createMemeController = self.storyboard!.instantiateViewController(withIdentifier: "CreateMemeController") as! ViewController
            //navigationController.pushViewController(createMemeController, animated: true)
            present(createMemeController, animated: true, completion: nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        memes = appDelegate.memes
       
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    // to create a collection veiw cell with identifier=xxx
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let meme = memes[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionViewCell", for: indexPath) as! MemeCollectionViewCell
        
//        cell.memeTopText.text = meme.topText
//        cell.memeBottomText.text = meme.bottomText
        cell.memeImageView.image = meme.memedImage
        
        return cell
    }
    
    // select one view cell and navigate to detail view controller
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "DetailView") as! DetailViewController
        
        detailController.memes = self.memes[indexPath.row]
        
        navigationController?.pushViewController(detailController, animated: true)
    }

}
