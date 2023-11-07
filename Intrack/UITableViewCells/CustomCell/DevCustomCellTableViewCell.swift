//
//  DevCustomCellTableViewCell.swift
//  Intrack
//
//  Created by Victor Martin Fuentes on 3/8/23.
//

import UIKit

class DevCustomCellTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var deviceLabel: UILabel!
    @IBOutlet weak var connectedLabel: UILabel!
    
    static let identifier = "DevCustomCellTableViewCell"
    
    static func nib()-> UINib {
        return UINib(nibName: "DevCustomCellTableViewCell", bundle: nil)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.connectedLabel.text = "Conectado"
        self.activityIndicator.isHidden = true
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        self.activityIndicator.startAnimating()
        
        // Configure the view for the selected state
    }
    
}
