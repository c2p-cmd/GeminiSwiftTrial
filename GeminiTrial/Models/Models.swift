//
//  Models.swift
//  GeminiTrial
//
//  Created by Sharan Thakur on 30/12/23.
//

import GoogleGenerativeAI
import SwiftUI
import SwiftyChat

@Observable
class AIViewModel {
    private let model: GenerativeModel
    private let imageModel: GenerativeModel
    private var chat: Chat
    
    public var messages: [MessageItem]
    
    init() {
        let settings = [
            SafetySetting(harmCategory: .sexuallyExplicit, threshold: .blockOnlyHigh)
        ]
        self.model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.stored, safetySettings: settings)
        self.chat = self.model.startChat()
        self.imageModel = GenerativeModel(name: "gemini-pro-vision", apiKey: APIKey.stored, safetySettings: settings)
        self.messages = [
            MessageItem(
                user: .botUser,
                messageKind: .text("Hey there I am Google's LLM!\n<a href=\"https://deepmind.google/technologies/gemini/\">Learn More</a>")
            )
        ]
    }
    
    func askAI(kind: ChatMessageKind, completion: @escaping (MessageItem) -> Void) {
        Task {
            do {
                // MARK: Only Text
                if case ChatMessageKind.text(let text) = kind {
                    let result = try await chat.sendMessage(text)
                    if let response = result.text {
                        withAnimation {
                            completion(MessageItem(user: .botUser, messageKind: .text(response)))
                        }
                    }
                }
                
                // MARK: Image & Text
                if case ChatMessageKind.imageText(let imageKind, let text) = kind {
                    let result: GenerateContentResponse
                    
                    switch imageKind {
                    case .local(let uiImage):
                        result = try await imageModel.generateContent(uiImage, text)
                        break
                    case .remote(let url):
                        let (data, _) = try await URLSession.shared.data(from: url)
                        let uiImage = UIImage(data: data)!
                        result = try await imageModel.generateContent(uiImage, text)
                        break
                    }
                    
                    withAnimation {
                        if let response = result.text {
                            completion(MessageItem(user: .botUser, messageKind: .text(response)))
                        }
                    }
                }
                
                // MARK: Only Image
                if case ChatMessageKind.image(let imageKind) = kind {
                    let result: GenerateContentResponse
                    
                    switch imageKind {
                    case .local(let uiImage):
                        result = try await imageModel.generateContent(uiImage)
                        break
                    case .remote(let url):
                        let (data, _) = try await URLSession.shared.data(from: url)
                        let uiImage = UIImage(data: data)!
                        result = try await imageModel.generateContent(uiImage)
                        break
                    }
                    
                    withAnimation {
                        if let response = result.text {
                            completion(MessageItem(user: .botUser, messageKind: .text(response)))
                        }
                    }
                }
            } catch {
                completion(MessageItem(user: .botUser, messageKind: .text(error.localizedDescription)))
            }
        }
    }
}

// MARK: Chatting structs

struct MyChatUser: ChatUser {
    let id = UUID()
    var userName: String
    var avatar: UIImage?
    var avatarURL: URL?
    
    private init(userName: String, avatar: UIImage? = nil, avatarURL: URL? = nil) {
        self.userName = userName
        self.avatar = avatar
        self.avatarURL = avatarURL
    }
    
    static let botUser = MyChatUser(userName: "GeminiAI", avatar: UIImage(resource: .gemini))
    static let senderUser = MyChatUser(userName: "Person", avatar: UIImage(systemName: "person.circle.fill"))
}

struct MessageItem: ChatMessage {
    let id = UUID()
    
    var user: MyChatUser
    
    var messageKind: SwiftyChat.ChatMessageKind
    
    var isSender: Bool = false
    
    var date: Date = .now
}
