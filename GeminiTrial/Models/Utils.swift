//
//  Utils.swift
//  GeminiTrial
//
//  Created by Sharan Thakur on 30/12/23.
//

import SwiftUI
import SwiftyChat

// MARK: AnyView ViewBuilder extension

extension AnyView {
    init<Content: View>(@ViewBuilder contentBuilder: () -> Content) {
        self.init(contentBuilder())
    }
}

// MARK: Chatting properties

extension Color {
    static let chatBlue = Color(#colorLiteral(red: 0, green: 0.597967267, blue: 0, alpha: 1))
    static let chatGray = Color(#colorLiteral(red: 0.7861273885, green: 0.7897668481, blue: 0.7986581922, alpha: 1))
}

extension ChatMessageCellStyle {
    static let myStyle = ChatMessageCellStyle(
        incomingTextStyle: TextCellStyle(
            textStyle: CommonTextStyle(
                textColor: .black,
                font: .system(.body, design: .rounded)
            ),
            textPadding: 16,
            attributedTextStyle: AttributedTextStyle(textColor: .black, fontWeight: .bold),
            cellBackgroundColor: Color.chatGray,
            cellBorderWidth: 0,
            cellShadowRadius: 5,
            cellRoundedCorners: .allCorners
        ),
        outgoingTextStyle: TextCellStyle(
            textStyle: CommonTextStyle(
                textColor: .white,
                font: .system(.body, design: .rounded)
            ),
            textPadding: 16,
            attributedTextStyle: AttributedTextStyle(textColor: .white, fontWeight: .bold),
            cellBackgroundColor: Color.chatBlue,
            cellBorderWidth: 0,
            cellShadowRadius: 5,
            cellRoundedCorners: .allCorners
        ),
        imageTextCellStyle: ImageTextCellStyle(
            textStyle: CommonTextStyle(
                textColor: .white,
                font: .system(.body, design: .rounded)
            ),
            textPadding: 16,
            cellBackgroundColor: .chatBlue,
            cellBorderWidth: 0,
            cellShadowRadius: 5,
            cellShadowColor: .black,
            cellRoundedCorners: [.bottomLeft, .bottomRight]
        )
    )
}

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

/// Extension for `UIApplication` to add functionality for dismissing the keyboard.
extension UIApplication {
    /// Dismisses the keyboard by resigning the first responder status.
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
