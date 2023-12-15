//
//  ContentView.swift
//  GeminiTrial
//
//  Created by Sharan Thakur on 15/12/23.
//

import PhotosUI
import SwiftUI

struct ContentView: View {
    @State private var pickedItem: PhotosPickerItem?
#if os(iOS)
    @State private var pickedImage: UIImage?
#else
    @State private var pickedImage: NSImage?
#endif
    @State private var messages = [ChatMessage]()
    @Environment(\.viewModel) private var viewModel: ViewModel
    @State var text: String = ""
    @State var isBusy = false
    
    var body: some View {
        NavigationStack {
            VStack {
                List(messages) { m in
                    TextView(showingMessage: m)
                }
                .listStyle(.inset)
                .opacity(isBusy ? 0.5 : 1.0)
                .overlay(alignment: .center) {
                    if isBusy {
                        ProgressView {
                            Label("Generating...", systemImage: "wand.and.stars.inverse")
                                .symbolEffect(.variableColor.iterative.reversing)
                        }
                    }
                }
                
                inputBar()
                    .padding()
            }
            .onChange(of: pickedItem) {
                guard let pickedItem else {
                    return
                }
                
                pickedItem.loadTransferable(type: Data.self) { result in
                    switch result {
                    case .success(let success):
                        if let success {
                            withAnimation {
#if os(iOS)
                                self.pickedImage = UIImage(data: success)
#else
                                self.pickedImage = NSImage(data: success)
#endif
                                
                            }
                        }
                        return
                    case .failure(let failure):
                        print(failure.localizedDescription)
                        return
                    }
                }
            }
            .toolbar {
                Button {
                    
#if os(iOS)
                    UIApplication.shared.endEditing()
#endif
                    
                    
                } label: {
                    Label("", systemImage: "keyboard.chevron.compact.down")
                        .labelStyle(.iconOnly)
                }
            }
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .navigationTitle("Gemini Pro AI")
        }
    }
    
    @ViewBuilder
    func inputBar() -> some View {
        HStack {
            PhotosPicker(selection: $pickedItem, matching: .any(of: [.images, .not(.cinematicVideos), .not(.videos)])) {
                Label("", systemImage: "photo.badge.plus")
                    .labelStyle(.iconOnly)
            }
            
            VStack(alignment: .leading) {
                if let pickedImage {
#if os(iOS)
                    Image(uiImage: pickedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 75)
                        .overlay(alignment: .topTrailing) {
                            Image(systemName: "x.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 10)
                                .foregroundStyle(.white)
                        }
                        .onTapGesture {
                            withAnimation {
                                self.pickedImage = nil
                            }
                        }
#else
                    Image(nsImage: pickedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 75)
                        .overlay(alignment: .topTrailing) {
                            Image(systemName: "x.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 10)
                                .foregroundStyle(.white)
                        }
                        .onTapGesture {
                            withAnimation {
                                self.pickedImage = nil
                            }
                        }
#endif
                }
                
                TextField("Ask Gemini AI", text: $text, axis: .vertical)
                    .disabled(isBusy)
            }
            
            if text.isEmpty == false {
                Button(action: askAi, label: {
                    Label("Send", systemImage: "paperplane")
                })
            }
        }
        .disabled(isBusy)
    }
    
    func askAi() {
#if os(iOS)
        UIApplication.shared.endEditing()
#endif
        Task {
            withAnimation {
                self.pickedImage = nil
                isBusy = true
            }
            do {
                let input = text
                self.text = ""
                
                let inputMessage = ChatMessage(
                    LocalizedStringKey(input),
                    alignment: .trailing
                )
                self.messages.append(inputMessage)
                
                let response = try await viewModel.generateText(from: input, with: pickedImage)
                
                let message = ChatMessage(
                    LocalizedStringKey(response),
                    alignment: .leading
                )
                
                withAnimation {
                    messages.append(message)
                }
            } catch {
                let message = ChatMessage(
                    LocalizedStringKey(error.localizedDescription),
                    alignment: .leading
                )
                withAnimation {
                    messages.append(message)
                }
            }
            withAnimation {
                isBusy = false
            }
        }
    }
}

#Preview {
    @State var viewModel = ViewModel()
    
    return ContentView()
        .frame(maxWidth: 1280, maxHeight: 1200)
        .environment(\.viewModel, viewModel)
}
