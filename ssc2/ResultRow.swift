//
//  ResultRow.swift
//  ssc2
//
//  Created by Diogo Assumpcao on 4/18/25.
//

import SwiftUI

// Custom row for displaying results
struct ResultRow: View {
    var label: String
    var value: String
    
    private var formattedValue: String {
        // Check if value is a large number that should be formatted
        if let number = Double(value), number > 1_000_000_000 {
            // Simple approach - just use a scientific formatter
            let formatter = NumberFormatter()
            formatter.numberStyle = .scientific
            formatter.maximumFractionDigits = 2
            formatter.exponentSymbol = "e"
                        
            if let formattedNumber = formatter.string(from: NSNumber(value: number)) {
                // Parse the formatted number to get parts
                let parts = formattedNumber.components(separatedBy: "e")
                if parts.count == 2 {
                    let base = parts[0]
                    var exponent = parts[1]
                    
                    // Remove leading plus sign if present
                    if exponent.hasPrefix("+") {
                        exponent.removeFirst()
                    }
                    
                    // Remove leading zeros from exponent
                    while exponent.hasPrefix("0") && exponent.count > 1 {
                        exponent.removeFirst()
                    }
                    
                    // Convert to superscript
                    let superscriptMap: [Character: String] = [
                        "0": "⁰", "1": "¹", "2": "²", "3": "³", "4": "⁴",
                        "5": "⁵", "6": "⁶", "7": "⁷", "8": "⁸", "9": "⁹",
                        "-": "⁻"
                    ]
                    
                    let superscriptExponent = exponent.map { superscriptMap[$0] ?? String($0) }.joined()
                    
                    return "\(base) × 10\(superscriptExponent)"
                }
            }
        }
        
        return value
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            HStack {
                Spacer()
                Text(formattedValue)
                    .font(.title3)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.trailing)
                    .textSelection(.enabled)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
    }
}


// Side-by-side result rows for compact layout
struct DoubleResultRow: View {
    var leftLabel: String
    var leftValue: String
    var rightLabel: String
    var rightValue: String
    
    var body: some View {
        HStack(spacing: 0) {
            // Custom implementation instead of using ResultRow directly to avoid height issues
            VStack(alignment: .leading, spacing: 4) {
                Text(leftLabel)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                HStack {
                    Spacer()
                    Text(formatValue(leftValue))
                        .font(.title3)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.trailing)
                        .textSelection(.enabled)
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            
            Divider()
                .padding(.vertical, 10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(rightLabel)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                HStack {
                    Spacer()
                    Text(formatValue(rightValue))
                        .font(.title3)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.trailing)
                        .textSelection(.enabled)
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    // Reuse the same formatting logic from ResultRow
    private func formatValue(_ value: String) -> String {
        // Check if value is a large number that should be formatted
        if let number = Double(value), number > 1_000_000_000 {
            // Simple approach - just use a scientific formatter
            let formatter = NumberFormatter()
            formatter.numberStyle = .scientific
            formatter.maximumFractionDigits = 2
            formatter.exponentSymbol = "e"
                        
            if let formattedNumber = formatter.string(from: NSNumber(value: number)) {
                // Parse the formatted number to get parts
                let parts = formattedNumber.components(separatedBy: "e")
                if parts.count == 2 {
                    let base = parts[0]
                    var exponent = parts[1]
                    
                    // Remove leading plus sign if present
                    if exponent.hasPrefix("+") {
                        exponent.removeFirst()
                    }
                    
                    // Remove leading zeros from exponent
                    while exponent.hasPrefix("0") && exponent.count > 1 {
                        exponent.removeFirst()
                    }
                    
                    // Convert to superscript
                    let superscriptMap: [Character: String] = [
                        "0": "⁰", "1": "¹", "2": "²", "3": "³", "4": "⁴",
                        "5": "⁵", "6": "⁶", "7": "⁷", "8": "⁸", "9": "⁹",
                        "-": "⁻"
                    ]
                    
                    let superscriptExponent = exponent.map { superscriptMap[$0] ?? String($0) }.joined()
                    
                    return "\(base) × 10\(superscriptExponent)"
                }
            }
        }
        
        return value
    }
}

#Preview {
    VStack(spacing: 20) {
        ResultRow(label: "Network", value: "192.168.1.0")
            .previewLayout(.sizeThatFits)
        
        ResultRow(label: "Total Hosts", value: "18446744073709551616")
            .previewLayout(.sizeThatFits)
        
        Divider()
        
        DoubleResultRow(
            leftLabel: "/64 Networks", 
            leftValue: "65536", 
            rightLabel: "Total Hosts", 
            rightValue: "18446744073709551616"
        )
    }
    .padding()
}
