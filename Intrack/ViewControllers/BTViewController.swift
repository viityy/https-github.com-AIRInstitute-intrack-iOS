//
//  BTViewController.swift
//  Intrack
//
//  Created by Victor Martin Fuentes on 29/8/23.
//

import UIKit
import CoreBluetooth

class BTViewController: UIViewController {
    
    
    //ELEMENTOS DE LA VISTA
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var btImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    //VARIABLES AUXILIARES
    var sendFlag = false
    var varMax: Double = 0
    var varMin: Double = 0
    var BTarrayAnswers: [Int] = []
    var BTarrayImages: [images] = []
    var timestampInit: Int = 0
    var idQuest: Int = 0
    var numberQuestions: Int?
    var need_device: Int?
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if sendFlag {
            btImage.image = UIImage(systemName: "folder.fill")
            btImage.tintColor = .systemGreen
            titleLabel.text = "Listo para enviar"
            btImage.isHidden = false
            titleLabel.isHidden = false
            sendButton.setTitle("Enviar", for: .normal)
            
        } else {
            // Crea la alerta
            let alertController = UIAlertController(title: "Antes de encender su dispositivo Intrack", message: "Coloquese el dispositivo Intrack, después estire la pierna. Finalmente enciendalo y pulse en continuar", preferredStyle: .alert)
            
            // Agrega un botón "Continuar"
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { action in
                
            }))
            present(alertController, animated: true, completion: nil)
            titleLabel.text = "BLUETOOTH"
            sendButton.setTitle("Emparejar dispositivo", for: .normal)
            btImage.isHidden = false
            titleLabel.isHidden = false
        }
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            print("nosfuimos")
            if(numberQuestions == 0 && need_device == 1){
                backNoQuestions()
            }
        }
    }
    
    // FUNCIONES DE ELEMENTOS DE LA VISTA
    
    @IBAction func sendButton(_ sender: Any) {
        
        if sendFlag {
            
            let session = SessionWithDevice(
                timestampInit: timestampInit,
                timestampEnd: Int(Date().timeIntervalSince1970),
                max: varMax,
                min: varMin,
                idQuest: idQuest,
                answers: BTarrayAnswers
            )
            sendSessionData(Session: session)
            
        } else {
            
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewControllerBluetooth") as? DeviceBTViewController {
                self.navigationController?.pushViewController(vc, animated: true)
                btImage.isHidden = true
                titleLabel.isHidden = true
                
            }
            
        }
    }
    
    
    
    // FUNCIONES AUXILIARES
    
    
    func backNoQuestions() {
        print("hola")
        // Realiza la acción deseada, en este caso, popToViewController
        if let viewControllers = navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController is DescriptionQuestViewController {
                    navigationController?.popToViewController(viewController, animated: false)
                    break
                }
            }
        }
    }
    
    func sendSessionData(Session: SessionWithDevice ) {
        
        var msgPresented = false
        
        var alertController = UIAlertController(title: "Error en el envío", message: "Su cuestionario no ha podido ser enviado, disculpe las molestias.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
        
        
        // Crear un UIAlertController con un indicador de actividad
        let alertControllerAC = UIAlertController(title: " ", message: "", preferredStyle: .alert)
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        alertControllerAC.view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: alertControllerAC.view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: alertControllerAC.view.centerYAnchor).isActive = true
        activityIndicator.startAnimating()
        
        present(alertControllerAC, animated: true, completion: nil)
        
        // Contadores para rastrear el progreso
        var successfulImageCount = 0
        var failedImageCount = 0
        
        // Función para manejar el resultado del envío de imágenes
        func handleImageResult() {
            if successfulImageCount + failedImageCount == self.BTarrayImages.count {
                let title: String
                let message: String
                
                if successfulImageCount == self.BTarrayImages.count {
                    title = "Envío completado con éxito"
                    message = "Su cuestionario ha sido enviado con éxito, puede continuar."
                } else {
                    title = "Error en el envío"
                    message = "Su cuestionario no ha podido ser enviado, disculpe las molestias."
                }
                
                
                alertControllerAC.dismiss(animated: true) {
                    alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Aceptar", style: .default) { _ in
                        if successfulImageCount == self.BTarrayImages.count {
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    })
                    self.present(alertController, animated: true, completion: nil)
                    msgPresented = true
                }
                
            }
        }
        
        // Programar una tarea para ejecutar después de 15 segundos
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
            // Verificar si ya se ha mostrado la alerta
            if msgPresented {
                print("La alerta se presentó")
            } else {
                print("La alerta no se mostró en 15 segundos.")
                alertControllerAC.dismiss(animated: true) {
                    // Finalizar la ejecución de la función
                    
                    alertController = UIAlertController(title: "Error en el envío", message: "Su cuestionario no ha podido ser enviado, disculpe las molestias.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
            }
        }
        
        WebRequest.sendSessionDataWithDevice(SessionDev: Session) { SessionResponse in
            print("Ok cuestionario")
            
            if !self.BTarrayImages.isEmpty {
                // Ciclo para enviar imágenes
                for image in self.BTarrayImages {
                    WebRequest.sendImage(idSession: SessionResponse.idSession, idAnswer: image.id, imageToSend: image.image, sendImageSuccess: {
                        // Imagen enviada con éxito
                        print("Ok imagen")
                        successfulImageCount += 1
                        handleImageResult()
                    }, error: { errorMessage in
                        // Error al enviar la imagen
                        print("No se pudo enviar la imagen")
                        failedImageCount += 1
                        handleImageResult()
                    })
                }
            } else {
                handleImageResult()
            }
        } error: { errorMessage in
            print("No se pudo enviar el cuestionario")
        }
    }
    
}
