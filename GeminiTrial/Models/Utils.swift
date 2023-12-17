//
//  Utils.swift
//  GeminiTrial
//
//  Created by Sharan Thakur on 15/12/23.
//

import ExyteChat
import GoogleGenerativeAI
import SwiftUI

// MARK: - Enums for App.

/// `APIKey` enum manages the retrieval of API keys from the app's configuration file.
///
/// This enum provides a static property to retrieve stored API keys.
enum APIKey {
    /// Retrieves the stored API key from the `Config.plist` file.
    ///
    /// - Returns: The API key as a `String`.
    /// - Throws: `AppError.noSuchKey` if the API key is not found in the file.
    /// - Note: Terminates the app with `fatalError` if the file is not found or other errors occur.
    static var stored: String {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist") else {
            fatalError("No Plist!")
        }
        do {
            let dict = try NSDictionary(contentsOf: url, error: ())
            guard let key = dict["APIKEY"] as? String else {
                throw AppError.noSuchkey
            }
            return key
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

/// `AppError` defines custom error types used within the app.
///
/// Each case provides a user-friendly description.
enum AppError: Error, CustomStringConvertible {
    case noSuchkey
    case noResponse
    
    var description: String {
        switch self {
        case .noSuchkey:
            return "No Such Key Found"
        case .noResponse:
            return "AI has nothing to say"
        }
    }
}

// MARK: - All Extensions.

/// Extension for the `User` type providing predefined static instances.
///
/// Includes static instances for a bot user and the current user.
extension User {
    /// Represents a predefined bot user in the chat.
    static let botUser = User(id: UUID().uuidString, name: "Gemini", avatarURL: nil, isCurrentUser: false)
    
    /// Represents the current user of the app.
    static let currentUser = User(id: UUID().uuidString, name: "User", avatarURL: nil, isCurrentUser: true)
}

/// Extension to add a custom string description to `GenerateContentError`.
///
/// This extension enhances the error type with a human-readable description, which is useful for debugging and displaying error messages to the user.
extension GenerateContentError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .internalError(let underlying):
            return underlying.localizedDescription
        case .promptBlocked(let response):
            return "Prompt blocked for: \(response.text ?? "")"
        case .responseStoppedEarly(let reason, _):
            return "Response stopped early due to \(reason.description)"
        }
    }
}

/// Extension to add a custom string description to `FinishReason`.
///
/// Provides a human-readable description for each case of `FinishReason`, aiding in understanding the cause of a response's completion.
extension FinishReason: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "unknown"
        case .unspecified:
            return "unspecified"
        case .stop:
            return "stop"
        case .maxTokens:
            return "max tokens"
        case .safety:
            return "safety"
        case .recitation:
            return "recitation"
        case .other:
            return "other"
        }
    }
}

/// Extension for `LocalizedStringKey` to access its internal `key` property.
///
/// Note: Utilizes `Mirror` for reflection which can be performance-intensive if overused.
extension LocalizedStringKey {
    /// Retrieves the string key of the `LocalizedStringKey`.
    ///
    /// - Returns: The internal `key` as a `String` if available.
    var stringKey: String? {
        Mirror(reflecting: self).children.first(where: { $0.label == "key" })?.value as? String
    }
}

/// Extension for `UIApplication` to add functionality for dismissing the keyboard.
extension UIApplication {
    /// Dismisses the keyboard by resigning the first responder status.
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
