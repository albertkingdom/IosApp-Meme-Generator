//
//  VillainCollectionViewCell.swift
//  ExperimentApp
//
//  Created by Albert Lin on 2021/9/21.
//

import UIKit

class MemeCollectionViewCell: UICollectionViewCell {
    
    var isEditing: Bool = false {
        didSet {
            if isEditing && isSelected {
                checkIcon.isHidden = false
            } else {
                checkIcon.isHidden = true
                isSelected = false
            }
        }
    }
   
//    @IBOutlet weak var memeTopText: UILabel!
//    @IBOutlet weak var memeBottomText: UILabel!
    @IBOutlet weak var memeImageView: UIImageView!
   
    @IBOutlet weak var checkIcon: UIImageView!
    
    override var isSelected: Bool {
        
        didSet {
            if isEditing && isSelected {
                checkIcon.isHidden = false
            } else {
                checkIcon.isHidden = true
            }
        }
    }
}
