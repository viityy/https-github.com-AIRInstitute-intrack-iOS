//
//  ViewControllerScanBT.swift
//  Intrack
//
//  Created by Victor Martin Fuentes on 7/9/23.
//

import UIKit
import CoreBluetooth

class ViewControllerScanBT: UIViewController {
    
    
    //ELEMENTOS DE LA VISTA
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var GifView: UIImageView!
    @IBOutlet weak var scanningLabel: UILabel!
    
    
    //VARIABLES AUXILIARES
    var serialBT: BluetoothSerial!
    let KNEE_MESSAGES_SERVICE_UUID : UUID = UUID(uuidString: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")!
    let KNEE_MESSAGES_CHARACTERISTIC_UUID : UUID = UUID(uuidString: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")!
    var ScanSelectedPeripheral: CBPeripheral?
    var fullScanFlag: Bool = false
    var okFlag = false
    var stopScan = false
    var arrayMax: [Double] = []
    var arrayMin: [Double] = []
    var alertController1 = UIAlertController(title: "Doble su rodilla", message: "Por favor, doble todo lo que pueda la rodilla y proceda a escanear.", preferredStyle: .alert)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ScanSelectedPeripheral?.delegate = self
        
        serialBT.delegate = self
        
        if let connectedPeripheral = serialBT.connectedPeripheral {
            print("Conectado a: \(connectedPeripheral.name ?? "Desconocido")")
        } else {
            print("Ningún dispositivo conectado.")
        }
        
        
        GifView.loadGif(name: "circular-soundwave_03")
        GifView.isHidden = true
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        stopScan = false
        okFlag = false
        
        alertController1.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
        
        present(alertController1, animated: true, completion: nil)
        
        discoverServices()
        
    }
    
    
    
    
    // FUNCIONES DE ELEMENTOS DE LA VISTA
    
    
    @IBAction func scanButton(_ sender: Any) {
        
        suscribeToScan()
        
        scanningLabel.text = "Escaneando... Permanezca quieto"
        
        GifView.isHidden = false
        GifView.alpha = 0.0
        UIView.animate(withDuration: 1.5) {
            self.GifView.alpha = 1.0 // Hace que la imagen sea completamente visible.
        }
        
        scanButton.isEnabled = false
        scanningLabel.isHidden = false
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(scanTimeOut), userInfo: nil, repeats: false)
        
    }
    
    
    
    
    // FUNCIONES AUXILIARES
    
    @objc func scanTimeOut() {
        
        print(arrayMax)
        print(arrayMin)
        
        UIView.animate(withDuration: 1.5) {
            self.GifView.alpha = 0.0 // Hace que la imagen sea completamente invisible.
        }
        
        scanButton.isEnabled = true
        
        scanningLabel.isHidden = true
        
        
        if( !fullScanFlag ){
            
            // Crea la alerta
            alertController1 = UIAlertController(title: "Escaneo 1 completado", message: "Por favor, estire todo lo que pueda la rodilla y proceda a escanear de nuevo.", preferredStyle: .alert)
            
            // Cambiar el color del título a verde
            if let titleString = alertController1.title {
                let titleMutableString = NSMutableAttributedString(string: titleString)
                titleMutableString.addAttribute(.foregroundColor, value: UIColor.systemGreen, range: NSRange(location: 0, length: titleString.count))
                alertController1.setValue(titleMutableString, forKey: "attributedTitle")
            }
            
            //repetir escaneo
            alertController1.addAction(UIAlertAction(title: "Repetir escaneo", style: .default, handler: { action in
                self.arrayMax = []
                self.scanButton((Any).self)
                self.fullScanFlag = false
            }))
            // Agregar un botón "Aceptar"
            alertController1.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { action in
                self.fullScanFlag = true
            }))
            
            
            if !stopScan { //si el dispositivo se ha desconectado que no se muestre el aviso de escaneo
                // Mostrar la alerta
                present(alertController1, animated: true, completion: nil)
            }
            
            
        } else {
            
            // Crea la alerta
            alertController1 = UIAlertController(title: "Escaneo 2 completado", message: "El cuestionario está listo para ser enviado.", preferredStyle: .alert)
            
            // Cambiar el color del título a verde
            if let titleString = alertController1.title {
                let titleMutableString = NSMutableAttributedString(string: titleString)
                titleMutableString.addAttribute(.foregroundColor, value: UIColor.systemGreen, range: NSRange(location: 0, length: titleString.count))
                alertController1.setValue(titleMutableString, forKey: "attributedTitle")
            }
            
            //repetir escaneo
            alertController1.addAction(UIAlertAction(title: "Repetir escaneo", style: .default, handler: { action in
                self.arrayMin = []
                self.scanButton((Any).self)
            }))
            
            // Agregar un botón "Aceptar"
            alertController1.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { action in
                // Realiza la transición a la siguiente vista aquí
                self.navigateBack()
            }))
            
            
            if !stopScan { //si el dispositivo se ha desconectado que no se muestre el aviso de escaneo
                // Mostrar la alerta
                present(alertController1, animated: true, completion: nil)
            }
            
        }
        
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error al actualizar el valor de la característica: \(error.localizedDescription)")
            return
        }
        
        if let value = characteristic.value {
            let dataString = String(data: value, encoding: .utf8)
            if let data = dataString!.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                // Obtener el valor del campo "angle"
                if let angle = json["angle"] as? String {
                    print("El valor del campo 'angle' es: \(angle)")
                    
                    if( !fullScanFlag ) {
                        arrayMax.append(Double(angle)!)
                    } else {
                        arrayMin.append(Double(angle)!)
                    }
                }
            } else {
                print("Error al parsear el JSON")
            }
        }
    }
    
    
    func suscribeToScan() {
        
        let characteristicUUID = CBUUID(nsuuid: KNEE_MESSAGES_CHARACTERISTIC_UUID)
        let characteristic = ScanSelectedPeripheral?.services?.first?.characteristics?.first(where: { $0.uuid == characteristicUUID })
        
        // Habilitar las notificaciones para la característica deseada
        ScanSelectedPeripheral?.setNotifyValue(true, for: characteristic!)
        
        // Temporizador para detener las notificaciones después de 5 segundos
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
            // Cuando el temporizador expire, deshabilita las notificaciones
            self.ScanSelectedPeripheral?.setNotifyValue(false, for: characteristic!)
            
        }
    }
    
    
    
    func discoverServices() {
        
        ScanSelectedPeripheral?.discoverServices(nil)
        
    }
    
    
    func navigateBack() { //para navegar en la pila de views y acceder a una view en concreto
        
        okFlag = true
        
        if let viewControllers = self.navigationController?.viewControllers {
            for viewController in viewControllers {
                if let viewControllerBT2 = viewController as? DeviceBTViewController {
                    print("encontro bt2")
                    viewControllerBT2.serialBT.disconnect()
                    
                }
                if let viewControllerBT = viewController as? BTViewController {
                    // Se encontró la vista de destino
                    print("encontro bt")
                    
                    viewControllerBT.sendFlag = true
                    
                    let sumaMax = arrayMax.reduce(0.0, +)
                    let sumaMin = arrayMin.reduce(0.0, +)
                    let mediaMax = sumaMax / Double(arrayMax.count)
                    let mediaMin = sumaMin / Double(arrayMin.count)
                    
                    print("La mediaMax es: \(mediaMax)")
                    print("La mediaMin es: \(mediaMin)")
                    
                    
                    viewControllerBT.varMax = mediaMax
                    viewControllerBT.varMin = mediaMin
                    
                    self.navigationController?.popToViewController(viewController, animated: true)
                }
            }
        }
    }
    
    
}




// EXTENSIONES


extension ViewControllerScanBT: CBPeripheralDelegate { //delegado para los servicios
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let error = error {
            print("Error al descubrir servicios: \(error.localizedDescription)")
            return
        }
        
        if peripheral.state == .connected {
            print("dispositivo conectado")
        } else {
            print("dispositivo no conectado")
        }
        
        if let services = peripheral.services {
            for service in services {
                print("Servicio encontrado: \(service.uuid)")
                
                peripheral.discoverCharacteristics(nil, for: service) // Descubre las características del servicio
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("caracteristicas descubiertas")
    }
    
    
}

extension ViewControllerScanBT: BluetoothSerialDelegate {
    
    func serialDidChangeState() {
        if serialBT.centralManager.state != .poweredOn {
            print("bt apagado,,,")
            
            self.ScanSelectedPeripheral = nil
            
            UIView.animate(withDuration: 1.5) {
                self.GifView.alpha = 0.0 // Hace que la imagen sea completamente invisible.
            }
            
            stopScan = true
            
            if(!okFlag){
                
                alertController1.dismiss(animated: false){
                    let alertController = UIAlertController(title: "Error de conexión", message: "El dispositivo se ha desconectado.", preferredStyle: .alert)
                    
                    // Cambiar el color del título a rojo
                    if let titleString = alertController.title {
                        let titleMutableString = NSMutableAttributedString(string: titleString)
                        titleMutableString.addAttribute(.foregroundColor, value: UIColor.systemRed, range: NSRange(location: 0, length: titleString.count))
                        alertController.setValue(titleMutableString, forKey: "attributedTitle")
                    }
                    
                    alertController.addAction(UIAlertAction(title: "Volver", style: .default, handler: { action in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    
                    // Mostrar la alerta
                    self.present(alertController, animated: true, completion: nil)
                }
                
                return
                
            }
            
        } else {
            print("bt encendido,,,")
            
        }
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        
        print("Disconnected,,,")
        
        self.ScanSelectedPeripheral = nil
        
        UIView.animate(withDuration: 1.5) {
            self.GifView.alpha = 0.0 // Hace que la imagen sea completamente invisible.
        }
        
        stopScan = true
        
        if( !okFlag ){
            
            alertController1.dismiss(animated: false){
                
                let alertController = UIAlertController(title: "Error de conexión", message: "El dispositivo se ha desconectado.", preferredStyle: .alert)
                
                // Cambiar el color del título a rojo
                if let titleString = alertController.title {
                    let titleMutableString = NSMutableAttributedString(string: titleString)
                    titleMutableString.addAttribute(.foregroundColor, value: UIColor.systemRed, range: NSRange(location: 0, length: titleString.count))
                    alertController.setValue(titleMutableString, forKey: "attributedTitle")
                }
                
                alertController.addAction(UIAlertAction(title: "Volver", style: .default, handler: { action in
                    self.navigationController?.popViewController(animated: true)
                }))
                
                // Mostrar la alerta
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
}

