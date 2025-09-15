//
//  IPTextField.swift
//  ssc2
//
//  Created by Diogo Assumpcao on 4/11/25.
//

import SwiftUI

// Custom TextField for full IPv6 address
struct IPv6TextField: View {
    @Binding var text: String
    var field: IPv6Field
    
    // Maximum length of a valid IPv6 address: 39 characters
    // (8 segments of 4 hex chars + 7 colons)
    private let maxLength = 39
    
    // State for showing custom hex keypad
    @State private var isShowingKeypad = false
    
    init(text: Binding<String>, 
         field: IPv6Field) {
        self._text = text
        self.field = field
    }
    
    var body: some View {
        ZStack {
            TextField("2001:db8::1", text: $text)
                .disabled(true) // Disable system keyboard
                .lineLimit(1)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(10)
                .background(Color.appBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isShowingKeypad ? Color.blue : Color(.systemGray), lineWidth: isShowingKeypad ? 2.0 : 0.5)
                )
                .onTapGesture {
                    isShowingKeypad = true
                }
            
            // Overlay clear button if there's text
            if !text.isEmpty {
                HStack {
                    Spacer()
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                }
            }
        }
        .onChange(of: text) {
            validateAndFormatInput()
        }
        .sheet(isPresented: $isShowingKeypad) {
            VStack {
                HexKeypadView(inputText: $text)
                    .padding()
                
//                Button("Done") {
//                    isShowingKeypad = false
//                }
//                .font(.headline)
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .cornerRadius(10)
//                .padding()
            }
            .presentationDetents([.medium])
        }
    }
    
    private func validateAndFormatInput() {
        // Filter input to only allow valid IPv6 characters (hex digits and colons)
        let validCharacterSet = CharacterSet(charactersIn: "0123456789abcdefABCDEF:")
        let filtered = String(text.unicodeScalars.filter { validCharacterSet.contains($0) })
        
        if filtered != text {
            text = filtered
        }
        
        // Enforce maximum length
        if text.count > maxLength {
            text = String(text.prefix(maxLength))
        }
        
        // Auto-insert colon after 4 consecutive hex characters
        var segments = text.components(separatedBy: ":")
        
        // Process each segment to ensure it doesn't exceed 4 hex characters
        for i in 0..<segments.count {
            if i >= 8 {
                // IPv6 addresses have a maximum of 8 segments
                segments = Array(segments.prefix(8))
                break
            }
            
            if segments[i].count > 4 {
                // If a segment has more than 4 characters, break it into valid segments
                let segment = segments[i]
                segments[i] = String(segment.prefix(4))
                
                // If there are remaining characters, insert them into the next position
                let remaining = String(segment.dropFirst(4))
                if !remaining.isEmpty {
                    if i + 1 < segments.count {
                        segments.insert(remaining, at: i + 1)
                    } else if i < 7 { // Ensure we don't exceed 8 segments
                        segments.append(remaining)
                    }
                }
            }
        }
        
        // Rejoin with colons and update if different
        let modifiedText = segments.joined(separator: ":")
        if modifiedText != text {
            text = modifiedText
        }
    }
}
