//
//  ViewController.swift
//  Intrack
//
//  Created by Victor Martin Fuentes on 19/7/23.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    //ELEMENTOS DE LA VISTA
    @IBOutlet weak var rememberButton: UISwitch!
    @IBOutlet weak var rememberText: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var rememberSwitch: UISwitch!
    @IBOutlet weak var showPassButton: UIButton!
    @IBOutlet weak var logButton: UIButton!
    @IBOutlet weak var forgetButton: UIButton!
    @IBOutlet weak var incorrectLabel: UILabel!
    
    
    //VARIABLES AUXILIARES
    private var checkFlag = false //recordar el usuario y contraseña
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.delegate = self
        passwordField.delegate = self
        
        
        CheckAndAdd()
        incorrectLabel.isHidden = true
        logButton.isEnabled = true
        showPassButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        passwordField.isSecureTextEntry = true
        
        print(UserDefaults.standard.string(forKey: "rememberMe") ?? "")
        
    }
    
    
    // FUNCIONES DE ELEMENTOS DE LA VISTA
    
    @IBAction func rememberSwitch(_ sender: Any) {
        checkFlag = rememberSwitch.isOn
        rememberText.isEnabled = rememberSwitch.isOn
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameField.resignFirstResponder() // Cierra el teclado
        passwordField.resignFirstResponder() // Cierra el teclado
        return true
    }
    
    
    @IBAction func nameField(_ sender: Any) {
        logButton.isEnabled = (nameField.text != "" && passwordField.text != "")
    }
    
    @IBAction func passwordField(_ sender: Any) {
        logButton.isEnabled = (nameField.text != "" && passwordField.text != "")
    }
    
    
    @IBAction func showPassButton(_ sender: Any) {
        showPassButton.setImage((passwordField.isSecureTextEntry) ? UIImage(systemName: "eye.slash.fill") : UIImage(systemName: "eye.fill"), for: .normal)
        passwordField.isSecureTextEntry = !passwordField.isSecureTextEntry
    }
    
    
    @IBAction func logButton(_ sender: Any) {
        
        logButton.isEnabled = false
        
        guard let username = nameField.text, let password = passwordField.text,
              username != "", password != "" else {
            print("Error de asignacion, celdas vacias")
            return
        }
        
        WebRequest.login(username: username, password: password) {
            
            // Login OK
            let currentTimestamp = Int(Date().timeIntervalSince1970)
            UserDefaults.standard.set(currentTimestamp, forKey: "userTimestampInit")
            
            
            self.saveRememberTapped()
            self.incorrectLabel.isHidden = true
            self.nameField.layer.borderColor = UIColor.gray.cgColor
            self.nameField.layer.cornerRadius = 5
            self.passwordField.layer.borderColor = UIColor.gray.cgColor
            self.passwordField.layer.cornerRadius = 5
            self.nameField.layer.borderWidth = 1.0
            self.passwordField.layer.borderWidth = 1.0
            
            let sb = self.storyboard
            self.present(sb!.instantiateViewController(withIdentifier: "ncHomeVC"), animated: true)
            // nos desplazamos al navigation controller asociado a la Home View (pasamos de vista)
            
            self.logButton.isEnabled = true
            
            
        } error: { errorMessage in
            
            // Error
            print(errorMessage)
            
            self.incorrectLabel.isHidden = false
            self.nameField.layer.borderColor = UIColor.red.cgColor
            self.nameField.layer.cornerRadius = 5
            self.passwordField.layer.borderColor = UIColor.red.cgColor
            self.passwordField.layer.cornerRadius = 5
            self.nameField.layer.borderWidth = 1.0
            self.passwordField.layer.borderWidth = 1.0
            
            self.shakeNamefield()
            self.shakePassfield()
            
            self.logButton.isEnabled = true

        }
        
        
    }
    
    
    
    // FUNCIONES AUXILIARES
    
    func saveRememberTapped() {
        let rememberValue = checkFlag ? "1" : "2"
        let isEnabled = checkFlag
        
        // Configurar el switch y el campo de texto de recordar
        rememberButton.isOn = isEnabled
        rememberText.isEnabled = isEnabled
        
        // Guardar los datos en UserDefaults
        UserDefaults.standard.set(rememberValue, forKey: "rememberMe")
        UserDefaults.standard.set(nameField.text ?? "", forKey: "userMail")
        UserDefaults.standard.set(passwordField.text ?? "", forKey: "userPassword")
        
        print("Usuario y contraseña recordados correctamente")
    }
    
    
    func CheckAndAdd() {
        
        let rememberMe = UserDefaults.standard.string(forKey: "rememberMe") ?? "2"
        
        rememberButton.isOn = rememberMe == "1"
        rememberText.isEnabled = rememberMe == "1"
        checkFlag = rememberMe == "1"
        
        if ( checkFlag ) {
            nameField.text = UserDefaults.standard.string(forKey: "userMail") ?? ""
            passwordField.text = UserDefaults.standard.string(forKey: "userPassword") ?? ""
        }
    }
    
    
    func shakeNamefield() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05 // Duración de la animación en segundos
        animation.repeatCount = 3 // Número de repeticiones
        animation.autoreverses = true // Hacer la animación en sentido inverso
        animation.fromValue = NSValue(cgPoint: CGPoint(x: nameField.center.x - 10, y: nameField.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: nameField.center.x + 10, y: nameField.center.y))
        
        // Aplicar la animación al layer del elemento
        nameField.layer.add(animation, forKey: "position")
    }
    
    func shakePassfield() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05 // Duración de la animación en segundos
        animation.repeatCount = 3 // Número de repeticiones
        animation.autoreverses = true // Hacer la animación en sentido inverso
        animation.fromValue = NSValue(cgPoint: CGPoint(x: passwordField.center.x - 10, y: passwordField.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: passwordField.center.x + 10, y: passwordField.center.y))
        
        // Aplicar la animación al layer del elemento
        passwordField.layer.add(animation, forKey: "position")
    }
    
    
}

