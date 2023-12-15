//
//  Utils.swift
//  GeminiTrial
//
//  Created by Sharan Thakur on 15/12/23.
//

import GoogleGenerativeAI
import SwiftUI

struct ChatMessage: Identifiable {
    let id: UUID
    var text: LocalizedStringKey
    let alignment: HorizontalAlignment
    
    init(_ text: LocalizedStringKey, alignment: HorizontalAlignment) {
        self.id = UUID()
        self.text = text
        self.alignment = alignment
    }
}

enum APIKey {
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

enum AppError: Error, CustomStringConvertible {
    case noSuchkey, noResponse
    
    var description: String {
        switch self {
        case .noSuchkey:
            return "No Such Key Found"
        case .noResponse:
            return "AI has nothing to say"
        }
    }
}

extension LocalizedStringKey {
    // This will mirror the `LocalizedStringKey` so it can access its
    // internal `key` property. Mirroring is rather expensive, but it
    // should be fine performance-wise, unless you are
    // using it too much or doing something out of the norm.
    var stringKey: String? {
        Mirror(reflecting: self).children.first(where: { $0.label == "key" })?.value as? String
    }
}

#if os(iOS)
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
