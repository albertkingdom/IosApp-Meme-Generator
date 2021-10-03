//
//  DetailViewController.swift
//  ExperimentApp
//
//  Created by Albert Lin on 2021/9/21.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {

    var memeImage: Image!
    var dataController: DataController!
    
    @IBOutlet weak var memeImageView: UIImageView!
   
    @IBAction func shareImage(_ sender: Any) {
        guard let imageToShare = UIImage(data: memeImage.editedImg!) else { return }
        
        let activity = UIActivityViewController(activityItems: [imageToShare], applicationActivities: nil)
        
        present(activity, animated: true, completion: nil)
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Detail View"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(navigateToMemeEditor))
    }
    
    override func viewWillAppear(_ animated: Bool) {
     
        self.memeImageView.image = UIImage(data: memeImage.editedImg!)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    @objc func navigateToMemeEditor() {
        let controller = storyboard?.instantiateViewController(identifier: "CreateMemeController") as! ViewController
        controller.dataController = dataController
        controller.imageToBeEdit = memeImage
        
        navigationController?.pushViewController(controller, animated: true)

    }

}
