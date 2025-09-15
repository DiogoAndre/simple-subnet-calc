//
//  SubnetCalculatorView.swift
//  ssc2
//
//  Created by Diogo Assumpcao on 4/8/25.
//

import SwiftUI


// Helper enum to track focused fields
enum IPField: Hashable {
    case octet1, octet2, octet3, octet4
}

struct SubnetV4CalculatorView: View {
    @EnvironmentObject private var appState: AppState

    // Active field tracking
    @State private var activeField: IPField? = nil
    @State private var isShowingKeypad: Bool = false
    
    // Subnet calculation results
    @State private var networkAddress: String = "0.0.0.0"
    @State private var broadcastAddress: String = "0.0.0.0"
    @State private var numberOfHosts: UInt32 = 0
    @State private var subnetMask: String = "0.0.0.0"
    
    // Computed properties
    private var ipAddress: String {
        return "\(appState.ipv4Octet1).\(appState.ipv4Octet2).\(appState.ipv4Octet3).\(appState.ipv4Octet4)"
    }
    
    // Computed property to determine active text binding
    private var activeTextBinding: Binding<String> {
        switch activeField {
        case .octet1:
            return $appState.ipv4Octet1
        case .octet2:
            return $appState.ipv4Octet2
        case .octet3:
            return $appState.ipv4Octet3
        case .octet4:
            return $appState.ipv4Octet4
        case nil:
            return $appState.ipv4Octet1 // Default, should not happen
        }
    }
    
    // Function to move to next field
    private func moveToNextField() {
        switch activeField {
        case .octet1:
            activeField = .octet2
        case .octet2:
            activeField = .octet3
        case .octet3:
            activeField = .octet4
        case .octet4:
            activeField = nil
            isShowingKeypad = false
        case nil:
            break
        }
    }
    
    // Function to move to previous field
    private func moveToPreviousField() {
        switch activeField {
        case .octet2:
            activeField = .octet1
        case .octet3:
            activeField = .octet2
        case .octet4:
            activeField = .octet3
        case .octet1, nil:
            break // Stay on first field or do nothing if no field is active
        }
    }
    
    // Function to validate current field
    private func validateActiveField() {
        guard let field = activeField else { return }
        
        let text: String
        switch field {
        case .octet1: text = appState.ipv4Octet1
        case .octet2: text = appState.ipv4Octet2
        case .octet3: text = appState.ipv4Octet3
        case .octet4: text = appState.ipv4Octet4
        }
        
        // Validate and format
        if let value = Int(text), value >= 0, value <= 255 {
            let formattedText = "\(value)"
            
            // Update the text binding
            switch field {
            case .octet1: appState.ipv4Octet1 = formattedText
            case .octet2: appState.ipv4Octet2 = formattedText
            case .octet3: appState.ipv4Octet3 = formattedText
            case .octet4: appState.ipv4Octet4 = formattedText
            }
            
            // Auto advance if 3 digits
            if text.count >= 3 {
                moveToNextField()
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
            // Title
            Text("Simple Subnet Calc")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.top)
                .onTapGesture {
                    isShowingKeypad = false
                }

            // IP Address input fields and binary representation card
            VStack(spacing: 12) {
                // IP Address input fields
                HStack(spacing: 10) {
                    IPTextField(
                        text: $appState.ipv4Octet1,
                        field: .octet1,
                        activeField: $activeField
                    ).onChange(of: appState.ipv4Octet1) {
                        calculateSubnet()
                        validateActiveField()
                    }
                    
                    IPTextField(
                        text: $appState.ipv4Octet2,
                        field: .octet2,
                        activeField: $activeField
                    ).onChange(of: appState.ipv4Octet2) {
                        calculateSubnet()
                        validateActiveField()
                    }
                    
                    IPTextField(
                        text: $appState.ipv4Octet3,
                        field: .octet3,
                        activeField: $activeField
                    ).onChange(of: appState.ipv4Octet3) {
                        calculateSubnet()
                        validateActiveField()
                    }
                    
                    IPTextField(
                        text: $appState.ipv4Octet4,
                        field: .octet4,
                        activeField: $activeField
                    ).onChange(of: appState.ipv4Octet4) {
                        calculateSubnet()
                        validateActiveField()
                    }
                }
                
                // Binary representation
                BinaryRepresentationView(
                    octet1: appState.ipv4Octet1,
                    octet2: appState.ipv4Octet2,
                    octet3: appState.ipv4Octet3,
                    octet4: appState.ipv4Octet4,
                    maskBits: Int(appState.ipv4CidrPrefix)
                )
            }
            .contentShape(Rectangle()) // Make entire card tappable
            .onTapGesture {
                isShowingKeypad = false
            }
            .cardStyle()
            .onChange(of: activeField) { oldValue, newValue in
                isShowingKeypad = newValue != nil
            }

            
            // Results
            VStack(spacing: 0) {
                ResultRow(label: "Network", value: networkAddress)
                Divider()
                ResultRow(label: "Broadcast", value: broadcastAddress)
                Divider()
                ResultRow(label: "Hosts", value: "\(numberOfHosts)")
                Divider()
                ResultRow(label: "Mask", value: subnetMask)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                // Clear focus and dismiss keyboard when tapping on results
                isShowingKeypad = false
            }
            .cardStyle()
            
            // CIDR prefix slider with following display
            VStack {
                // We need a ZStack to position the CIDR label above the slider
                ZStack(alignment: .top) {
                    // Slider control with label that follows
                    VStack(spacing: 10) {
                        // This is a blank space to make room for the floating label
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 40)
                        
                        // Slider control
                        Slider(value: $appState.ipv4CidrPrefix, in: 1...32, step: 1)
                            .accentColor(.accentColor)
                            .onChange(of: appState.ipv4CidrPrefix) {
                                calculateSubnet()
                            }
                        
                        // Min/Max labels
                        HStack {
                            Text("1")
                            Spacer()
                            Text("32")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // CIDR prefix display that follows the slider
                    ZStack {
                        CIDRBubbleShape()
                            .fill(Color.blue)
                            .frame(width: 60, height: 45)  // Slightly taller to accommodate arrow
                        
                        Text("\(Int(appState.ipv4CidrPrefix))")
                            .font(.title2)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .offset(y: -4)  // Move text up slightly to account for arrow space
                    }
                    .offset(x: getCIDRLabelPosition(), y: 0)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                // Clear focus and dismiss keyboard when tapping on slider
                isShowingKeypad = false
            }
            .cardStyle()
            
            
            Spacer()
            }
            .background(Color.appBackground)
        }
        .onTapGesture {
            isShowingKeypad = false
        }
        .onAppear {
            calculateSubnet()
        }
        .refreshable {
            // Reset IPv4 fields when refreshed
            appState.resetIPv4Fields()
            
            // Reset calculation results
            networkAddress = "0.0.0.0"
            broadcastAddress = "0.0.0.0"
            numberOfHosts = 0
            subnetMask = "0.0.0.0"
            
            calculateSubnet()
        }
        .sheet(isPresented: $isShowingKeypad, onDismiss: {() -> Void in activeField = nil}) {
            VStack {
                NumericKeypadView(inputText: activeTextBinding, onKeyTap: { key in
                    if key == "." {
                        moveToNextField()
                    } else if key == "delete-empty" {
                        // If attempting to delete on an empty field, move to previous field
                        moveToPreviousField()
                    }
                })
                .padding()
            }
            .presentationDetents([.medium])
        }
    }
    
    // Calculate subnet when IP or prefix changes
    private func calculateSubnet() {
            guard let calculator = try? IPv4Calculator.calculateSubnet(
                ipAddress: ipAddress,
                maskBits: Int(appState.ipv4CidrPrefix)
            ) else {
                return
            }
            
            networkAddress = calculator.networkAddress
            broadcastAddress = calculator.broadcastAddress
            numberOfHosts = calculator.numberOfHosts
            subnetMask = calculator.subnetMask
    }
    
    // Calculate position for the CIDR label based on slider value
    private func getCIDRLabelPosition() -> CGFloat {
        // Calculate position within available width (assuming a standard padding)
        // Maps the CIDR value (1...32) to a position across the width of the slider
        let totalRange: CGFloat = 31
        let normalizedValue = (appState.ipv4CidrPrefix - 1) / totalRange // 0.0 to 1.0
        
        // The available width minus the width of the label (70)
        // We need UIScreen.main.bounds.width to get the device width
        let availableWidth = UIScreen.main.bounds.width - 100 // Adjust for padding and margins
        
        // Calculate position from left edge
        var basePosition = (normalizedValue * availableWidth) - (availableWidth / 2)
        switch appState.ipv4CidrPrefix {
        case 1...4:
            basePosition += appState.ipv4CidrPrefix / 0.3
        case 5...8:
            basePosition += appState.ipv4CidrPrefix / 1.5
        case 9...15:
            basePosition += appState.ipv4CidrPrefix / 2
        case 17...23:
            basePosition -= appState.ipv4CidrPrefix / 5
        case 24...32:
            basePosition -= appState.ipv4CidrPrefix / 3
        default:
            break
        }
        return basePosition
    }
}


// Custom binary representation view with alignment and selective bolding
struct BinaryRepresentationView: View {
    let octet1: String
    let octet2: String
    let octet3: String
    let octet4: String
    let maskBits: Int
    
    private let octets: [String]
    
    init(octet1: String, octet2: String, octet3: String, octet4: String, maskBits: Int) {
        self.octet1 = octet1
        self.octet2 = octet2
        self.octet3 = octet3
        self.octet4 = octet4
        self.maskBits = maskBits
        self.octets = [octet1, octet2, octet3, octet4]
    }
    
    private func binaryOctet(_ decimal: String) -> String {
        guard let value = Int(decimal) else { return "00000000" }
        return String(value, radix: 2).padding(toLength: 8, withPad: "0", startingAt: 0)
    }
    
    var body: some View {
            HStack(alignment: .center, spacing: 20) {
                ForEach(0..<octets.count, id: \.self) { index in
                    OctetBinaryView(
                        decimalValue: octets[index],
                        startBitPosition: index * 8,
                        maskBits: maskBits
                    )
                }
            }
            .padding(.horizontal, 5)
    }
}



// Extension for String to enable subscript access
extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}

#Preview {
    SubnetV4CalculatorView()
        .environmentObject(AppState())
}
