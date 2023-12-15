//
//  TextView.swift
//  GeminiTrial
//
//  Created by Sharan Thakur on 15/12/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct TextView: View {
    let alignment: HorizontalAlignment
    let text: LocalizedStringKey
    
    init(showingMessage chatMessage: ChatMessage) {
        self.text = chatMessage.text
        self.alignment = chatMessage.alignment
    }
    
    init(_ text: LocalizedStringKey, alignment: HorizontalAlignment) {
        self.alignment = alignment
        self.text = text
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            Text(text)
                .multilineTextAlignment(alignment == .leading ? .leading : .trailing)
                .contextMenu {
                    Button {
                        #if os(iOS)
                        UIPasteboard.general.setValue(
                            text,
                            forPasteboardType: UTType.plainText.identifier
                        )
                        #else
                        NSPasteboard.general.setString(text.stringKey ?? "", forType: .string)
                        #endif
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                }
        }
        .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .trailing)
        .scrollIndicators(.hidden, axes: .horizontal)
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        .scrollTargetLayout()
    }
}

#Preview {
    List {
        TextView("**Show me** power ~lost in time~", alignment: .leading)
        TextView("**Show me** power _lost in time_", alignment: .trailing)
    }
    .frame(maxWidth: 1200, maxHeight: 1200)
    .padding()
}
