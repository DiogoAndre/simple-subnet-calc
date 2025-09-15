import SwiftUI

struct OctetBinaryView: View {
    let decimalValue: String
    let startBitPosition: Int
    let maskBits: Int
    
    private var binaryValue: String {
        guard let value = Int(decimalValue) else { return "00000000" }
        return String(value, radix: 2).padding(toLength: 8, withPad: "0", startingAt: 0)
    }
    
    var body: some View {
        VStack(spacing: 2) {
            // Binary digits with appropriate bolding, centered to match IP field
            HStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { bitIndex in
                    let globalBitPosition = startBitPosition + bitIndex
                    let charIndex = binaryValue.index(binaryValue.startIndex, offsetBy: bitIndex)
                    let digit = String(binaryValue[charIndex])
                    
                    Text(digit)
                        .font(.system(.footnote, design: .monospaced))
                        .fontWeight(globalBitPosition < maskBits ? .bold : .regular)
                        .foregroundColor(globalBitPosition < maskBits ? Color.blue : Color.primary)
                }
            }
            .frame(width: 60)  // Match the approximate width of the IP text field
            .padding(.vertical, 2)
        }
    }
}