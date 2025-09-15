//
//  NumericKeypadView.swift
//  ssc2
//
//  Created by Diogo Assumpcao on 4/20/25.
//

import SwiftUI

struct NumericKeypadView: View {
    // MARK: - Properties
    @Binding var inputText: String
    var onKeyTap: ((String) -> Void)?
    
    // MARK: - Layout Constants
    private let spacing: CGFloat = 10
    private let cornerRadius: CGFloat = 10
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: spacing) {
            // Row 1: 1, 2, 3
            HStack(spacing: spacing) {
                KeyButton(key: "1", action: keyPressed)
                KeyButton(key: "2", action: keyPressed)
                KeyButton(key: "3", action: keyPressed)
            }
            
            // Row 2: 4, 5, 6
            HStack(spacing: spacing) {
                KeyButton(key: "4", action: keyPressed)
                KeyButton(key: "5", action: keyPressed)
                KeyButton(key: "6", action: keyPressed)
            }
            
            // Row 3: 7, 8, 9
            HStack(spacing: spacing) {
                KeyButton(key: "7", action: keyPressed)
                KeyButton(key: "8", action: keyPressed)
                KeyButton(key: "9", action: keyPressed)
            }
            
            // Row 4: ., 0, delete
            HStack(spacing: spacing) {
                KeyButton(key: ".", action: keyPressed)
                KeyButton(key: "0", action: keyPressed)
                
                KeyButton(
                    content: {
                        Image(systemName: "delete.left")
                            .font(.system(size: 18, weight: .medium))
                    },
                    backgroundColor: Color.gray.opacity(0.2),
                    action: deletePressed
                )
            }
        }
        .padding(spacing)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(20)
    }
    
    // MARK: - Actions
    private func keyPressed(_ key: String) {
        if key == "." {
            // Don't append the decimal point, just send it to handler
            onKeyTap?(key)
        } else {
            // Check if adding this digit would exceed 255
            let newText = inputText + key
            if let value = Int(newText), value <= 255 {
                inputText = newText
            }
            onKeyTap?(key)
        }
    }
    
    private func deletePressed() {
        if !inputText.isEmpty {
            inputText.removeLast()
            onKeyTap?("delete")
        } else {
            // If the field is empty and delete is pressed, send special event
            onKeyTap?("delete-empty")
        }
    }
}

// MARK: - Preview
struct NumericKeypadView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text(previewInputText)
                .font(.system(size: 24).monospaced())
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top)
            
            NumericKeypadView(inputText: .constant(previewInputText))
                .padding(.horizontal)
        }
        .background(Color.secondary.opacity(0.1))
    }
    
    static var previewInputText: String = "192.168.1"
}
