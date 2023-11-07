//
//  EvaViewController.swift
//  Intrack
//
//  Created by Victor Martin Fuentes on 21/9/23.
//

import UIKit

class EvaViewController: UIViewController {

    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var evaSlider: UISlider!
    @IBOutlet weak var questionLabel: UILabel!
    
    
    var question: QuestionForm? = nil
    var titleView: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = titleView
        questionLabel.text = question?.body
        
    }
    

    @IBAction func evaSlider(_ sender: Any) {
    }
    
    
    @IBAction func nextButton(_ sender: Any) {
    }
    
    
    @IBAction func backButton(_ sender: Any) {
    }
    
    
    
}
