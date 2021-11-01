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
    var context: NSManagedObjectContext!
    @IBOutlet weak var memeImageView: UIImageView!
   
    @IBAction func shareImage(_ sender: Any) {
        guard let imageToShare = UIImage(data: memeImage.editedImg!) else { return }
        
        let activity = UIActivityViewController(activityItems: [imageToShare], applicationActivities: nil)
        let alertController = UIAlertController(title: "Share", message: "", preferredStyle: .actionSheet)
        let uploadAction = UIAlertAction(title: "透過imgur分享", style: .default) { _ in
           
            uploadImage(data: self.memeImage.editedImg!){ [weak self] (link:String?, error:Error?) in
                if let link = link {
                    let resultAlertController = UIAlertController(title: "Imgur分享結果", message: link, preferredStyle: .alert)
                    let copyAction = UIAlertAction(title: "複製連結", style: .default){ _ in
                        UIPasteboard.general.string = link
                    }
                    resultAlertController.addAction(copyAction)
                    self?.present(resultAlertController, animated: true, completion: nil)
                    
                } else {
                    let resultAlertController = UIAlertController(title: "Imgur分享結果", message: "無法成功上傳！", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    resultAlertController.addAction(okAction)
                    self?.present(resultAlertController, animated: true, completion: nil)
                }
                
            }
        }
        let shareWithOtherAppAction = UIAlertAction(title: "分享", style: .default) { _ in
            self.present(activity, animated: true, completion: nil)
        }
        alertController.addAction(uploadAction)
        alertController.addAction(shareWithOtherAppAction)
        //present(activity, animated: true, completion: nil)
        
        present(alertController, animated: true, completion: nil)
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
        let controller = storyboard?.instantiateViewController(identifier: "CreateMemeController") as! EditorViewController
        controller.context = context
        controller.imageToBeEdit = memeImage
        
        navigationController?.pushViewController(controller, animated: true)

    }

}
