//
//  ViewModel.swift
//  GeminiTrial
//
//  Created by Sharan Thakur on 15/12/23.
//

import GoogleGenerativeAI
import Observation
import SwiftUI

extension EnvironmentValues {
    var viewModel: ViewModel {
        get { self[ViewModelKey.self] }
        set { self[ViewModelKey.self] = newValue }
    }
}

struct ViewModelKey: EnvironmentKey {
    static var defaultValue: ViewModel {
        ViewModel()
    }
}

@Observable
class ViewModel {
    private let model: GenerativeModel, imageModel: GenerativeModel
    private let chat: Chat
    
    init() {
        self.model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.stored)
        self.imageModel = GenerativeModel(name: "gemini-pro-vision", apiKey: APIKey.stored)
        self.chat = model.startChat()
    }
    
    #if os(iOS)
    func generateText(from text: String, with uiImage: UIImage?) async throws -> String {
        let response: GenerateContentResponse
        if let uiImage {
            response = try await self.imageModel.generateContent(text, uiImage)
        } else {
            response = try await self.chat.sendMessage(text)
        }
        guard let text = response.text else {
            throw AppError.noResponse
        }
        
        return text
    }
    #else
    func generateText(from text: String, with nsImage: NSImage?) async throws -> String {
        let response: GenerateContentResponse
        if let nsImage {
            response = try await self.imageModel.generateContent(text, nsImage)
        } else {
            response = try await self.chat.sendMessage(text)
        }
        guard let text = response.text else {
            throw AppError.noResponse
        }
        
        return text
    }
    #endif
    
    func generateTextStream(
        from text: String,
        newString: (String) -> Void
    ) async throws {
        let response = self.chat.sendMessageStream(text)
        
        for try await chunk in response {
            if let text = chunk.text {
                newString(text)
            }
        }
    }
}
