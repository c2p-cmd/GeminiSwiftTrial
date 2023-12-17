//
//  ContentView.swift
//  GeminiTrial
//
//  Created by Sharan Thakur on 15/12/23.
//

import ExyteChat
import SwiftUI

/// `ContentView` serves as the main interface for the chat application.
///
/// This SwiftUI view integrates a chat view, input toolbar, and additional functionalities like a swipe gesture to dismiss the keyboard and a toolbar for sharing.
struct ContentView: View {
    @Environment(\.viewModel) private var viewModel: ViewModel
    
    @State private var isBusy = false
    @State private var showMenu = false
    
    /// Gesture to dismiss the keyboard by swiping.
    let swipeToDismissKeyboard = DragGesture().onEnded { value in
        UIApplication.shared.endEditing()
    }
    
    var body: some View {
        NavigationStack {
            ChatView(
                messages: viewModel.messages,
                didSendMessage: didSendMessage(_:),
                inputViewBuilder: inputViewToolbar(
                    textBinding:attachments:state:style:actionClosure:dismissKeyboardClosure:
                )
            )
            .chatType(.chat)
            .setMediaPickerSelectionParameters(MediaPickerParameters(
                mediaType: .photo,
                selectionStyle: .checkmark,
                selectionLimit: 1,
                showFullscreenPreview: true
            ))
            .showMessageMenuOnLongPress(false)
            .messageUseMarkdown(messageUseMarkdown: true)
            .transition(.push(from: .bottom))
            .id(viewModel.messages.description)
            .padding([.bottom, .horizontal])
            .opacity(isBusy ? 0.5 : 1.0)
            .overlay(alignment: .center) {
                if isBusy {
                    ProgressView {
                        Label("Generating...", systemImage: "wand.and.stars.inverse")
                    }
                    .opacity(1.0)
                }
            }
            .gesture(swipeToDismissKeyboard)
            .toolbar {
                ShareLink(item: viewModel.lastBotMessage() ?? "", subject: Text("Gemini's Response"))
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Gemini Pro AI")
        }
    }
}

extension ContentView {
    /// Builds the input view toolbar for the chat interface.
    ///
    /// Depending on the style, this function provides different UI components for message input and additional actions like sending photos or copying text.
    @ViewBuilder
    func inputViewToolbar(
        textBinding: Binding<String>,
        attachments: InputViewAttachments,
        state: InputViewState,
        style: InputViewStyle,
        actionClosure: @escaping (InputViewAction) -> Void,
        dismissKeyboardClosure: () -> Void
    ) -> some View {
        Group {
            switch style {
            case .message: // input view on chat screen
                HStack(alignment: .bottom) {
                    VStack(spacing: 30) {
                        if showMenu {
                            Button {
                                actionClosure(.photo)
                            } label: {
                                Label("", systemImage: "paperclip.circle.fill")
                            }
                            
                            Button {
                                copyToClipboard()
                            } label: {
                                Label("Copy response", systemImage: "doc.on.doc.fill")
                            }
                        }
                        
                        Toggle(isOn: $showMenu) {
                            Label("", systemImage: showMenu ? "x.circle" : "plus")
                                .font(.headline)
                                .symbolVariant(.circle)
                                .labelStyle(.iconOnly)
                        }
                        .toggleStyle(.button)
                    }
                    
                    TextField("Write your message", text: textBinding, axis: .vertical)
                    if textBinding.wrappedValue.isEmpty == false {
                        Button {
                            actionClosure(.send)
                        } label: {
                            Label("", systemImage: "paperplane.fill")
                        }
                    }
                }
                .transition(.push(from: .bottom))
                .id(showMenu.description)
                .animation(.interpolatingSpring, value: showMenu.description)
                .labelStyle(.iconOnly)
            case .signature: // input view on photo selection screen
                HStack {
                    TextField("Compose a signature for photo", text: textBinding, axis: .vertical)
                        .background(Color.green)
                    Button {
                        actionClosure(.send)
                    } label: {
                        Label("", systemImage: "paperplane.fill")
                    }
                }
            }
        }
        .padding(.top)
    }
    
    /// Copies the last bot message to the clipboard.
    func copyToClipboard() {
        let lastBotMessage = viewModel.lastBotMessage()
        if let lastBotMessage {
            UIPasteboard.general.string = lastBotMessage
        }
    }
}

extension ContentView {
    /// Handles sending a message and updating the UI accordingly.
    ///
    /// This function processes the user's input, generates a response using the `viewModel`, and updates the chat view with new messages.
    func didSendMessage(_ draftMessage: DraftMessage) {
        Task {
            await UIApplication.shared.endEditing()
        }
        Task {
            var inputMessage = Message(
                id: UUID().uuidString,
                user: .currentUser,
                text: draftMessage.text
            )
            
            if let media = draftMessage.medias.first,
               let url = await media.getURL(),
               let thumbnailUrl = await media.getThumbnailURL() {
                
                inputMessage.attachments = [
                    Attachment(
                        id: media.id.uuidString,
                        thumbnail: thumbnailUrl,
                        full: url,
                        type: .image
                    )
                ]
            }
            
            withAnimation {
                viewModel.append(message: inputMessage)
            }
            
            isBusy = true
            
            let reply: Message
            do {
                reply = try await viewModel.generateText(from: draftMessage)
            } catch {
                reply = Message(
                    id: UUID().uuidString,
                    user: .botUser,
                    text: error.localizedDescription
                )
            }
            
            withAnimation {
                viewModel.append(message: reply)
            }
            
            isBusy = false
        }
    }
}

#Preview {
    ContentView()
}
