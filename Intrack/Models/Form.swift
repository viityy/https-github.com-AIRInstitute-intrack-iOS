//
//  Formulario.swift
//  Intrack
//
//  Created by Victor Martin Fuentes on 24/7/23.
//


// cuestionario = id, title, description, vector preguntas
//pregunta = struct de stringpregunta + vector respuestas

import Foundation
import UIKit


// CLASES PARA DECODIFICAR

class QuestForm: Codable { //cuestionarios para el HOME 
    let id: Int
    let title, description: String
    let periodicity, need_device: Int

    enum CodingKeys: String, CodingKey {
        case id
        case title, description, periodicity
        case need_device
    }

    init(id: Int, title: String, description: String, periodicity: Int, need_device: Int) {
        self.id = id
        self.title = title
        self.description = description
        self.periodicity = periodicity
        self.need_device = need_device
    }
}

class Form: Codable { //cuestionario con sus preguntas
    let id_quest: Int
    let questions: [QuestionForm]

    enum CodingKeys: String, CodingKey {
        case id_quest
        case questions
    }

    init(id_quest: Int, questions: [QuestionForm]) {
        self.id_quest = id_quest
        self.questions = questions
    }
}

enum QuestionType: String, Codable {
    case text = "text", photo = "photo", eva = "EVA"
}

class QuestionForm: Codable { //clase para decodificar del json obtenido del servidor
    let id: Int
    let body: String
    let answers: [AnswerForm]
    let type: QuestionType

    init(id: Int, body: String, answers: [AnswerForm], type: QuestionType) {
        self.id = id
        self.body = body
        self.answers = answers
        self.type = type
    }
}

class QuestionFilled: QuestionForm { //clase heredada para clasificar
    var answerSelected: Int?
    init(id: Int, body: String, answers: [AnswerForm], type: QuestionType, answerSelected: Int? = nil) {
        self.answerSelected = answerSelected
        super.init(id: id, body: body, answers: answers, type: type)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

class AnswerForm: Codable { //clase para decodificar del json obtenido del servidor
    let id: Int
    let answer: String
    init(id: Int, answer: String) {
        self.id = id
        self.answer = answer
    }
}

class AnswerImageForm: AnswerForm { //clase heredada para clasificar
    var image: UIImage?
    init(id: Int, answer: String, image: UIImage? = nil ) {
        self.image = image
        super.init(id: id, answer: answer)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

//*****************************************************************************************


class images {
    var image: UIImage
    var id: Int
    init(image: UIImage, id: Int) {
        self.image = image
        self.id = id
    }
}

