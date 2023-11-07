import Foundation

// MARK: - Session
class SessionWithDevice: Codable {
    let timestampInit, timestampEnd, max, min: Int
    let idQuest: Int
    let answers: [Answer]

    enum CodingKeys: String, CodingKey {
        case timestampInit = "timestamp_init"
        case timestampEnd = "timestamp_end"
        case max, min
        case idQuest = "id_quest"
        case answers
    }

    init(timestampInit: Int, timestampEnd: Int, max: Int, min: Int, idQuest: Int, answers: [Answer]) {
        self.timestampInit = timestampInit
        self.timestampEnd = timestampEnd
        self.max = max
        self.min = min
        self.idQuest = idQuest
        self.answers = answers
    }
}
