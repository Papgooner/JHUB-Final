//
//  SettingsView.swift
//  JHUB final
//
//  Created by Thomas Perkes on 04/04/2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("themeColor") private var themeColor = "0.98,0.9,0.2"
    @AppStorage("useFaceId") private var useFaceId = false
    @Environment(\.requestReview) private var requestReview
    @State private var bgColor =
            Color(.sRGB, red: 0.98, green: 0.9, blue: 0.2)
    var body: some View {
        NavigationStack {
            Form {
                ColorPicker("App Theme", selection: $bgColor)
                Toggle("Face ID", isOn: $useFaceId)
                Button("Rate the app") {
                    requestReview()
                }
            }.onAppear {
                bgColor = Color.fromRGBString(themeColor)
            }.onChange(of: bgColor) { themeColor = bgColor.rgbValues()}.navigationTitle("Settings")
                .onChange(of: useFaceId) {
                    print(useFaceId)
                }
        }
    }
    
    func localBgColorChanged() {
        themeColor = bgColor.rgbValues()
    }
}

extension Color {
    // Convert Color to RGB string
    func rgbValues() -> String {
        let components = self.cgColor?.components ?? [0, 0, 0, 0]
        return "\(components[0]),\(components[1]),\(components[2])"
    }

    // Initialize Color from an RGB string
    static func fromRGBString(_ rgbString: String) -> Color {
        let components = rgbString.split(separator: ",").map { Double($0) ?? 0.0 }
        return Color(red: components[0], green: components[1], blue: components[2])
    }
}

#Preview {
    SettingsView()
}
