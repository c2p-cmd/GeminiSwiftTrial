//
//  ContentView.swift
//  GeminiTrial
//
//  Created by Sharan Thakur on 30/12/23.
//

import SwiftUI
import SwiftyChat

struct ContentView: View {
    @Environment(\.openURL) var openURL
    
    @State private var viewModel = AIViewModel()
    
    // MARK: - InputBarView variables
    @State private var message = ""
    @State private var isEditing = false
    
    @State private var isBusy = false
    
    var body: some View {
        NavigationStack {
            chatView()
                .opacity(isBusy ? 0.1 : 1.0)
                .overlay(alignment: .center) {
                    if isBusy {
                        ContentUnavailableView(
                            "Generating...",
                            systemImage: "wand.and.stars"
                        )
                        .symbolEffect(.variableColor.iterative.dimInactiveLayers.reversing)
                    }
                }
//                .toolbar {
//                    Button(
//                        "Dismiss",
//                        systemImage: "keyboard.chevron.compact.down.fill",
//                        action: UIApplication.shared.endEditing
//                    )
//                }
                .environmentObject(ChatMessageCellStyle.myStyle)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Gemini Pro AI")
        }
    }
}

extension ContentView {
    @ViewBuilder
    func chatView() -> some View {
        ChatView<MessageItem, MyChatUser>(messages: $viewModel.messages) {
            AnyView {
                inputToolBar()
            }
        }
        .messageCellContextMenu { messageItem in
            AnyView {
                contextMenu(messageItem: messageItem)
            }
        }
        .onMessageCellTapped { item in
            if case ChatMessageKind.text(let text) = item.messageKind {
                matchAndOpen(text: text)
            }
            if case ChatMessageKind.imageText(_, let text) = item.messageKind {
                matchAndOpen(text: text)
            }
        }
    }
    
    func matchAndOpen(text: String) {
        let types = NSTextCheckingResult.CheckingType.link.rawValue
        
        let detector = try! NSDataDetector(types: types)
        
        let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
        
        for match in matches {
            if match.resultType == .link, let url = match.url {
                openURL.callAsFunction(url) { accepted in
                    print(accepted.description)
                }
            }
        }
    }
}

extension ContentView {
    @ViewBuilder
    func contextMenu(messageItem: MessageItem) -> some View {
        if case ChatMessageKind.text(let textString) = messageItem.messageKind {
            VStack {
                Button("Copy", systemImage: "doc.on.doc") {
                    UIPasteboard.general.string = textString
                }
                ShareLink(item: textString)
            }
        }
        if case ChatMessageKind.image(let imageKind) = messageItem.messageKind {
            switch imageKind {
            case .local(let image):
                ShareLink(
                    item: Image(uiImage: image),
                    preview: SharePreview(
                        "Preview",
                        image: Image(uiImage: image)
                    )
                )
            case .remote(let url):
                ShareLink(item: url)
            }
        }
        if case ChatMessageKind.imageText(let imageKind, _) = messageItem.messageKind {
            switch imageKind {
            case .local(let image):
                ShareLink(
                    item: Image(uiImage: image),
                    preview: SharePreview(
                        "Preview",
                        image: Image(uiImage: image)
                    )
                )
            case .remote(let url):
                ShareLink(item: url)
            }
        }
    }
}

extension ContentView {
    @ViewBuilder
    func inputToolBar() -> some View {
        BasicInputView(
            message: $message,
            isEditing: $isEditing,
            placeholder: "Ask AI!"
        ) { messageKind in
            withAnimation {
                viewModel.messages.append(
                    MessageItem(user: .senderUser, messageKind: messageKind, isSender: true)
                )
                isBusy = true
                isEditing = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                viewModel.askAI(kind: messageKind) { resultMessage in
                    isBusy = false
                    DispatchQueue.main.async {
                        withAnimation {
                            viewModel.messages.append(
                                resultMessage
                            )
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 15)
        .padding(.bottom, 20)
    }
}

#Preview {
    ContentView()
}
