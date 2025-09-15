//
//  KeyButton.swift
//  ssc2
//
//  Created by Diogo Assumpcao on 4/20/25.
//

import SwiftUI

// MARK: - Key Button
struct KeyButton<Content: View>: View {
    // Content to display
    let content: () -> Content
    
    // Button appearance
    let backgroundColor: Color
    let foregroundColor: Color
    
    // Button action
    let action: () -> Void
    
    // MARK: - Initializers
    init(
        content: @escaping () -> Content,
        backgroundColor: Color = Color.white,
        foregroundColor: Color = Color.primary,
        action: @escaping () -> Void
    ) {
        self.content = content
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.action = action
    }
    
    init(
        key: String,
        backgroundColor: Color = Color.appBackground,
        foregroundColor: Color = Color.primary,
        action: @escaping (String) -> Void
    ) where Content == Text {
        self.content = { Text(key).font(.system(size: 24, weight: .medium).monospaced()) }
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.action = { action(key) }
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: action) {
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(foregroundColor)
        }
        .background(backgroundColor)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}
