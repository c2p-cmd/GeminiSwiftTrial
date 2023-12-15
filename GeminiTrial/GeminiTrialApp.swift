//
//  GeminiTrialApp.swift
//  GeminiTrial
//
//  Created by Sharan Thakur on 15/12/23.
//

import SwiftUI

@main
struct GeminiTrialApp: App {
    @State var viewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.viewModel, viewModel)
        }
    }
}
