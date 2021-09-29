//
//  SentMemeViewController.swift
//  ExperimentApp
//
//  Created by Albert Lin on 2021/9/21.
//

import UIKit
import CoreData

class SentMemeCollectionViewController: UICollectionViewController{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    //var memes: [Meme]!
    var memeImage = [Image]()
    var dataController: DataController! = (UIApplication.shared.delegate as! AppDelegate).dataController
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add right button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(navigateToMemeEditor))
        navigationItem.leftBarButtonItem = editButtonItem
        // setting flow layout
        //let space:CGFloat = 0.5
        //let dimension = (view.frame.size.width - (2 * space)) / 3.0

//        flowLayout.minimumInteritemSpacing = space
//        flowLayout.minimumLineSpacing = space
//        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        
        
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        print("setEditing: \(editing)")
        collectionView.allowsMultipleSelection = true
        collectionView.indexPathsForVisibleItems.forEach { index in
            guard let cell = collectionView.cellForItem(at: index) as? MemeCollectionViewCell else { return }
            
            cell.isEditing = editing
            
        }
        
        
        navigationItem.rightBarButtonItem = editing ? UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteItem)) : UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(navigateToMemeEditor))
    }
    
    @objc func navigateToMemeEditor() {
        
            let createMemeController = self.storyboard!.instantiateViewController(withIdentifier: "CreateMemeController") as! ViewController
            //navigationController.pushViewController(createMemeController, animated: true)
        
            createMemeController.dataController = dataController
       
            //present(createMemeController, animated: true, completion: nil)
        navigationController?.pushViewController(createMemeController, animated: true)
    }
    
    @objc func deleteItem() {
        let selectItems = collectionView.indexPathsForSelectedItems!
        print("selectItem \(selectItems)")
        
   
        
        for item in selectItems {
            
            dataController.viewContext.delete(memeImage[item[1]])
            memeImage.remove(at: item[1])
        }
        do {
            try dataController.viewContext.save()
            
            collectionView.deleteItems(at: selectItems)
            
            self.setEditing(false, animated: true)
            
        } catch {
            print("\(error.localizedDescription)")
        }
       
        //dataController.viewContext.deletedObjects
    }
    override func viewWillAppear(_ animated: Bool) {
        //memes = appDelegate.memes
        loadImage()
        collectionView.reloadData()
       
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memeImage.count
    }
    
    // to create a collection veiw cell with identifier=xxx
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
       // let meme = memeImage[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionViewCell", for: indexPath) as! MemeCollectionViewCell
        
//        cell.memeTopText.text = meme.topText
//        cell.memeBottomText.text = meme.bottomText
        cell.memeImageView.image = UIImage(data: memeImage[indexPath.row].editedImg!)
        
        return cell
    }
    
    // select one view cell and navigate to detail view controller
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "DetailView") as! DetailViewController
        
        //detailController.memes = self.memeImage[indexPath.row]
        if !isEditing {
            detailController.dataController = dataController
            //detailController.memeImage = UIImage(data: memeImage[indexPath.row].editedImg!)
            detailController.memeImage = memeImage[indexPath.row]
            navigationController?.pushViewController(detailController, animated: true)
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as? MemeCollectionViewCell
        
        //cell?.isEditing = isEditing
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath)
//        print(indexPath)
    }

    
    func loadImage(){
        let fetchRequest: NSFetchRequest<Image> = Image.fetchRequest()
        
        //let fetchTextRequest: NSFetchRequest<Text> = Text.fetchRequest()
        //let predicate: NSPredicate = NSPredicate(format: "image == %@", image)
        //fetchTextRequest.predicate = predicate
        
        do{
            memeImage = try dataController.viewContext.fetch(fetchRequest)
            //let fetchedText = try dataController.viewContext.fetch(fetchTextRequest)
            
            //imageView.image = UIImage(data: fetchedImage[fetchedImage.endIndex - 1].img!)
            
            
           
        }catch {
            print("Error while fetching the image")
        }
    }
}
