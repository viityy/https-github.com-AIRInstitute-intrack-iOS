//
//  DeviceBTViewController.swift
//  Intrack
//
//  Created by Victor Martin Fuentes on 31/8/23.
//

import UIKit
import CoreBluetooth

class DeviceBTViewController: UIViewController, UIScrollViewDelegate {
    
    
    //ELEMENTOS DE LA VISTA
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollToRefresh: UIScrollView!
    @IBOutlet weak var btImage: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var btView: UIView!
    @IBOutlet weak var devicesTable: UITableView!
    
    
    //VARIABLES AUXILIARES
    var connectedFlag: Bool = false
    var connectingFlag: Bool = false
    var disConnectingFlag: Bool = false
    var serialBT: BluetoothSerial!
    var peripherals: [CBPeripheral] = []
    var selectedPeripheral: CBPeripheral?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Bluetooth"
        
        self.view.backgroundColor = .systemGray5
        
        btView.layer.cornerRadius = 10
        
        devicesTable.layer.cornerRadius = 10
        devicesTable.register(DevCustomCellTableViewCell.nib(), forCellReuseIdentifier: DevCustomCellTableViewCell.identifier)
        
        //delegates
        devicesTable.delegate = self
        devicesTable.dataSource = self
        
        scrollToRefresh.delegate = self
        scrollToRefresh.refreshControl = refresh
        
        
        // Inicializa el objeto BluetoothSerial
        serialBT = BluetoothSerial(delegate: self)
        serialBT.delegate = self
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        serialBT.delegate = self
        serialDidChangeState()
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            serialBT.disconnect()
        }
    }
    
    
    
    
    
    // FUNCIONES DE ELEMENTOS DE LA VISTA
    
    @IBAction func nextButton(_ sender: Any) { //pasamos a escanear
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ViewControllerScan") as! ViewControllerScanBT
        vc.ScanSelectedPeripheral = selectedPeripheral
        vc.serialBT = self.serialBT // Pasa la instancia de serialBT a la vista 2
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    
    // FUNCIONES AUXILIARES
    
    func scrollToPosition(_ position: CGFloat) {
        let desiredContentOffset = CGPoint(x: 0, y: position)
        // Realiza la animación de scroll
        scrollToRefresh.setContentOffset(desiredContentOffset, animated: true)
    }
    
    
    func removeDuplicates(from array: inout [CBPeripheral]) {
        var uniqueElements = Set<CBPeripheral>()
        var newArray = [CBPeripheral]()
        
        for element in array {
            if !uniqueElements.contains(element) {
                uniqueElements.insert(element)
                newArray.append(element)
            }
        }
        
        array = newArray
    }
    
    
    @objc func connectTimeOut() {
        
        if let _ = serialBT.connectedPeripheral { // al conectarse
            print("bt conectado")
            devicesTable.allowsSelection = true
            connectedFlag = true
            connectingFlag = false // una vez conectado, desactivamos la flag de conectandose
            devicesTable.reloadData()
            return
        }
        
        if let _ = selectedPeripheral { // al desconectarse
            print("bt libre")
            devicesTable.allowsSelection = true
            nextButton.isEnabled = false
            connectedFlag = false
            disConnectingFlag = false // una vez desconectado, desactivamos la flag de desconectandose
            devicesTable.reloadData()
            serialBT.disconnect()
            selectedPeripheral = nil
        }
        
    }
    
    @objc func handleRefresh(_ control: UIRefreshControl) {
        
        print("REFRESH")
        
        devicesTable.isHidden = true
        
        nextButton.isEnabled = false
        
        heightConstraint.constant = 55.0
        
        peripherals = []
        
        //devicesTable.reloadData()
        
        serialBT.startScan()
        
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(scanTimeOut), userInfo: nil, repeats: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { //escaneo de cinco segundos
            
            if self.devicesTable.numberOfRows(inSection: 0) > 0 {
                self.devicesTable.isHidden = false
            }
            
            if(self.peripherals.count > 10){ //si se detectan más de 10 perifericos
                self.heightConstraint.constant = 550.0
                self.devicesTable.isScrollEnabled = true
            } else {
                self.heightConstraint.constant = 55.0 * CGFloat(self.peripherals.count)
                self.devicesTable.isScrollEnabled = false
            }
            
            self.devicesTable.isHidden = false
            
        }
    }
    
    
    
    var refresh: UIRefreshControl{
        let ref = UIRefreshControl()
        ref.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        return ref
    }
    
    
    // 5 segundos de escaneo y deja de escanear
    @objc func scanTimeOut() {
        serialBT.stopScan()
        devicesTable.reloadData()
        
        if scrollToRefresh.refreshControl?.isRefreshing == true {
            scrollToRefresh.refreshControl?.endRefreshing()
        }
    }
    
}


// EXTENSIONES

extension DeviceBTViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        removeDuplicates(from: &peripherals) //borra los duplicados
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print(connectingFlag)
        print(disConnectingFlag)
        
        
        guard let customCell = tableView.dequeueReusableCell(withIdentifier: DevCustomCellTableViewCell.identifier, for: indexPath) as? DevCustomCellTableViewCell
        else {
            print("unable to create cell")
            return UITableViewCell()
        }
        
        customCell.deviceLabel.text = "Intrack"
        
        
        if ( self.serialBT.connectedPeripheral != nil ) {
            // El dispositivo ESTÁ conectado
            
            print("la celda: \(indexPath.row)")
            print("esta desconectandose \(!customCell.activityIndicator.isHidden)")
            
            
            if peripherals[indexPath.row] == selectedPeripheral {
                // (cuando recargas o cuando desconectas y conectas el bluetooth)
                //si el dispositivo de la celda coinice con el dispositivo seleccionado anteriormente
                print("1")
                customCell.connectedLabel.text = connectedFlag ? "Conectado" : "Desconectado"
            } else {
                print("2")
                customCell.connectedLabel.text = "Desconectado"
            }
            
            
            
        } else { // El dispositivo NO ESTÁ conectado.
            
            print("la celda: \(indexPath.row)")
            print("esta conectandose \(!customCell.activityIndicator.isHidden)")
            connectedFlag = false
            
            
            print("3")
            customCell.connectedLabel.text = "Desconectado"
            
            
            if(connectingFlag && (selectedPeripheral == peripherals[indexPath.row]) ) { //conectandose
                
                customCell.activityIndicator.isHidden = customCell.connectedLabel.text != "Desconectado"
                customCell.connectedLabel.isHidden = !customCell.activityIndicator.isHidden
                
            }
            
        }
        
        
        nextButton.isEnabled = customCell.connectedLabel.text == "Conectado"
        
        if(nextButton.isEnabled){
            customCell.activityIndicator.isHidden = true
            customCell.connectedLabel.isHidden = false
            
        }
        
        
        return customCell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if( connectedFlag && (selectedPeripheral != peripherals[indexPath.row] )){
            
            //si hay un dispositivo conectado, bloquear el pulsar en el resto de dispostivos hasta que no se desconecte el dispositivo conectado
            tableView.deselectRow(at: indexPath, animated: true)
            //mostrar aviso
            
            // Crea la alerta
            let alertController = UIAlertController(title: "Ya hay un dispositivo conectado", message: "Desconecte el dispositivo emparejado para establecer otra conexión.", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { action in
                //acción
            }))
            
            // Muestra la alerta
            present(alertController, animated: true, completion: nil)
            
            return
            
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        devicesTable.allowsSelection = false
        
        serialBT.stopScan()
        
        selectedPeripheral = peripherals[indexPath.row] //guardar el dispositivo seleccionado
        
        if(!connectedFlag){ // si no está conectado
            
            connectingFlag = true // poner la animacion de conexión
            devicesTable.reloadData() //recargar la tabla para que se vea la animación de conexión
            
            serialBT.connectToPeripheral(selectedPeripheral!) // conectarse a un dispositivo
            Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(connectTimeOut), userInfo: nil, repeats: false) // hacer un timeout
            
        } else { // si está conectado
            
            disConnectingFlag = true
            devicesTable.reloadData()
            
            
            if(selectedPeripheral?.name == "Intrac"){
                serialBT.disconnect()
                Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(connectTimeOut), userInfo: nil, repeats: false)
                
            }
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    
}




extension DeviceBTViewController: BluetoothSerialDelegate {
    
    
    // Implementación de los métodos del protocolo BluetoothSerialDelegate
    func serialDidChangeState() {
        if serialBT.centralManager.state != .poweredOn {
            print("bt apagado")
            btImage.image = UIImage(named: "bluetoothIconOff")
            nextButton.isEnabled = false
            scrollToRefresh.isScrollEnabled = false
            devicesTable.isScrollEnabled = false
            devicesTable.isHidden = true
            heightConstraint.constant = 55.0
            
            connectedFlag = false
            disConnectingFlag = false
            connectingFlag = false
            devicesTable.reloadData()
            return
            
            
        } else {
            print("Escaneando...")
            scrollToRefresh.isScrollEnabled = true
            devicesTable.isScrollEnabled = false
            //devicesTable.isHidden = false
            btImage.image = UIImage(named: "bluetoothIconOn")
            
            
            scrollToRefresh.refreshControl?.beginRefreshing()
            self.scrollToPosition(CGFloat(-200))
            handleRefresh(refresh)
            
        }
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        
        peripherals = []
        connectedFlag = false
        disConnectingFlag = false
        connectingFlag = false
        
        nextButton.isEnabled = false
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(connectTimeOut), userInfo: nil, repeats: false)
        
        handleRefresh(refresh)
        
        print("Disconnected.")
    }
    
    func serialDidFailToConnect(_ peripheral: CBPeripheral, error: NSError?) {
        
        print("Error al conectar")
        
    }
    
    func serialDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?) {
        // Imprime el nombre del dispositivo encontrado
        let peripheralName = peripheral.name
        let peripheralID = peripheral.identifier
        
        if (peripheralName != nil && peripheralName == "Intrac")  {
            peripherals.append(peripheral)
            print("Discovered Device: \(peripheralName!), Discovered Device: \(peripheralID), ")
            devicesTable.reloadData()
            devicesTable.isHidden = false
        }
    }
    
    func serialDidConnect(_ peripheral: CBPeripheral) {
        print("Conexión exitosa a:: \(peripheral.name ?? "Dispositivo sin nombre")")
    }
    
    
}

