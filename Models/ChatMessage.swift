//
//  ChatMessage.swift
//  PulseCor
//
//

import Foundation
import SwiftData

//represents a single messsage in chat interface
@Model
class ChatMessage {
    var sessionId: String //messages are grouped by sessionID (1 per check-in flow)
    var sender: MessageSender
    var content: String
    var timestamp: Date
    var messageType: MessageType
    var quickReplies: [String]

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
}
