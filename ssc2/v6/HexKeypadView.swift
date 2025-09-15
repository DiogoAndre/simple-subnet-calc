//
//  HexKeypadView.swift
//  ssc2
//
//  Created by Diogo Assumpcao on 4/16/25.
//

import SwiftUI

struct HexKeypadView: View {
    // MARK: - Properties
    @Binding var inputText: String
    var onKeyTap: ((String) -> Void)?
    
    // MARK: - Layout Constants
    private let spacing: CGFloat = 10
    private let cornerRadius: CGFloat = 10
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: spacing) {
            // Row 1: 1, 2, 3, a
            HStack(spacing: spacing) {
                KeyButton(key: "1", action: keyPressed)
                KeyButton(key: "2", action: keyPressed)
                KeyButton(key: "3", action: keyPressed)
                KeyButton(key: "a", action: keyPressed)
            }
            
            // Row 2: 4, 5, 6, b
            HStack(spacing: spacing) {
                KeyButton(key: "4", action: keyPressed)
                KeyButton(key: "5", action: keyPressed)
                KeyButton(key: "6", action: keyPressed)
                KeyButton(key: "b", action: keyPressed)
            }
            
            // Row 3: 7, 8, 9, c
            HStack(spacing: spacing) {
                KeyButton(key: "7", action: keyPressed)
                KeyButton(key: "8", action: keyPressed)
                KeyButton(key: "9", action: keyPressed)
                KeyButton(key: "c", action: keyPressed)
            }
            
            // Row 4: d, 0, f, e
            HStack(spacing: spacing) {
                KeyButton(key: "e", action: keyPressed)
                KeyButton(key: "0", action: keyPressed)
                KeyButton(key: "f", action: keyPressed)
                KeyButton(key: "d", action: keyPressed)

            }
            
            // Row 5: :, delete
            HStack(spacing: spacing) {
                KeyButton(key: ":", action: keyPressed)
                    .frame(maxWidth: .infinity)
                
                KeyButton(
                    content: {
                        Image(systemName: "delete.left")
                            .font(.system(size: 18, weight: .medium))
                    },
                    backgroundColor: Color.gray.opacity(0.2),
                    action: deletePressed
                )
                .frame(maxWidth: .infinity)
            }
        }
        .padding(spacing)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(20)
    }
    
    // MARK: - Actions
    private func keyPressed(_ key: String) {
        inputText.append(key)
        onKeyTap?(key)
    }
    
    private func deletePressed() {
        if !inputText.isEmpty {
            inputText.removeLast()
        }
        onKeyTap?("delete")
    }
}

// MARK: - Preview
struct HexKeypadView_Previews: PreviewProvider {
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
            
            HexKeypadView(inputText: .constant(previewInputText))
                .padding(.horizontal)
        }
        .background(Color.secondary.opacity(0.1))
    }
    
    static var previewInputText: String = "12::a3"
}
