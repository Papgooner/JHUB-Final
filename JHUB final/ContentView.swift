//
//  ContentView.swift
//  JHUB final
//
//  Created by Thomas Perkes on 04/04/2025.
//

import SwiftUI
import SwiftData
import LocalAuthentication

struct ContentView: View {
    @AppStorage("themeColor") private var themeColor = "0.98,0.9,0.2"
    @State private var isUnlocked = false
    @AppStorage("useFaceId") private var useFaceId = false
    
    var body: some View {
        TabView {
                if isUnlocked {
                    ReceiptListView().tabItem { Image(systemName: "list.bullet"); }
                    SettingsView().tabItem { Image(systemName: "gear"); }
                } else {
                    Text("Not authorised")
                }
        }.onAppear(perform: isFaceIdEnabled)
          .tint(Color.fromRGBString(themeColor))
    }
    
    func isFaceIdEnabled() {
        if useFaceId {
            authenticate()
        } else {
            isUnlocked = true
        }
    }
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "For security"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in if success {
                isUnlocked = true
            } else {
                isUnlocked = false
            }}
        } else {
            isUnlocked = false
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Receipt.self, inMemory: true)
}
