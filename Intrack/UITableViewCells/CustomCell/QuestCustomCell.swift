//
//  QuestCustomCell.swift
//  Intrack
//
//  Created by Victor Martin Fuentes on 19/10/23.
//

import UIKit

class QuestCustomCell: UITableViewCell {
    
    
    @IBOutlet weak var viewShape: UIView!
    @IBOutlet weak var btIcon: UIImageView!
    @IBOutlet weak var questLabel: UILabel!
    
    static let identifier = "QuestCustomCell"

    static func nib()-> UINib {
        return UINib(nibName: "QuestCustomCell", bundle: nil)
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        questLabel.textColor = .white
        viewShape.layer.cornerRadius = 20.0	
        viewShape.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
