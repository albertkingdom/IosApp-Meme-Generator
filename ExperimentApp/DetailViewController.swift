//
//  DetailViewController.swift
//  ExperimentApp
//
//  Created by Albert Lin on 2021/9/21.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var memeTopText: UILabel!
    @IBOutlet weak var memeBottomText: UILabel!
    
    var memes:Meme!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("detail view \(memes)")
        // Do any additional setup after loading the view.
        navigationItem.title = "Detail View"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(navigateToMemeEditor))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.memeImageView.image = memes.memedImage
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    @objc func navigateToMemeEditor() {
        
    }

}
