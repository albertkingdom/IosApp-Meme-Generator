//
//  SentMemeViewController.swift
//  ExperimentApp
//
//  Created by Albert Lin on 2021/9/21.
//

import UIKit
import CoreData

class SentMemeCollectionViewController: UICollectionViewController{

    var memeImage = [Image]()
    var dataController: DataController! = (UIApplication.shared.delegate as! AppDelegate).dataController
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(navigateToMemeEditor))
        navigationItem.leftBarButtonItem = editButtonItem

        
        
        
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
        
        createMemeController.dataController = dataController
       
        navigationController?.pushViewController(createMemeController, animated: true)
    }
    
    @objc func deleteItem() {
        let selectItems = collectionView.indexPathsForSelectedItems!
        print("s")
        for item in selectItems {

            dataController.viewContext.delete(image(for: item))
            
        }
        do {
            try dataController.viewContext.save()

            let indexToDelete = selectItems.map {
               $0.row
            }
            
            memeImage = memeImage.enumerated().filter{ !indexToDelete.contains($0.offset) }.map{$0.element}
            collectionView.deleteItems(at: selectItems)
            
            self.setEditing(false, animated: true)
            
        } catch {
            print("\(error.localizedDescription)")
        }

    }
    override func viewWillAppear(_ animated: Bool) {

        loadImage()
        collectionView.reloadData()
       
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memeImage.count
    }
    
    // to create a collection veiw cell with identifier=xxx
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionViewCell", for: indexPath) as! MemeCollectionViewCell

        cell.memeImageView.image = UIImage(data: image(for: indexPath).editedImg!)
        
        return cell
    }
    
    // select one view cell and navigate to detail view controller
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "DetailView") as! DetailViewController
        
        //detailController.memes = self.memeImage[indexPath.row]
        if !isEditing {
            detailController.dataController = dataController
            detailController.memeImage = image(for: indexPath)
            navigationController?.pushViewController(detailController, animated: true)
        }
        
    }
    

    
    func loadImage(){
        let fetchRequest: NSFetchRequest<Image> = Image.fetchRequest()
        
        do{
            memeImage = try dataController.viewContext.fetch(fetchRequest)
        }catch {
            print("Error while fetching the image")
        }
    }
}

extension SentMemeCollectionViewController {
    func image(for indexPath: IndexPath) -> Image {
        return memeImage[indexPath.row]
    }
}
