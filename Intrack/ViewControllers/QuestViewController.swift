//
//  QuestViewController.swift
//  Intrack
//
//  Created by Victor Martin Fuentes on 21/7/23.
//

import UIKit
import CoreBluetooth


class QuestViewController: UIViewController {
    
    
    //ELEMENTOS DE LA VISTA
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var takePicButton: UIButton!
    @IBOutlet weak var nextQuestButton: UIButton!
    @IBOutlet weak var backQuestButton: UIButton!
    @IBOutlet weak var questLabel: UILabel!
    @IBOutlet weak var answersTable: UITableView!
    @IBOutlet weak var evaView: UIView!
    @IBOutlet weak var evaSlider: UISlider!
    @IBOutlet weak var evaImage: UIImageView!
    
    
    //VARIABLES AUXILIARES
    var currentFormQuest: QuestForm?
    var serverQuest: Form? = nil //guardamos el formulario entero que queremos rellenar
    var questionAnswers: [AnswerForm] = [] //carga las respuesta de la pregunta a mostrar
    var arrayAnswers: [Int] = [] //guardamos el id de las respuestas a mandar
    var arrayImages: [images] = [] //guardamos las imagenes a mandar
    var questionCont: Int = 0 //
    var numberQuestions: Int = 0
    var questID: Int = 0
    let alertControllerAC = UIAlertController(title: " ", message: "", preferredStyle: .alert)
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ajustamos el indicador de actividad y lo mostramos
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        alertControllerAC.view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: alertControllerAC.view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: alertControllerAC.view.centerYAnchor).isActive = true
        activityIndicator.startAnimating()
        present(alertControllerAC, animated: false, completion: nil)
        
        title = currentFormQuest?.title
        
        getQuestQuestions()
        
        
        nextQuestButton.isEnabled = false
        nextQuestButton.isHidden = false
        
        answersTable.register(AnswerCustomCell.nib(), forCellReuseIdentifier: AnswerCustomCell.identifier)
        answersTable.rowHeight = UITableView.automaticDimension
        
        //delegates
        answersTable.delegate = self
        answersTable.dataSource = self
        
        
        evaView.isHidden = true
        evaImage.image = UIImage(named: "disatisfied")
        evaImage.tintColor = UIColor(red: 255/255, green: 204/255, blue: 0, alpha: 1.0)
        evaSlider.tintColor = UIColor(red: 255/255, green: 204/255, blue: 0, alpha: 1.0)
        
    }
    
    
    // FUNCIONES DE ELEMENTOS DE LA VISTA
    
    @IBAction func backQuestButton(_ sender: Any) {
        
        questionCont -= 1
        questLabel.text = serverQuest?.questions[questionCont].body
        updateQuestion()
        backQuestButton.isEnabled = questionCont > 0
        
        if let questionFilled = serverQuest?.questions[questionCont] as? QuestionFilled {
            nextQuestButton.isEnabled = (questionFilled.answerSelected == nil)
        }
        
        let buttonText = currentFormQuest?.need_device == 0 ? (questionCont == numberQuestions ? "Enviar" : "Siguiente") : "Siguiente"
        nextQuestButton.setTitle(buttonText, for: .normal)
        
        typeQuestionInterface()
    }
    
    
    @IBAction func nextQuestButton(_ sender: Any) {
        
        // Verificar si es la última pregunta y no se necesita un dispositivo
        if questionCont == numberQuestions - 1, currentFormQuest?.need_device == 0 {
            
            prepareDataToSend()
            
            let session = Session(
                timestampInit: UserDefaults.standard.integer(forKey: "userTimestampInit"),
                timestampEnd: Int(Date().timeIntervalSince1970),
                idQuest: questID,
                answers: arrayAnswers
            )
            sendSessionData(Session: session)
            return
        }
        
        // Verificar si no hay preguntas y se necesita un dispositivo
        if numberQuestions == 0, currentFormQuest?.need_device == 1 {
            nextQuestButton.setTitle("Siguiente", for: .normal)
            prepareDataToSend()
            navigateToBluetoothViewController()
            return
        }
        
        // Verificar si es la última pregunta y se necesita un dispositivo
        if questionCont == numberQuestions - 1, currentFormQuest?.need_device == 1 {
            nextQuestButton.setTitle("Siguiente", for: .normal)
            prepareDataToSend()
            navigateToBluetoothViewController()
            return
        }
        
        
        // Incrementar el contador de preguntas
        questionCont += 1
        
        // Actualizar el texto de la pregunta
        questLabel.text = serverQuest?.questions[questionCont].body
        
        // Verificar si la pregunta actual está respondida para habilitar el botón siguiente
        if let questionFilled = serverQuest?.questions[questionCont] as? QuestionFilled {
            nextQuestButton.isEnabled = (questionFilled.answerSelected != nil)
        } else {
            nextQuestButton.isEnabled = false // deshabilitar el botón por defecto
        }
        
        // Configurar el texto del botón siguiente
        if currentFormQuest?.need_device == 0 {
            let isLastQuestion = questionCont == numberQuestions - 1
            let buttonText = isLastQuestion ? "Enviar" : "Siguiente"
            nextQuestButton.setTitle(buttonText, for: .normal)
        } else {
            nextQuestButton.setTitle("Siguiente", for: .normal)
        }
        
        // Habilitar/deshabilitar el botón atrás según la pregunta actual
        backQuestButton.isEnabled = questionCont > 0
        
        // Actualizar la interfaz de acuerdo al tipo de pregunta
        typeQuestionInterface()
        updateQuestion() //actualizar la pregunta (actualizar tabla)
    }
    
    
    @IBAction func takePicButton(_ sender: Any) {
        
        let alertController = UIAlertController(title: nil, message: "Selecciona una fuente", preferredStyle: .actionSheet)
                
                let cameraAction = UIAlertAction(title: "Cámara", style: .default) { [weak self] _ in
                    self?.openCamera()
                }
                alertController.addAction(cameraAction)
                
                let galeriaAction = UIAlertAction(title: "Galería", style: .default) { [weak self] _ in
                    self?.openGallery()
                }
                alertController.addAction(galeriaAction)
                
                let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    
    
    
    // FUNCIONES AUXILIARES
    
    
    func openCamera() {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                present(picker, animated: true)
            } else {
                // Mostrar un mensaje de que la cámara no está disponible
                print("Camara no disponible")
            }
        }
    
        
    func openGallery() {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            present(picker, animated: true)
        }
    
    
    @objc func sliderValueChanged(sender: UISlider) {
        
        let currentIndex = Int(sender.value)
        
        if currentIndex >= 0 && currentIndex < (serverQuest?.questions[questionCont].answers.count)! {
            
            if let questionFilled = serverQuest?.questions[questionCont] as? QuestionFilled {
                
                questionFilled.answerSelected = currentIndex //cambiar el valor
            }
            
            colorSwitchEVA(currentIndex: currentIndex)
        }
    }
    
    
    func prepareDataToSend(){
        
        arrayAnswers = []
        arrayImages = []
        
        for question in serverQuest!.questions {
            if let filledQuestion = question as? QuestionFilled {
                arrayAnswers.append(question.answers[filledQuestion.answerSelected!].id)
                
                if( filledQuestion.type == .photo ){
                    for answers in question.answers {
                        if let imgAnswer = answers as? AnswerImageForm{
                            
                            let imgObj = images(image: imgAnswer.image!, id: filledQuestion.answers[filledQuestion.answerSelected!].id)
                            arrayImages.append(imgObj)
                        }
                    }
                }
                
            }
        }
    }
    
    
    func typeQuestionInterface(){
        
        if( serverQuest?.questions[questionCont].type == .eva){
            nextQuestButton.isEnabled = true
            changeQuestionEVA()
            
        }else if (serverQuest?.questions[questionCont].type == .photo){
            changeQuestionImage()
            
        } else{
            
            changeQuestionText()
        }
    }
    
    
    func colorSwitchEVA(currentIndex: Int) {
        
        switch currentIndex {
        case 0:
            evaImage.image = UIImage(named: "extremely_dissatisfied")
            evaImage.tintColor = .systemRed
            evaSlider.tintColor = .systemRed
        case 1:
            evaImage.image = UIImage(named: "very_disatisfied")
            evaImage.tintColor = UIColor(red: 255/255, green: 106/255, blue: 0, alpha: 1.0)
            evaSlider.tintColor = UIColor(red: 255/255, green: 106/255, blue: 0, alpha: 1.0)
        case 2:
            evaImage.image = UIImage(named: "disatisfied")
            evaImage.tintColor = UIColor(red: 255/255, green: 204/255, blue: 0, alpha: 1.0)
            evaSlider.tintColor = UIColor(red: 255/255, green: 204/255, blue: 0, alpha: 1.0)
        case 3:
            evaImage.image = UIImage(named: "sentiment_neutral")
            evaImage.tintColor =  UIColor(red: 242/255, green: 248/255, blue: 64/255, alpha: 1)
            evaSlider.tintColor =  UIColor(red: 242/255, green: 248/255, blue: 64/255, alpha: 1)
        case 4:
            evaImage.image = UIImage(named: "satisfied")
            evaImage.tintColor = UIColor(red: 155/255, green: 255/255, blue: 0, alpha: 1)
            evaSlider.tintColor = UIColor(red: 155/255, green: 255/255, blue: 0, alpha: 1)
        case 5:
            evaImage.image = UIImage(named: "very_satisfied")
            evaImage.tintColor = UIColor(red: 0/255, green: 255/255, blue: 0, alpha: 1)
            evaSlider.tintColor = UIColor(red: 0/255, green: 255/255, blue: 0, alpha: 1)
        default:
            break
        }
    }
    
    
    func changeQuestionEVA() {
        
        answersTable.isHidden = true
        
        evaView.layer.isHidden = false
        evaImage.isHidden = false
        evaSlider.isHidden = false
        takePicButton.isHidden = true
        photo.isHidden = true
        
        
        if let questionFilled = serverQuest?.questions[questionCont] as? QuestionFilled {
            if(questionFilled.answerSelected != nil){ // Verificar si la pregunta fue rellenada
                
                evaSlider.minimumValue = 0
                evaSlider.maximumValue = Float((serverQuest?.questions.count)! - 1)
                
                //print("SI EXISTE EL VALOR, ESTE ES: \(questionFilled.answerSelected)")
                
                //RESTAURAR ESCALA EVA
                
                if questionCont < (serverQuest?.questions.count)! {
                    evaSlider.value = Float(questionFilled.answerSelected!)
                    colorSwitchEVA(currentIndex: questionFilled.answerSelected!)
                    
                }
                
                
                evaSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
                
            } else { //si la pregunta todavia no fue rellenada
                
                print("NO EXISTE EL VALOR")
                evaSlider.minimumValue = 0
                evaSlider.maximumValue = Float((serverQuest?.questions.count)!)
                evaSlider.value = 3 // Establece el valor inicial
                evaSlider.tintColor = UIColor(red: 255/255, green: 204/255, blue: 0, alpha: 1.0)
                
                evaImage.image = UIImage(named: "disatisfied")
                evaImage.tintColor = UIColor(red: 255/255, green: 204/255, blue: 0, alpha: 1.0)
                
                evaSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
                
                questionFilled.answerSelected = 2 //guardamos el indice del medio
                //si no existe el valor, que directamente se añada el valor del medio
            }
        }
        
    }
    
    
    
    func changeQuestionImage(){
        answersTable.isHidden = true
        
        evaView.layer.isHidden = false
        evaImage.isHidden = true
        evaSlider.isHidden = true
        takePicButton.isHidden = false
        
        
        if let questionFilled = serverQuest?.questions[questionCont] as? QuestionFilled {
            if(questionFilled.answerSelected != nil){ // Verificar si la pregunta fue rellenada
                
                print("pregunta rellenada")
                
                if let imgAnswer = questionFilled.answers[0] as? AnswerImageForm {
                    print("hay imagen guardada")
                    photo.image = imgAnswer.image
                    
                    photo.isHidden = false
                    
                } else {
                    print("no hay una imagen guardada")
                    
                }
                
            } else{ //si no fue rellenada
                
                print("pregunta no rellenada")
                
                photo.image = UIImage(systemName: "photo.fill")
                photo.tintColor = .gray
                photo.isHidden = false
            }
        }
        
    }
    
    
    func changeQuestionText(){
        
        answersTable.isHidden = false
        evaView.layer.isHidden = true
        
    }
    
    
    func updateQuestion() {
        questLabel.text = serverQuest?.questions[questionCont].body
        questionAnswers = (serverQuest?.questions[questionCont].answers)!
        answersTable.reloadData()
    }
    
    
    
    func navigateToBluetoothViewController() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ViewControllerBlueT") as! BTViewController
        vc.idQuest = currentFormQuest!.id
        vc.BTarrayAnswers = arrayAnswers
        vc.BTarrayImages = arrayImages
        vc.timestampInit = UserDefaults.standard.integer(forKey: "userTimestampInit")
        
        let backButton = UIBarButtonItem()
        backButton.title = "Volver al cuestionario"
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func sendSessionData(Session: Session) {
        
        var msgPresented = false
        
        //creamos el aviso de error
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

        //presentamos la alerta
        present(alertControllerAC, animated: true, completion: nil)

        // Contadores para rastrear el progreso
        var successfulImageCount = 0
        var failedImageCount = 0

        // Función para manejar el resultado del envío de imágenes
        func handleImageResult() {
            if successfulImageCount + failedImageCount == self.arrayImages.count { //si ya se han procesado todas las imagenes
                let title: String
                let message: String

                if successfulImageCount == self.arrayImages.count { //si se han procesado TODAS correctamente
                    title = "Envío completado con éxito"
                    message = "Su cuestionario ha sido enviado con éxito, puede continuar."
                } else { //si no se han procesado TODAS las imagenes correctamente
                    title = "Error en el envío"
                    message = "Su cuestionario no ha podido ser enviado, disculpe las molestias."
                }

                
                alertControllerAC.dismiss(animated: true) { //quitar la animación de carga
                    //se crea el aviso
                    alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Aceptar", style: .default) { _ in
                        if successfulImageCount == self.arrayImages.count { //si se procesaron todas las imagenes correctamente que se añada la accion de vuelta
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    })
                    
                    //mostrar el aviso
                    self.present(alertController, animated: true, completion: nil)
                    msgPresented = true //desactivar el timeout
                }

            }
        }

        // Programar una tarea para ejecutar después de 15 segundos
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
            // Verificar si ya se ha mostrado la alerta
            if msgPresented { // si se desactivó el timeout
                print("La alerta se presentó")
            } else {
                print("La alerta no se mostró en 15 segundos.")
                alertControllerAC.dismiss(animated: true) { //quitar la animación de carga
                    //mostrar mensaje de error
                    alertController = UIAlertController(title: "Error en el envío", message: "Su cuestionario no ha podido ser enviado, disculpe las molestias.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    
                    // Finalizar la ejecución de la función
                    return
                }
            }
        }

        WebRequest.sendSessionData(Session: Session) { SessionResponse in
            print("Ok cuestionario") //si se consigue mandar el cuestionario, que se procedan a mandar las imagenes
            
            if !self.arrayImages.isEmpty { //si hay imagenes a mandar
                // Ciclo para enviar imágenes
                for image in self.arrayImages { //mandar de una en una las imagenes
                    WebRequest.sendImage(idSession: SessionResponse.idSession, idAnswer: image.id, imageToSend: image.image, sendImageSuccess: {
                        // Imagen enviada con éxito
                        print("Ok imagen")
                        successfulImageCount += 1 // si la imagen se manda bien que aumente su contador
                        handleImageResult()
                    }, error: { errorMessage in
                        // Error al enviar la imagen
                        print("No se pudo enviar la imagen")
                        failedImageCount += 1 // si la imagen NO se manda bien que aumente su contador
                        handleImageResult()
                    })
                }
            } else {
                handleImageResult() // si no hay imagenes a mandar se mostrará directamente el aviso de todo correcto
            }
        } error: { errorMessage in
            print("No se pudo enviar el cuestionario")
        }
    }

    
    
    func castQuest( quest: Form ) -> Form { //funcion para clasificar las preguntas del cuestionario con sus respectivos atributos
        
        var questions: [QuestionForm] = []
        
        for question in quest.questions { //recorremos todas las preguntas del array
            
            switch question.type { //dependiendo del tipo de array
                
            case .text:
                print("texto")
                
                var answers: [AnswerForm] = []
                
                for answer in question.answers { //casteamos las respuestas
                    answers.append(AnswerForm(id: answer.id, answer: answer.answer))
                }
                
                //añadimos la pregunta ya casteada
                questions.append(QuestionFilled(id: question.id, body: question.body, answers: question.answers, type: question.type))
                
            case .eva:
                print("EVA")
                
                var answers: [AnswerForm] = []
                
                for answer in question.answers { //casteamos las respuestas
                    answers.append(AnswerForm(id: answer.id, answer: answer.answer))
                }
                
                //añadimos la pregunta ya casteada
                questions.append(QuestionFilled(id: question.id, body: question.body, answers: question.answers, type: question.type))
                
            case .photo:
                print("photo")
                
                let answers = [ AnswerImageForm(id: question.answers[0].id, answer: question.answers[0].answer) ]
                
                questions.append(QuestionFilled(id: question.id, body: question.body, answers: answers, type: question.type))
                
            }
            
        }
        
        return Form(id_quest: quest.id_quest, questions: questions) //devolvemos el cuestionario ya clasificado por tipos de preguntas
        
    }
    
    
    func getQuestQuestions() {
        
        //implementar timeout
        var alert = false
        
        //implementar timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            // Verificar si ya se ha mostrado la alerta
            if alert {
                print("Todo correcto")
            } else {
                print("No ha habido respuesta en cinco segundos")
                
                self.alertControllerAC.dismiss(animated: true) {
                    let alertController = UIAlertController(title: "Error en el cuestionario", message: "No se ha podido abrir el cuestionario, espere unos instantes y vuelva a intentarlo", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Aceptar", style: .default) { _ in
                            self.navigationController?.popToRootViewController(animated: true)
                    })
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
            }
        }
        
        WebRequest.getQuestQuestions(idQuest: String(currentFormQuest!.id)) { QuestQuestions in
            //si recuperamos el questQuestions que no se muestre el error
            
            alert = true
            
            self.serverQuest = self.castQuest(quest: QuestQuestions) // guardamos el cuestionario ya clasificado por preguntas
            self.questID = self.serverQuest!.id_quest

            if let serverQuest = self.serverQuest {
                print("id_quest: \(serverQuest.id_quest)")
                for question in self.serverQuest!.questions {
                    if let filledQuestion = question as? QuestionFilled {
                        print("Question - id: \(filledQuestion.id), type: \(filledQuestion.type)")
                    }
                }
            } else {
                print("serverQuest es nil")
            }
            
            
            self.numberQuestions = self.serverQuest!.questions.count //guardar el numero de preguntas que tiene el cuestionario
            
            
            
            if(self.numberQuestions != 0){
                self.questionAnswers = (self.serverQuest?.questions[0].answers)!
                self.questLabel.text = self.serverQuest?.questions[0].body
            } else {
                print("SIN PREGUNTAS")
                self.questLabel.text = "Este cuestionario no tiene preguntas"
                self.alertControllerAC.dismiss(animated: true)
                self.nextQuestButton.isEnabled = self.currentFormQuest?.need_device == 1
                
                if ( self.currentFormQuest?.need_device == 1 ) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewControllerBlueT") as! BTViewController
                    vc.idQuest = self.currentFormQuest!.id
                    vc.BTarrayAnswers = self.arrayAnswers
                    vc.BTarrayImages = self.arrayImages
                    vc.timestampInit = UserDefaults.standard.integer(forKey: "userTimestampInit")
                    vc.numberQuestions = 0
                    vc.need_device = 1
                    
                    let backButton = UIBarButtonItem()
                    backButton.title = "Back"
                    self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
                
                return
            }
            
            self.questionCont = 0 //en que pregunta estamos
            
            // Configurar el texto del botón siguiente
            if let currentFormQuest = self.currentFormQuest, currentFormQuest.need_device == 0 {
                self.nextQuestButton.setTitle(self.numberQuestions == 1 ? "Enviar" : "Siguiente", for: .normal)
            } else {
                self.nextQuestButton.setTitle("Siguiente", for: .normal)
            }

            self.questLabel.isHidden = false
            self.answersTable.reloadData()
            
            
            //recuperamos del servidor un array y de preguntas
            self.alertControllerAC.dismiss(animated: true){
                print("se dismiseó")
            }
            
        } error: { errorMessage in
            print("Error ", errorMessage)
            
        }
        
    } // fin getQuestQuestions()
    
}



// EXTENSIONES

extension QuestViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return questionAnswers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let customCell = answersTable.dequeueReusableCell(withIdentifier: AnswerCustomCell.identifier, for: indexPath) as! AnswerCustomCell
        
        customCell.answerLabel?.text = questionAnswers[indexPath.row].answer
        customCell.answerLabel?.numberOfLines = 0
        
        customCell.checkMark?.image = UIImage(systemName: "circle")
        
        print(indexPath.row)
        
        if let questionFilled = serverQuest?.questions[questionCont] as? QuestionFilled {
            if(questionFilled.answerSelected != nil){
                
                if(indexPath.row == questionFilled.answerSelected){
                    customCell.checkMark?.image = UIImage(systemName: "largecircle.fill.circle")
                    nextQuestButton.isEnabled = true
                }
            } else {
                customCell.checkMark?.image = UIImage(systemName: "circle")
            }
            
        }
        
        return customCell
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath) as! AnswerCustomCell
        
        cell.checkMark?.image = UIImage(systemName: "largecircle.fill.circle")
        
        if let questionFilled = serverQuest?.questions[questionCont] as? QuestionFilled {
            questionFilled.answerSelected = indexPath.row
        }
        
        nextQuestButton.isEnabled = true
        
        for otherCell in tableView.visibleCells {
            
            if otherCell != cell {
                let otherCell = otherCell as! AnswerCustomCell
                otherCell.checkMark?.image = UIImage(systemName: "circle")
                
            }
        }
        
        
    }
    
    
}

extension QuestViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let imageVar = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        photo.image = imageVar
        photo.isHidden = false
        
        nextQuestButton.isEnabled = true
        
        print("SE HACE LA FOTO")
        
        if let questionFilled = serverQuest?.questions[questionCont] as? QuestionFilled {
            questionFilled.answerSelected = 0
            
            for answer in questionFilled.answers {
                if let imgAnser = answer as? AnswerImageForm {
                    imgAnser.image = imageVar
                    print("SE GUARDA LA FOTO")
                } else {
                    print("NO SE GUARDA LA FOTO")
                }
                
            }
        }
    }
    
    
}


