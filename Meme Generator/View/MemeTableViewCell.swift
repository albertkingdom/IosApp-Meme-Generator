//
//  MemeTableViewCell.swift
//  Meme Generator
//
//  Created by 林煜凱 on 10/28/21.
//

import UIKit

class MemeTableViewCell: UITableViewCell {

    @IBOutlet weak var imageThumbnail: UIImageView!
    @IBOutlet weak var creationDateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setup(with meme: Image){
        imageThumbnail.image = UIImage(data: meme.editedImg!)
        creationDateLabel.text = formatDate(date: meme.createDate ?? Date())
    }
    func formatDate(date: Date) -> String {
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd"
        return formater.string(from: date)
        
    }
}
