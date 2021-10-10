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
    var context: NSManagedObjectContext!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        } else {
            // Fallback on earlier versions
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(navigateToMemeEditor))
        navigationItem.leftBarButtonItem = editButtonItem

        
        
        
    }
    // compositional layout
    @available(iOS 13.0, *)
    private func generateLayout() -> UICollectionViewLayout {
        //let spacing: CGFloat = 20
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        //item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: spacing, bottom: 0, trailing: spacing)
        return UICollectionViewCompositionalLayout(section: section)
        
    }
    

  
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        
        if #available(iOS 14.0, *) {
            collectionView.allowsMultipleSelectionDuringEditing = true
        } else {
            // Fallback on earlier versions
            collectionView.allowsMultipleSelection = true
        }
        collectionView.indexPathsForVisibleItems.forEach { index in
            guard let cell = collectionView.cellForItem(at: index) as? MemeCollectionViewCell else { return }
            
            cell.isEditing = editing
            
        }
        
        
        navigationItem.rightBarButtonItem = editing ? UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteMultipleItem)) : UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(navigateToMemeEditor))
    }
    
    @objc func navigateToMemeEditor() {
        
        let createMemeController = self.storyboard!.instantiateViewController(withIdentifier: "CreateMemeController") as! EditorViewController
        
        createMemeController.context = context
        navigationController?.pushViewController(createMemeController, animated: true)
    }
    
    @objc func deleteMultipleItem() {
        let selectItems = collectionView.indexPathsForSelectedItems!
       
        for item in selectItems {
            context.delete(image(for: item))
            
        }
        do {
            try context.save()
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
            detailController.context = context
            detailController.memeImage = image(for: indexPath)
            navigationController?.pushViewController(detailController, animated: true)
        }
        
    }
    
    // long press image to show menus, available >= ios 13
    @available(iOS 13, *)
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil,
               previewProvider: nil) { (elements) -> UIMenu? in
                let delete = UIAction(title: "Delete") { (action) in
                    self.deleteSingleMeme(at: indexPath)
                }

                return UIMenu(title: "", image: nil, identifier: nil,
                   options: [], children: [delete])
            }

        return config
       
    }
    
    func loadImage(){
        let fetchRequest: NSFetchRequest<Image> = Image.fetchRequest()
        
        do{
            memeImage = try context.fetch(fetchRequest)
        }catch {
            print("Error while fetching the image")
        }
    }
}

extension SentMemeCollectionViewController {
    func image(for indexPath: IndexPath) -> Image {
        return memeImage[indexPath.row]
    }
    func deleteSingleMeme(at indexPath: IndexPath){
        
        context.delete(image(for: indexPath))
        memeImage.remove(at: indexPath.row)
        do {
            try context.save()
        } catch {
            print("\(error.localizedDescription)")
        }
        collectionView.deleteItems(at: [indexPath])
    }
}
