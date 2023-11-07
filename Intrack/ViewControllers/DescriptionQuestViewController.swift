//
//  DescriptionQuestViewController.swift
//  Intrack
//
//  Created by Victor Martin Fuentes on 20/9/23.
//

import UIKit

class DescriptionQuestViewController: UIViewController {

    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    var currentFormQuest: QuestForm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = currentFormQuest?.title

        descriptionLabel.text = currentFormQuest?.description
        
    }
    
    @IBAction func startButton(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ViewControllerQ") as! QuestViewController
        
        vc.currentFormQuest = currentFormQuest
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
    

}
