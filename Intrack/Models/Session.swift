//
//  Session.swift
//  Intrack
//
//  Created by Victor Martin Fuentes on 18/9/23.
//

import Foundation
import UIKit

class Session: Codable {
    let timestampInit, timestampEnd, idQuest: Int
    let answers: [Int]

    enum CodingKeys: String, CodingKey {
        case timestampInit = "timestamp_init"
        case timestampEnd = "timestamp_end"
        case idQuest = "id_quest"
        case answers
    }

    init(timestampInit: Int, timestampEnd: Int, idQuest: Int, answers: [Int]) {
        self.timestampInit = timestampInit
        self.timestampEnd = timestampEnd
        self.idQuest = idQuest
        self.answers = answers
    }
}



class SessionWithDevice: Codable {
    let timestampInit, timestampEnd: Int
    let max, min: Double
    let idQuest: Int
    let answers: [Int]

    enum CodingKeys: String, CodingKey {
        case timestampInit = "timestamp_init"
        case timestampEnd = "timestamp_end"
        case max = "max"
        case min = "min"
        case idQuest = "id_quest"
        case answers
    }

    init(timestampInit: Int, timestampEnd: Int, max: Double, min: Double, idQuest: Int, answers: [Int]) {
        self.timestampInit = timestampInit
        self.timestampEnd = timestampEnd
        self.max = max
        self.min = min
        self.idQuest = idQuest
        self.answers = answers
    }
}

class DataSession: Codable {
    let id: Int
    let timestamp_init: Int
    let timestamp_end: Int
    let max: Double?
    let min: Double?
    let id_user: Int
    let id_quest: Int

    enum CodingKeys: String, CodingKey {
        case id
        case timestamp_init
        case timestamp_end
        case max
        case min
        case id_user
        case id_quest
    }

    init(id: Int, timestamp_init: Int, timestamp_end: Int, max: Double?, min: Double?, id_user: Int, id_quest: Int) {
        self.id = id
        self.timestamp_init = timestamp_init
        self.timestamp_end = timestamp_end
        self.max = max
        self.min = min
        self.id_user = id_user
        self.id_quest = id_quest
    }
}

class LimitData: Codable {
    var min_limit: Double
    var max_limit: Double
}

class ResponseSession: Codable {
    
    let idSession: Int

    enum CodingKeys: String, CodingKey {
        case idSession = "id_session"
    }

    init(idSession: Int) {
        self.idSession = idSession
    }
}

//**************************************************

