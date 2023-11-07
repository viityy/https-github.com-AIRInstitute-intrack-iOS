//
//  AnswerCustomCell.swift
//  Intrack
//
//  Created by Victor Martin Fuentes on 20/7/23.
//

import UIKit

class AnswerCustomCell: UITableViewCell {

            
    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!
    
    static let identifier = "AnswerCustomCell"

    static func nib()-> UINib {
        return UINib(nibName: "AnswerCustomCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
