//
//  ChatMessage.swift
//  PulseCor
//
//
import Foundation

struct ChatMessage: Codable {
    let id: Int?
    let sessionId: String  // Links messages to a conversation session
    let sender: MessageSender
    let content: String
    let timestamp: Date
    let messageType: MessageType
    var quickReplies: [String]?  // Optional quick reply buttons
    var stableId: String {
            return id != nil ? String(id!) : "\(timestamp.timeIntervalSince1970)-\(content.prefix(10))"
    }
    
    // initaliser
    init(id: Int? = nil, sessionId: String, sender: MessageSender, content: String, timestamp: Date = Date(), messageType: MessageType = .text, quickReplies: [String]? = nil) {
        self.id = id
        self.sessionId = sessionId
        self.sender = sender
        self.content = content
        self.timestamp = timestamp
        self.messageType = messageType
        self.quickReplies = quickReplies
    }
}

enum MessageSender: String, Codable {
    case cora = "Cora"
    case user = "User"
}

enum MessageType: String, Codable {
    case text = "text"
    case quickReply = "quick_reply"
    case systemInfo = "system_info" //gentle nudges
}
