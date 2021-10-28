//
//  SentMemeTableViewController.swift
//  Meme Generator
//
//  Created by 林煜凱 on 10/28/21.
//
import CoreData
import UIKit

class SentMemeTableViewController: UITableViewController {
    //var memeImage = [Image]()
    var context: NSManagedObjectContext!
   
    lazy var controller: NSFetchedResultsController<Image> = {
        let fetchRequest: NSFetchRequest<Image> = Image.fetchRequest()
        let sortDiscriptor = [NSSortDescriptor(key: "createDate", ascending: true)]
        fetchRequest.sortDescriptors = sortDiscriptor
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
      
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(navigateToMemeEditor))
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.dataSource = self
        tableView.delegate = self

    }
    override func viewWillAppear(_ animated: Bool) {
       
        self.loadImage()
        //tableView.reloadData()
    }
 
    func loadImage(){

        do{

           try controller.performFetch()
        }catch {
            print("Error while fetching the image")
        }
    }
    func deleteSingleMeme(at indexPath: IndexPath){
        let objToBeDelete = controller.object(at: indexPath)
        context.delete(objToBeDelete)
       
        do {
            try context.save()
        } catch {
            print("\(error.localizedDescription)")
        }
       
    }

    @objc func navigateToMemeEditor() {
        let createMemeController = self.storyboard!.instantiateViewController(withIdentifier: "CreateMemeController") as! EditorViewController
        
        createMemeController.context = context
        navigationController?.pushViewController(createMemeController, animated: true)
    }

}

extension SentMemeTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        guard let sections = self.controller.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        return sections[0].numberOfObjects
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! MemeTableViewCell
        let object = self.controller.object(at: indexPath)
        cell.setup(with: object)
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        deleteSingleMeme(at: indexPath)

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "DetailView") as! DetailViewController
        

        if !isEditing {
            detailController.context = context
            detailController.memeImage = self.controller.object(at: indexPath)
            navigationController?.pushViewController(detailController, animated: true)
        }
    }
    

  
    
    
}

extension SentMemeTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
