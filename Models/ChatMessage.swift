import Foundation
import SwiftData

@Model
class ChatMessage {
    var sessionId: String
    var sender: MessageSender
    var content: String
    var timestamp: Date
    var messageType: MessageType
    var quickReplies: [String] // non-optional — SwiftData handles [String] natively, defaults to []

    init(
        sessionId: String,
        sender: MessageSender,
        content: String,
        timestamp: Date = Date(),
        messageType: MessageType = .text,
        quickReplies: [String]? = nil
    ) {
        self.sessionId = sessionId
        self.sender = sender
        self.content = content
        self.timestamp = timestamp
        self.messageType = messageType
        self.quickReplies = quickReplies ?? []
    }
}


enum MessageSender: String, Codable {
    case cora = "Cora"
    case user = "User"
}

enum MessageType: String, Codable {
    case text = "text"
    case quickReply = "quick_reply"
    case systemInfo = "system_info" // gentle nudges
}
