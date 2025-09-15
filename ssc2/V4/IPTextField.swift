//
//  IPTextField.swift
//  ssc2
//
//  Created by Diogo Assumpcao on 4/11/25.
//

import SwiftUI

// Simple IP TextField without keyboard handling
struct IPTextField: View {
    @Binding var text: String
    var field: IPField
    @Binding var activeField: IPField?
    
    var body: some View {
        TextField("0", text: $text)
            .disabled(true) // Disable system keyboard
            .lineLimit(1)
            .font(.title2) // Slightly smaller font
            .multilineTextAlignment(.center)
            .padding(10) // Reduced padding
            .frame(width: 70) // Reduced width
            .background(Color.appBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(activeField == field ? Color.blue : Color.gray.opacity(0.5),
                            lineWidth: activeField == field ? 2.0 : 0.5)
            )
            .onTapGesture {
                activeField = field
            }
    }
}
