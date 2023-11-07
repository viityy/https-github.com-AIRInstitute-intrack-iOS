//
//  CustomCellBT.swift
//  Intrack
//
//  Created by Victor Martin Fuentes on 6/9/23.
//

import UIKit

class CustomCellBT: UITableViewCell {
    
    
    @IBOutlet weak var deviceLabel: UILabel!
    
    @IBOutlet weak var conectedLabel: UILabel!
    

    static let identifier = "CustomCellBT"

    static func nib()-> UINib {
        return UINib(nibName: "CustomCellBT", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
