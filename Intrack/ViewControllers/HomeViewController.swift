//
//  HomeViewController.swift
//  Intrack
//
//  Created by Victor Martin Fuentes on 20/7/23.
//

import UIKit

class HomeViewController: UIViewController {
    
    //ELEMENTOS DE LA VISTA
    //@IBOutlet weak var imageHome: UIImageView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableQuest: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!

    //VARIABLES AUXILIARES
    var serverQuests: [QuestForm] = [] //volcar aqui los formularios
    var selectedIndexPath: IndexPath?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.navigationItem.title = "Principal"
        
        
        //scrollView.refreshControl = refresh
        //scrollView.refreshControl?.isHidden = false
        
        
        tableQuest.layer.cornerRadius = 10
        tableQuest.register(QuestCustomCell.nib(), forCellReuseIdentifier: QuestCustomCell.identifier)
        
        tableQuest.refreshControl = refresh
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.navigationItem.title = "Principal"
                
        tableQuest.refreshControl?.beginRefreshing()
        //scrollToPosition(CGFloat(-200))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        handleRefresh(refresh)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
                
        self.tableQuest.refreshControl?.endRefreshing()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        print("desaparecio")
        
        selectedIndexPath = nil
            tableQuest.reloadData()
    }
    
    

    
    
    // FUNCIONES AUXILIARES
    
    func scrollToPosition(_ position: CGFloat) {
        let desiredContentOffset = CGPoint(x: 0, y: position)
        // Realiza la animación de scroll
        scrollView.setContentOffset(desiredContentOffset, animated: true)
    }
    
    var refresh: UIRefreshControl{
        let ref = UIRefreshControl()
        ref.addTarget(self, action: #selector(handleRefresh(_:)), for: .allEvents)
        
        return ref
    }
    
    
    @objc func handleRefresh(_ control: UIRefreshControl){
        
        emptyView.isHidden = true
        serverQuests.removeAll()
        tableQuest.reloadData()
        print("REFRESH")
        getQuests()
        //control.endRefreshing()
    }
    
    
    func getQuests() {
                
        WebRequest.getQuests { quests in
            
            self.serverQuests = quests
            self.tableQuest.reloadData()
            self.tableQuest.refreshControl?.endRefreshing()
            
            self.emptyView.isHidden = !self.serverQuests.isEmpty
            
        } error: { errorMessage in
            self.tableQuest.refreshControl?.endRefreshing()
            self.emptyView.isHidden = false
            print("Error ", errorMessage)
        }
        

    }
        
}


// EXTENSIONES

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverQuests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let customCell = tableView.dequeueReusableCell(withIdentifier: QuestCustomCell.identifier, for: indexPath) as? QuestCustomCell
        else {
            print("unable to create cell")
            return UITableViewCell()
        }
                
        customCell.selectionStyle = .none
        
        customCell.questLabel.text = serverQuests[indexPath.row].title
        customCell.btIcon.isHidden = !(serverQuests[indexPath.row].need_device == 1)
        
        if selectedIndexPath == indexPath {
                customCell.viewShape.backgroundColor = UIColor(named: "QuestColorSetB")
            } else {
                customCell.viewShape.backgroundColor = UIColor(named: "QuestColorSet")
            }
        
        return customCell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //enviar el cuestionario correspondiente a la celda a la siguiente vista
        
        //tableView.deselectRow(at: indexPath, animated: true)
        
        selectedIndexPath = indexPath
            tableView.reloadData()
        
                        
        let vc = storyboard?.instantiateViewController(withIdentifier: "DescriptionQuestView") as! DescriptionQuestViewController
        
        vc.currentFormQuest = serverQuests[indexPath.row]
        
        navigationController?.pushViewController(vc, animated: true)
                
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    
}


