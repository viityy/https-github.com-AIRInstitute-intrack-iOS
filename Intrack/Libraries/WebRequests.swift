//
//  WebRequests.swift
//  Intrack
//
//  Created by Victor Martin Fuentes on 15/9/23.
//

import Foundation
import Alamofire

class WebRequest {
    
    static var headers: HTTPHeaders = HTTPHeaders()
    
    static let xCodePutoPesao = true
    static let serverURL = xCodePutoPesao ? "http://kevin.der.usal.es:3031/api/":"https://intrack.bisite.usal.es:5000/api/"
    
    static func login(username: String, password: String, loginSuccess:@escaping () -> (), error:@escaping (_ errorMessage: String) -> ()) {
        let url = serverURL + "login"
        print(url)
        
        let parameters = ["username": username, "password": password]
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody).responseDecodable(of: LoginToken.self) { response in
            guard let token = response.value else {
                error(response.error.debugDescription)
                return
            }
            
            headers.add(HTTPHeader(name: "token", value: token.token))
            loginSuccess() //callback (importante)
        }
    }
    
    
    static func getQuests(questsHandler :@escaping (_ quests: [QuestForm]) -> (), error:@escaping (_ errorMessage: String) -> ()) {
        let url = serverURL + "quest"
        print(url)
        
        
        AF.request(url, headers: headers).responseDecodable(of: [QuestForm].self) { response in
            guard let quests = response.value else {
                error(response.error.debugDescription)
                return
            }
            
            questsHandler(quests) //callback (importante)
        }
    }
    
    
    static func getQuestQuestions(idQuest: String, questQuestionsHandler:@escaping (_ QuestQuestions: Form) -> (), error:@escaping (_ errorMessage: String) -> ()) {
        let url = serverURL + "quest/" + idQuest
        print(url)
        
        AF.request(url, method: .get, headers: headers).responseDecodable(of: Form.self) { response in
            guard let QuestQuestions = response.value else {
                error(response.error.debugDescription)
                return
            }
            
            questQuestionsHandler(QuestQuestions) //callback (importante)
        }
    }
    
    
    static func sendSessionData(Session: Session, sendSessionDataSuccess:@escaping (_ SessionResponse: ResponseSession) -> (), error:@escaping (_ errorMessage: String) -> ()) {
        let url = serverURL + "session"
        print(url)
        
        do {
            let parameters = try JSONSerialization.jsonObject(with: JSONEncoder().encode(Session), options: .fragmentsAllowed)
            guard let params = parameters as? [String: Any] else { print("Error"); return }
            
            AF.request(url, method:.post, parameters: params, encoding: JSONEncoding.default, headers: self.headers).responseDecodable(of: ResponseSession.self) { response in
                guard let SessionResponse = response.value else {
                    error(response.error.debugDescription)
                    return
                }
                sendSessionDataSuccess(SessionResponse) //callback (importante)
            }
        } catch {
            print("Error")
        }
    }
    
    static func sendSessionDataWithDevice(SessionDev: SessionWithDevice, sendSessionDataSuccess:@escaping (_ SessionResponse: ResponseSession) -> (), error:@escaping (_ errorMessage: String) -> ()) {
        let url = serverURL + "session"
        print(url)
        
        do {
            let parameters = try JSONSerialization.jsonObject(with: JSONEncoder().encode(SessionDev), options: .fragmentsAllowed)
            guard let params = parameters as? [String: Any] else { print("Error"); return }
            
            AF.request(url, method:.post, parameters: params, encoding: JSONEncoding.default, headers: self.headers).responseDecodable(of: ResponseSession.self) { response in
                guard let SessionResponse = response.value else {
                    error(response.error.debugDescription)
                    return
                }
                sendSessionDataSuccess(SessionResponse) //callback (importante)
            }
        } catch {
            print("Error")
        }
        
    }
    
    
    static func getSessions( getSessionsHandler :@escaping (_ sessions: [DataSession]) -> (), error:@escaping (_ errorMessage: String) -> ()) {
        let url = serverURL + "session"
        print(url)
        
        AF.request(url, headers: headers).responseDecodable(of: [DataSession].self) { response in
            guard let sessions = response.value else {
                error(response.error.debugDescription)
                return
            }
            
            getSessionsHandler(sessions) //callback (importante)
        }
    }
    
    static func getLimits( getLimitsHandler :@escaping (_ limits: LimitData) -> (), error:@escaping (_ errorMessage: String) -> ()) {
        let url = serverURL + "limit"
        print(url)
        
        AF.request(url, headers: headers).responseDecodable(of: LimitData.self) { response in
            guard let limits = response.value else {
                error(response.error.debugDescription)
                return
            }
            
            getLimitsHandler(limits) //callback (importante)
        }
    }
    
    
    static func sendImage(idSession: Int, idAnswer: Int, imageToSend: UIImage?, sendImageSuccess: @escaping () -> (), error: @escaping (_ errorMessage: String) -> ()) {
        let baseUrl = serverURL + "session"

        // URL con el ID de sesión
        let url = baseUrl + "/\(idSession)/image"
        print(url)
                
        
        
        if let image = imageToSend?.jpegData(compressionQuality: 1.0) {
            AF.upload(multipartFormData: { multipartFormData in
                // Agrega la imagen como datos binarios al cuerpo de la solicitud
                multipartFormData.append(image, withName: "image", fileName: "image.jpeg", mimeType: "image/jpeg")
                multipartFormData.append("\(idAnswer)".data(using: .utf8)!, withName: "id_quest_answer")
            }, to: url, method: .post, headers: headers)
            .responseString { response in
                switch response.result {
                case .success(let value):
                    print(value)
                    sendImageSuccess()
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            print("Error al cargar la imagen")
        }
    }

}
